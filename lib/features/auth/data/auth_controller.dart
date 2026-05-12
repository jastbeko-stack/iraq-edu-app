import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../study_guides/data/supabase_guides_service.dart'
    show supabaseClientProvider;
import '../domain/auth_state.dart';

/// Email/password authentication backed by Supabase Auth.
///
/// Supabase manages session persistence for us (encrypted in
/// `flutter_secure_storage` on mobile, `localStorage` on web), so the
/// controller's job is just to map `User` ↔ [AuthUser] and translate
/// `AuthException` codes into Arabic-friendly messages.
class AuthController extends StateNotifier<AuthState> {
  AuthController(supa.SupabaseClient client)
      : _client = client,
        super(const AuthSignedOut()) {
    _restore();
    _sub = _client!.auth.onAuthStateChange.listen(_onAuthChange);
  }

  /// Test-only constructor that creates a controller without any Supabase
  /// subscription. Used by widget tests where we don't want a Supabase
  /// session-refresh timer left pending after the widget tree disposes.
  AuthController.signedOutForTest()
      : _client = null,
        super(const AuthSignedOut());

  final supa.SupabaseClient? _client;
  StreamSubscription<supa.AuthState>? _sub;

  void _restore() {
    final client = _client;
    if (client == null) return;
    final session = client.auth.currentSession;
    final user = client.auth.currentUser;
    if (session != null && user != null) {
      state = AuthSignedIn(user: _mapUser(user));
    }
  }

  AuthUser _mapUser(supa.User u) {
    final meta = u.userMetadata ?? const <String, dynamic>{};
    return AuthUser(
      uid: u.id,
      email: u.email ?? '',
      displayName: meta['display_name'] as String?,
    );
  }

  void _onAuthChange(supa.AuthState event) {
    final session = event.session;
    if (session != null) {
      state = AuthSignedIn(user: _mapUser(session.user));
    } else if (state is AuthSignedIn) {
      // Only collapse to signed-out when we *were* signed in. Don't stomp on
      // an in-flight error message or the "check your email" state.
      state = const AuthSignedOut();
    }
  }

  /// Create a new student account. If the project has "Confirm email"
  /// enabled, this transitions to [AuthAwaitingConfirmation] and the user
  /// has to click the link in their inbox before [signIn] will succeed.
  /// Otherwise it transitions straight to [AuthSignedIn].
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedName = displayName?.trim();
    try {
      final res = await _client!.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: trimmedName != null && trimmedName.isNotEmpty
            ? {'display_name': trimmedName}
            : null,
      );
      final user = res.user;
      final session = res.session;
      if (user != null && session != null) {
        state = AuthSignedIn(user: _mapUser(user));
        return;
      }
      // No session means "confirm your email" is on. The Supabase SDK still
      // returns a User row but no auth tokens until confirmation completes.
      state = AuthAwaitingConfirmation(email: trimmedEmail);
    } on supa.AuthException catch (e) {
      state = AuthError(message: _arabicError(e), previous: state);
    } catch (e) {
      state = AuthError(
        message: 'تعذر إنشاء الحساب. تحقق من اتصالك بالإنترنت.',
        previous: state,
      );
    }
  }

  /// Sign in with email + password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client!.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) {
        state = AuthError(
          message: 'تعذر تسجيل الدخول. حاول مرة أخرى.',
          previous: state,
        );
        return;
      }
      state = AuthSignedIn(user: _mapUser(user));
    } on supa.AuthException catch (e) {
      state = AuthError(message: _arabicError(e), previous: state);
    } catch (e) {
      state = AuthError(
        message: 'تعذر تسجيل الدخول. تحقق من اتصالك بالإنترنت.',
        previous: state,
      );
    }
  }

  /// Send a password-reset email. Caller (UI) is expected to show a
  /// "check your inbox" snack; we don't move into [AuthError] on success
  /// because the user is still meant to stay on the login screen.
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _client!.auth.resetPasswordForEmail(email.trim());
      return true;
    } on supa.AuthException catch (e) {
      state = AuthError(message: _arabicError(e), previous: state);
      return false;
    } catch (e) {
      state = AuthError(
        message: 'تعذر إرسال رابط الاستعادة. حاول لاحقاً.',
        previous: state,
      );
      return false;
    }
  }

  /// Sign in with Google via Supabase OAuth.
  ///
  /// On web this performs a full-page redirect to Google's consent screen
  /// and back to the app, after which Supabase fires `onAuthStateChange`
  /// with the new session. On native platforms this opens an in-app browser.
  /// The Google provider must be enabled in the Supabase dashboard under
  /// Authentication → Providers.
  Future<void> signInWithGoogle() async {
    try {
      await _client!.auth.signInWithOAuth(
        supa.OAuthProvider.google,
        // Redirect back to the same origin on web so we land on the Hub.
        redirectTo: null,
      );
    } on supa.AuthException catch (e) {
      state = AuthError(message: _arabicError(e), previous: state);
    } catch (e) {
      state = AuthError(
        message: 'تعذر تسجيل الدخول بـ Google. حاول مرة أخرى.',
        previous: state,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _client!.auth.signOut();
    } finally {
      state = const AuthSignedOut();
    }
  }

  /// Reset transient error / awaiting-confirmation state back to whatever
  /// preceded it. Useful when the user dismisses an error banner.
  void clearTransient() {
    final s = state;
    if (s is AuthError) {
      state = s.previous ?? const AuthSignedOut();
    } else if (s is AuthAwaitingConfirmation) {
      state = const AuthSignedOut();
    }
  }

  String _arabicError(supa.AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }
    if (msg.contains('already registered') ||
        msg.contains('user already registered') ||
        msg.contains('user_already_exists')) {
      return 'هذا البريد مسجّل مسبقاً. سجّل الدخول مباشرة.';
    }
    if (msg.contains('email not confirmed')) {
      return 'لم تؤكّد بريدك بعد. افتح بريدك واضغط على رابط التأكيد.';
    }
    if (msg.contains('weak password') || msg.contains('password should be')) {
      return 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل.';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'حاولت كثيراً. انتظر دقيقة وأعد المحاولة.';
    }
    if (msg.contains('email') && msg.contains('invalid')) {
      return 'صيغة البريد الإلكتروني غير صحيحة.';
    }
    return 'حدث خطأ: ${e.message}';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(supabaseClientProvider)),
);

/// Convenience: is the user signed in?
final isSignedInProvider = Provider<bool>(
  (ref) => ref.watch(authControllerProvider) is AuthSignedIn,
);

/// Convenience: the signed-in user, or null.
final currentUserProvider = Provider<AuthUser?>((ref) {
  final s = ref.watch(authControllerProvider);
  return s is AuthSignedIn ? s.user : null;
});
