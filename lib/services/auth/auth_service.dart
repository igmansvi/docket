import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );

    if (response.user != null) {
      await _client.from('users').insert({
        'id': response.user!.id,
        'name': name,
        'email': email,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return response;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Future<void> updateProfile({
    required String name,
    required String role,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in. Cannot update profile.');
    }

    await _client.auth.updateUser(
      UserAttributes(data: {'name': name, 'role': role}),
    );

    await _client
        .from('users')
        .update({'name': name, 'role': role})
        .eq('id', userId);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    try {
      final response = await _client
          .from('users')
          .select('id, name, role, email')
          .eq('id', userId)
          .single();

      return response;
    } on PostgrestException {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> userIds) async {
    try {
      final response = await _client
          .from('users')
          .select('id, name, email, role')
          .inFilter('id', userIds);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
