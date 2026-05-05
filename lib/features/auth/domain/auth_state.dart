/// Authenticated user as exposed to the rest of the app.
///
/// Mirrors the shape of Supabase's `User` (id + email + display_name) so
/// the controller can map straight from `Supabase.instance.client.auth.currentUser`.
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;
}

/// Top-level auth state. Sealed so the UI can `switch` exhaustively.
sealed class AuthState {
  const AuthState();
}

/// No user signed in. Default state at boot.
class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

/// Sign-up succeeded but the project requires email confirmation. The UI
/// shows a "check your inbox" message and waits for the user to come back
/// after clicking the confirmation link in the email.
class AuthAwaitingConfirmation extends AuthState {
  const AuthAwaitingConfirmation({required this.email});
  final String email;
}

/// User finished verification and is now signed in.
class AuthSignedIn extends AuthState {
  const AuthSignedIn({required this.user});
  final AuthUser user;
}

/// A recoverable error happened during sign-in or sign-up.
class AuthError extends AuthState {
  const AuthError({required this.message, this.previous});

  final String message;

  /// Previous state so the UI can decide whether to bounce back to the
  /// login screen or stay on the same screen.
  final AuthState? previous;
}
