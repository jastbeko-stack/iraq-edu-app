/// Authenticated user as exposed to the rest of the app.
///
/// Mirrors the shape of [User] from `firebase_auth` (uid + phoneNumber)
/// so swapping the local stub for the real Firebase implementation is a
/// drop-in change.
class AuthUser {
  const AuthUser({required this.uid, required this.phoneNumber});

  final String uid;
  final String phoneNumber;
}

/// Top-level auth state. Sealed so the UI can `switch` exhaustively.
sealed class AuthState {
  const AuthState();
}

/// No user signed in. Default state at boot.
class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

/// We've sent (or "sent" — local stub) a verification code to [phoneNumber].
/// The OTP screen is shown in this state.
class AuthCodeSent extends AuthState {
  const AuthCodeSent({required this.phoneNumber, required this.verificationId});

  /// E.164 phone number, e.g. `+9647712345678`.
  final String phoneNumber;

  /// Opaque id returned by the verification provider. Real Firebase
  /// returns a long string here; the stub returns a uuid-ish string.
  final String verificationId;
}

/// User finished verification and is now signed in.
class AuthSignedIn extends AuthState {
  const AuthSignedIn({required this.user});

  final AuthUser user;
}

/// A recoverable error happened during sign-in or verification.
class AuthError extends AuthState {
  const AuthError({required this.message, this.previous});

  final String message;

  /// Previous state so the UI can decide whether to bounce back to the
  /// phone-entry screen or stay on the OTP screen.
  final AuthState? previous;
}
