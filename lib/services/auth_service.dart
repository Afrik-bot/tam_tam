import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

  // FIXED: Enhanced sign in method with improved connection and password handling
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Check network connectivity first
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        throw AuthException(
            'No internet connection. Please check your network settings and try again.');
      }

      // Check if Supabase is initialized
      if (_supabase == null || !SupabaseService.instance.isInitialized) {
        throw AuthException(
            'Connection error. Please check your internet connection and try again.');
      }

      // Validate email and password format
      if (email.trim().isEmpty) {
        throw AuthException('Please enter your email address.');
      }

      if (!_isValidEmail(email.trim())) {
        throw AuthException('Please enter a valid email address.');
      }

      if (password.isEmpty) {
        throw AuthException('Please enter your password.');
      }

      if (password.length < 6) {
        throw AuthException('Password must be at least 6 characters long.');
      }

      // Test connection to Supabase
      final connectionTest = await SupabaseService.instance.testConnection();
      if (!connectionTest) {
        throw AuthException(
            'Unable to connect to server. Please check your internet connection and try again.');
      }

      final response = await _supabase!.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // Additional validation
      if (response.user == null) {
        throw AuthException('Login failed. Please check your credentials.');
      }

      // If we get here without exception, login was successful
      return response;
    } on AuthException {
      // Re-throw AuthException to preserve error details for UI
      rethrow;
    } catch (e) {
      // Handle specific network and connection errors
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('timeout') ||
          errorString.contains('socket') ||
          errorString.contains('host lookup failed') ||
          errorString.contains('no address associated with hostname')) {
        throw AuthException(
            'Connection error. Please check your internet connection and try again.');
      }

      if (errorString.contains('invalid login credentials') ||
          errorString.contains('invalid email or password')) {
        throw AuthException(
            'Invalid email or password. Please check your credentials.');
      }

      if (errorString.contains('email not confirmed')) {
        throw AuthException(
            'Please check your email and click the confirmation link.');
      }

      if (errorString.contains('too many requests')) {
        throw AuthException(
            'Too many login attempts. Please wait a few minutes and try again.');
      }

      // Convert other errors to AuthException
      throw AuthException('Login failed: Please try again.');
    }
  }

  // Helper method to validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
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
        throw AuthException(
            'Supabase not initialized. Please check your configuration.');
      }

      final response = await _supabase!.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'username': username?.trim(),
          'full_name': fullName?.trim() ?? username?.trim(),
          'phone_number': phoneNumber?.trim(),
          ...?userData,
        },
      );

      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  // Reset password with enhanced error handling
  Future<void> resetPassword({required String email}) async {
    try {
      // Check network connectivity first
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        throw AuthException(
            'No internet connection. Please check your network settings and try again.');
      }

      if (_supabase == null) {
        throw AuthException(
            'Connection error. Please check your internet connection and try again.');
      }

      if (email.trim().isEmpty) {
        throw AuthException('Please enter your email address.');
      }

      if (!_isValidEmail(email.trim())) {
        throw AuthException('Please enter a valid email address.');
      }

      await _supabase!.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: 'com.tam_tam.app://reset-password',
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('timeout')) {
        throw AuthException(
            'Connection error. Please check your internet connection and try again.');
      }

      throw AuthException('Password reset failed. Please try again.');
    }
  }

  // FIXED: Enhanced network connectivity check
  Future<bool> _checkNetworkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.ethernet;
    } catch (e) {
      return false;
    }
  }

  // FIXED: Enhanced social login methods with better error handling and connection checks
  Future<bool> signInWithGoogle() async {
    try {
      // Check network connectivity first
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        return false;
      }

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
      // Check network connectivity first
      final hasConnection = await _checkNetworkConnectivity();
      if (!hasConnection) {
        return false;
      }

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

  // Sign out (instance method)
  Future<void> _signOut() async {
    try {
      if (_supabase == null) return;
      await _supabase!.auth.signOut();
    } catch (e) {
      // Silent failure for sign out
      print('Sign out error: $e');
    }
  }

  // Check username availability (instance method)
  Future<bool> _checkUsernameAvailability(String username) async {
    try {
      if (_supabase == null) return false;

      final response = await _supabase!.rpc('is_username_available',
          params: {'check_username': username.trim()});

      return response as bool? ?? false;
    } catch (e) {
      return false; // Assume unavailable on error
    }
  }

  // Get username suggestions (instance method)
  Future<List<String>> _getUsernameSuggestions(String baseUsername) async {
    try {
      if (_supabase == null) return [];

      final suggestions = <String>[];
      final cleanBase = baseUsername.trim().toLowerCase();

      // Generate variations of the username
      for (int i = 1; i <= 5; i++) {
        final suggestion = '$cleanBase$i';
        final isAvailable = await _checkUsernameAvailability(suggestion);
        if (isAvailable) {
          suggestions.add(suggestion);
        }
      }

      // Add random number suggestions if not enough
      if (suggestions.length < 3) {
        for (int i = 0; i < 3; i++) {
          final randomNum = DateTime.now().millisecondsSinceEpoch % 10000;
          final suggestion = '$cleanBase$randomNum';
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
          .eq('email', email.trim().toLowerCase())
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

  // Get user profile data with enhanced error handling
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated || _supabase == null || user == null) return null;

    try {
      final response = await _supabase!
          .from('user_profiles')
          .select('*')
          .eq('id', user!.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // FIXED: Static method aliases for backward compatibility
  static Future<bool> signInWithGoogleStatic() async {
    return await _instance.signInWithGoogle();
  }

  static Future<bool> signInWithAppleStatic() async {
    return await _instance.signInWithApple();
  }

  // Static getter for isAuthenticated
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