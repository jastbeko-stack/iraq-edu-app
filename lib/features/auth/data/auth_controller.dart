import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../coupons/data/coupon_repository.dart'
    show sharedPreferencesProvider;
import '../domain/auth_state.dart';

const _kAuthUidKey = 'auth_uid_v1';
const _kAuthPhoneKey = 'auth_phone_v1';

/// Local stub of phone OTP authentication.
///
/// Real Firebase wiring will replace [AuthController] with one that calls
/// `FirebaseAuth.instance.verifyPhoneNumber` / `signInWithCredential`. The
/// API surface here matches what the screens expect, so swapping the
/// implementation is a one-file change.
///
/// Stub behavior:
/// - Any phone matching `+9647[0-9]{9}` is accepted into the "code sent"
///   state with verification id `stub-<phone>`.
/// - The accepted code is **`123456`** (also surfaced to the UI as a
///   demo hint).
/// - On success a deterministic uid `local-<digits>` is generated and
///   persisted to `SharedPreferences` so the user stays signed in across
///   refreshes.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._prefs) : super(const AuthSignedOut()) {
    _restore();
  }

  final SharedPreferences _prefs;

  /// Validates +964 phone numbers (Iraqi mobile numbers always start with 7
  /// after the country code and are 10 digits long total).
  static final RegExp iraqiMobileRegExp = RegExp(r'^\+9647\d{8}$');

  /// Hardcoded demo OTP, surfaced in the OTP screen to make manual testing
  /// trivial. Real Firebase sends a real SMS so this constant goes away.
  static const stubVerificationCode = '123456';

  void _restore() {
    final uid = _prefs.getString(_kAuthUidKey);
    final phone = _prefs.getString(_kAuthPhoneKey);
    if (uid != null && phone != null) {
      state = AuthSignedIn(
        user: AuthUser(uid: uid, phoneNumber: phone),
      );
    }
  }

  /// Begin sign-in for [phoneNumber] (must be E.164, e.g. `+9647712345678`).
  Future<void> sendCode(String phoneNumber) async {
    final normalized = phoneNumber.replaceAll(RegExp(r'\s'), '');
    if (!iraqiMobileRegExp.hasMatch(normalized)) {
      state = AuthError(
        message: 'الرقم غير صحيح. أدخل رقم عراقي بصيغة +9647XXXXXXXX',
        previous: state,
      );
      return;
    }

    // Simulate the network round-trip Firebase would make.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = AuthCodeSent(
      phoneNumber: normalized,
      verificationId: 'stub-$normalized',
    );
  }

  /// Verify the OTP code against the current [AuthCodeSent] state.
  Future<void> verifyCode(String code) async {
    final current = state;
    if (current is! AuthCodeSent) {
      state = AuthError(
        message: 'لم يتم إرسال أي كود بعد. ابدأ من جديد.',
        previous: current,
      );
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (code != stubVerificationCode) {
      state = AuthError(
        message: 'الكود غير صحيح. حاول مرة أخرى أو أعد إرسال الكود.',
        previous: current,
      );
      return;
    }

    final uid = 'local-${current.phoneNumber.replaceAll('+', '')}';
    await _prefs.setString(_kAuthUidKey, uid);
    await _prefs.setString(_kAuthPhoneKey, current.phoneNumber);
    state = AuthSignedIn(
      user: AuthUser(uid: uid, phoneNumber: current.phoneNumber),
    );
  }

  /// Resend the code (no real cooldown on the stub — the screen enforces
  /// a 60s timer client-side).
  Future<void> resendCode() async {
    final current = state;
    final phoneNumber = switch (current) {
      AuthCodeSent() => current.phoneNumber,
      AuthError(:final previous) when previous is AuthCodeSent =>
        previous.phoneNumber,
      _ => null,
    };
    if (phoneNumber == null) return;
    await sendCode(phoneNumber);
  }

  /// Drop back to phone entry without losing the user's place if the OTP
  /// code was wrong but recoverable.
  void backToPhoneEntry() {
    state = const AuthSignedOut();
  }

  Future<void> signOut() async {
    await _prefs.remove(_kAuthUidKey);
    await _prefs.remove(_kAuthPhoneKey);
    state = const AuthSignedOut();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.watch(sharedPreferencesProvider)),
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
