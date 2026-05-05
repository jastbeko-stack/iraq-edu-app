import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../coupons/data/coupon_repository.dart'
    show sharedPreferencesProvider;

/// Admin credentials. Hardcoded into the client bundle — anyone with
/// browser dev-tools can extract them, so this is a casual gate, not real
/// security. To upgrade, swap [AdminAuthController.signIn] over to
/// Supabase Auth (or Firebase Auth) and remove the constants entirely.
class AdminCredentials {
  static const email = 'aliluai2001@gmail.com';
  static const password = 'Alilaui99@';
}

const _kAdminSignedInKey = 'admin_signed_in_v1';

sealed class AdminLoginResult {
  const AdminLoginResult();
}

class AdminLoginSuccess extends AdminLoginResult {
  const AdminLoginSuccess();
}

class AdminLoginInvalid extends AdminLoginResult {
  const AdminLoginInvalid();
}

class AdminAuthController extends StateNotifier<bool> {
  AdminAuthController(this._prefs)
    : super(_prefs.getBool(_kAdminSignedInKey) ?? false);

  final SharedPreferences _prefs;

  /// Validates credentials against [AdminCredentials]. In the real backend
  /// this becomes a call to Firebase Auth + a Firestore role check.
  Future<AdminLoginResult> signIn({
    required String email,
    required String password,
  }) async {
    // Email is case-insensitive (matches RFC mailbox conventions) so the
    // user typing 'Aliluai2001@gmail.com' on iOS still authenticates.
    // Password is exact-match — we deliberately don't lowercase it because
    // the chosen password contains uppercase letters whose case matters.
    final emailOk =
        email.trim().toLowerCase() == AdminCredentials.email.toLowerCase();
    final passOk = password == AdminCredentials.password;
    if (!emailOk || !passOk) return const AdminLoginInvalid();
    await _prefs.setBool(_kAdminSignedInKey, true);
    state = true;
    return const AdminLoginSuccess();
  }

  Future<void> signOut() async {
    await _prefs.setBool(_kAdminSignedInKey, false);
    state = false;
  }
}

final adminAuthProvider = StateNotifierProvider<AdminAuthController, bool>(
  (ref) => AdminAuthController(ref.watch(sharedPreferencesProvider)),
);
