import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase Auth so screens never touch the client
/// directly. Turns Supabase's [AuthException] into plain messages a user
/// can read.
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  bool get isSignedIn => currentUser != null;

  /// Fires whenever the signed-in state changes (sign in, sign out, token
  /// refresh). Screens use this to decide whether to show the app or the
  /// login flow.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Could not sign in. Check your connection and try again.');
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _client.auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (_) {
      throw AuthFailure('Could not create your account. Check your connection and try again.');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

/// A user-readable auth error, so screens can just display [message].
class AuthFailure implements Exception {
  final String message;
  AuthFailure(this.message);

  @override
  String toString() => message;
}
