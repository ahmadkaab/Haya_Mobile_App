import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value?.session?.user;
});

class AuthRepository {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  Future<void> signUpWithEmail(String email, String password) async {
    await _auth.signUp(email: email, password: password);
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
