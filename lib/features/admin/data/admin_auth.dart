import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../coupons/data/coupon_repository.dart'
    show sharedPreferencesProvider;

/// Demo admin credentials — visible on the login screen so reviewers can
/// try the portal without backend.
class AdminCredentials {
  static const email = 'admin@iraqedu.com';
  static const password = 'admin123';
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
    // Trim both fields and case-fold the password for the demo so a stray
    // space from autofill or iOS autocapitalize doesn't reject the login.
    // The real Firebase Auth path will be exact-match.
    final emailOk =
        email.trim().toLowerCase() == AdminCredentials.email.toLowerCase();
    final passOk =
        password.trim().toLowerCase() ==
        AdminCredentials.password.toLowerCase();
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
