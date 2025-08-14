import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient? get _supabase {
    try {
      return SupabaseService.instance.isInitialized
          ? SupabaseService.instance.client
          : null;
    } catch (e) {
      return null;
    }
  }

  // Get current user
  User? get user {
    try {
      return _supabase?.auth.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Check if user is authenticated (instance getter)
  bool get isLoggedIn {
    try {
      return user != null && SupabaseService.instance.isInitialized;
    } catch (e) {
      return false;
    }
  }

  // FIXED: Add isAuthenticated as instance property
  bool get isAuthenticated {
    try {
      return _instance.isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  // Static instance getter for convenient access
  static AuthService get instance => _instance;

  // Static accessors that existing code expects
  static User? get currentUser => _instance.user;

  // FIXED: Add instance methods that login screen expects
  Future<bool> signInWithGoogle() async {
    try {
      if (_supabase == null) return false;

      final response = await _supabase!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.tam_tam.app://login-callback',
      );

      return response;
    } catch (e) {
      return false; // Return false on error instead of rethrowing
    }
  }

  Future<bool> signInWithApple() async {
    try {
      if (_supabase == null) return false;

      final response = await _supabase!.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.tam_tam.app://login-callback',
      );

      return response;
    } catch (e) {
      return false; // Return false on error instead of rethrowing
    }
  }

  // FIXED: Add the exact static method names the existing code expects
  static Future<bool> signInWithGoogleStatic() async {
    return await _instance._signInWithGoogle();
  }

  static Future<bool> signInWithAppleStatic() async {
    return await _instance._signInWithApple();
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (_supabase == null) {
        throw Exception('Supabase not initialized');
      }

      final response = await _supabase!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up with email and password (instance method)
  Future<AuthResponse> _signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
    String? phoneNumber,
    Map<String, dynamic>? userData,
  }) async {
    try {
      if (_supabase == null) {
        throw Exception('Supabase not initialized');
      }

      final response = await _supabase!.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': fullName ?? username,
          'phone_number': phoneNumber,
          ...?userData,
        },
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out (instance method)
  Future<void> _signOut() async {
    try {
      if (_supabase == null) return;
      await _supabase!.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      if (_supabase == null) {
        throw Exception('Supabase not initialized');
      }
      await _supabase!.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google (instance method)
  Future<bool> _signInWithGoogle() async {
    try {
      if (_supabase == null) return false;

      final response = await _supabase!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.tam_tam.app://login-callback',
      );

      return response;
    } catch (e) {
      return false; // Return false on error instead of rethrowing
    }
  }

  // Sign in with Apple (instance method)
  Future<bool> _signInWithApple() async {
    try {
      if (_supabase == null) return false;

      final response = await _supabase!.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.tam_tam.app://login-callback',
      );

      return response;
    } catch (e) {
      return false; // Return false on error instead of rethrowing
    }
  }

  // Check username availability (instance method)
  Future<bool> _checkUsernameAvailability(String username) async {
    try {
      if (_supabase == null) return false;

      final response = await _supabase!
          .from('user_profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null; // Available if no user found
    } catch (e) {
      return false; // Assume unavailable on error
    }
  }

  // Get username suggestions (instance method)
  Future<List<String>> _getUsernameSuggestions(String baseUsername) async {
    try {
      final suggestions = <String>[];

      // Generate variations of the username
      for (int i = 1; i <= 5; i++) {
        final suggestion = '$baseUsername$i';
        final isAvailable = await _checkUsernameAvailability(suggestion);
        if (isAvailable) {
          suggestions.add(suggestion);
        }
      }

      // Add random number suggestions if not enough
      if (suggestions.length < 3) {
        for (int i = 0; i < 3; i++) {
          final randomNum = DateTime.now().millisecondsSinceEpoch % 10000;
          final suggestion = '$baseUsername$randomNum';
          final isAvailable = await _checkUsernameAvailability(suggestion);
          if (isAvailable && !suggestions.contains(suggestion)) {
            suggestions.add(suggestion);
          }
        }
      }

      return suggestions;
    } catch (e) {
      return [];
    }
  }

  // Check email availability (instance method)
  Future<bool> _checkEmailAvailability(String email) async {
    try {
      if (_supabase == null) return false;

      final response = await _supabase!
          .from('user_profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response == null; // Available if no user found
    } catch (e) {
      return false; // Assume unavailable on error
    }
  }

  // Listen to auth changes
  Stream<AuthState>? get authStateChanges {
    try {
      return _supabase?.auth.onAuthStateChange;
    } catch (e) {
      return null;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated || _supabase == null) return null;

    try {
      final response = await _supabase!
          .from('user_profiles')
          .select('*')
          .eq('id', user!.id)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Static getter for isAuthenticated - renamed to avoid conflict
  static bool get isUserAuthenticated => _instance.isAuthenticated;

  // Static method for signing out
  static Future<void> signOut() async {
    await _instance._signOut();
  }

  // Static method for checking username availability
  static Future<bool> checkUsernameAvailability(String username) async {
    return await _instance._checkUsernameAvailability(username);
  }

  // Static method for getting username suggestions
  static Future<List<String>> getUsernameSuggestions(
      String baseUsername) async {
    return await _instance._getUsernameSuggestions(baseUsername);
  }

  // Static method for sign up
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
    String? phoneNumber,
    Map<String, dynamic>? userData,
  }) async {
    return await _instance._signUp(
      email: email,
      password: password,
      username: username,
      fullName: fullName,
      phoneNumber: phoneNumber,
      userData: userData,
    );
  }

  // Static method for checking email availability
  static Future<bool> checkEmailAvailability(String email) async {
    return await _instance._checkEmailAvailability(email);
  }
}