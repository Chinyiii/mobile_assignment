import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //Sign in with email and password
  Future<AuthResponse> SignInWithEmailPassword(
      String email, String password) async {
    return await _supabase.auth.signInWithPassword(
        email: email,
        password: password
    );
  }

  //Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //Get user email
  String? getCurrentUserEmail(){
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  Future<int?> getCurrentUserId() async {
    final email = getCurrentUserEmail();
    if (email == null) {
      return null;
    }
    try {
      final response = await _supabase
          .from('users')
          .select('user_id')
          .eq('email', email)
          .single();
      return response['user_id'] as int?;
    } catch (e) {
      return null;
    }
  }
}
