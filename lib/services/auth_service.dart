import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final _supabase = SupabaseService.instance;

  // Remove all mock data and use real Supabase authentication
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.signUp(
        email,
        password,
        username: username,
      );

      // Create user profile if signup successful
      if (response.user != null) {
        await _createUserProfile(
          response.user!.id,
          email,
          username ?? email.split('@')[0],
          fullName ?? username ?? email.split('@')[0],
        );
      }

      return response;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.signIn(email, password);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<void> signOut() async {
    try {
      await _supabase.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  static Future<bool> signInWithGoogle() async {
    try {
      return await _supabase.client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  static Future<bool> signInWithApple() async {
    try {
      return await _supabase.client.auth.signInWithOAuth(OAuthProvider.apple);
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }

  static User? get currentUser => _supabase.currentUser;
  static Session? get currentSession => _supabase.currentSession;
  static Stream<AuthState> get authStateChanges => _supabase.authStateChanges;

  static bool get isAuthenticated => currentUser != null;

  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  static Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.client.auth
          .updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception('Password update failed: $e');
    }
  }

  static Future<void> updateEmail(String newEmail) async {
    try {
      await _supabase.client.auth.updateUser(UserAttributes(email: newEmail));
    } catch (e) {
      throw Exception('Email update failed: $e');
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await _supabase.client
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> checkUsernameAvailability(String username) async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .select('id')
          .eq('username', username);
      return response.isEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .select('id')
          .eq('email', email);
      return response.isEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('No user to delete');

    try {
      // Delete user profile data
      await _supabase.client.from('user_profiles').delete().eq('id', user.id);

      // Note: Deleting the auth user requires admin privileges
      // In a real app, you'd call an admin function or handle this server-side
      await signOut();
    } catch (e) {
      throw Exception('Account deletion failed: $e');
    }
  }

  // Private helper methods
  static Future<void> _createUserProfile(
    String userId,
    String email,
    String username,
    String fullName,
  ) async {
    try {
      await _supabase.client.from('user_profiles').insert({
        'id': userId,
        'email': email,
        'username': username,
        'full_name': fullName,
        'role': 'user',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Create wallet for new user
      await _supabase.client.from('wallets').insert({
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Profile creation failed, but auth user was created
      // In production, you'd want to handle this more gracefully
      print('Profile creation failed: $e');
    }
  }

  static Future<void> refreshSession() async {
    try {
      await _supabase.client.auth.refreshSession();
    } catch (e) {
      throw Exception('Session refresh failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getAuthStats() async {
    final user = currentUser;
    if (user == null) return {};

    try {
      final profile = await getCurrentUserProfile();
      return {
        'user_id': user.id,
        'email': user.email,
        'created_at': user.createdAt,
        'last_sign_in': user.lastSignInAt,
        'username': profile?['username'],
        'role': profile?['role'] ?? 'user',
        'verified': profile?['verified'] ?? false,
        'clout_score': profile?['clout_score'] ?? 0,
      };
    } catch (e) {
      return {
        'user_id': user.id,
        'email': user.email,
        'created_at': user.createdAt,
        'last_sign_in': user.lastSignInAt,
      };
    }
  }
}
