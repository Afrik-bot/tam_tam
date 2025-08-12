import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final _supabase = SupabaseService.instance;

  // Enhanced signup method with proper error handling and database trigger integration
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
    String? phoneNumber,
  }) async {
    try {
      // Validate inputs before attempting signup
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Email and password are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters long');
      }

      if (username != null && username.trim().isEmpty) {
        throw Exception('Username cannot be empty');
      }

      // Prepare metadata for the database trigger
      final metadata = <String, dynamic>{
        'role': 'user',
      };

      if (username != null && username.trim().isNotEmpty) {
        metadata['username'] = username.trim();
      }

      if (fullName != null && fullName.trim().isNotEmpty) {
        metadata['full_name'] = fullName.trim();
      }

      if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
        metadata['phone_number'] = phoneNumber.trim();
      }

      // Sign up user - the database trigger will handle profile creation
      final response = await _supabase.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: metadata,
      );

      return response;
    } on AuthException catch (e) {
      // Handle Supabase-specific auth errors
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        throw Exception('Email and password are required');
      }

      return await _supabase.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  static Future<void> signOut() async {
    try {
      await _supabase.client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // Enhanced OAuth methods with better error handling
  static Future<bool> signInWithGoogle() async {
    try {
      await _supabase.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'tam-tam://login-callback/',
      );
      return true;
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  static Future<bool> signInWithApple() async {
    try {
      await _supabase.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'tam-tam://login-callback/',
      );
      return true;
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Apple sign in failed: ${e.toString()}');
    }
  }

  static User? get currentUser => _supabase.client.auth.currentUser;
  static Session? get currentSession => _supabase.client.auth.currentSession;
  static Stream<AuthState> get authStateChanges =>
      _supabase.client.auth.onAuthStateChange;

  static bool get isAuthenticated => currentUser != null;

  static Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw Exception('Email is required');
      }
      await _supabase.client.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  static Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.client.auth
          .updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  static Future<void> updateEmail(String newEmail) async {
    try {
      await _supabase.client.auth.updateUser(UserAttributes(email: newEmail));
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Email update failed: ${e.toString()}');
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
          .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Enhanced username availability check using database function
  static Future<bool> checkUsernameAvailability(String username) async {
    if (username.trim().isEmpty) return false;

    // Basic validation first
    final cleanUsername = username.trim();
    if (cleanUsername.length < 3) return false;
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(cleanUsername)) return false;

    try {
      final response = await _supabase.client.rpc('is_username_available',
          params: {'check_username': cleanUsername});

      return response as bool? ?? false;
    } catch (e) {
      print('Username availability check error: $e');
      // Fallback to direct query if function doesn't exist
      try {
        final directCheck = await _supabase.client
            .from('user_profiles')
            .select('id')
            .eq('username', cleanUsername)
            .limit(1);
        return directCheck.isEmpty;
      } catch (e2) {
        print('Direct username check error: $e2');
        // Return false to be safe - assume username is taken if we can't check
        return false;
      }
    }
  }

  // Enhanced username suggestions using database function
  static Future<List<String>> getUsernameSuggestions(
      String preferredUsername) async {
    if (preferredUsername.trim().isEmpty) return [];

    final cleanUsername = preferredUsername.trim();

    try {
      final response = await _supabase.client.rpc(
          'suggest_username_alternatives',
          params: {'preferred_username': cleanUsername, 'limit_count': 5});

      if (response is List) {
        final suggestions = response.cast<String>();
        // Filter to ensure all suggestions are valid
        return suggestions
            .where(
                (s) => s.isNotEmpty && RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(s))
            .toList();
      }

      // Fallback suggestions if function fails
      return _generateFallbackSuggestions(cleanUsername);
    } catch (e) {
      print('Username suggestions error: $e');
      // Generate fallback suggestions
      return _generateFallbackSuggestions(cleanUsername);
    }
  }

  // Enhanced email availability check with proper error handling
  static Future<bool> checkEmailAvailability(String email) async {
    if (email.trim().isEmpty) return false;

    final cleanEmail = email.trim().toLowerCase();

    // Basic email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(cleanEmail)) {
      return false;
    }

    try {
      final response = await _supabase.client
          .from('user_profiles')
          .select('id')
          .eq('email', cleanEmail)
          .maybeSingle();

      return response == null;
    } catch (e) {
      print('Email availability check error: $e');
      // Return true for email check failures to avoid blocking registration
      // The actual signup will catch duplicate emails
      return true;
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
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  static Future<void> refreshSession() async {
    try {
      await _supabase.client.auth.refreshSession();
    } on AuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      throw Exception('Session refresh failed: ${e.toString()}');
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

  // Helper method to generate fallback username suggestions
  static List<String> _generateFallbackSuggestions(String baseUsername) {
    final suggestions = <String>[];
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    for (int i = 1; i <= 5; i++) {
      suggestions.add('${baseUsername}_$i');
    }

    // Add timestamp-based suggestion
    suggestions.add('${baseUsername}_$timestamp');

    return suggestions.take(5).toList();
  }

  // Helper method to handle auth errors consistently
  static String _handleAuthError(AuthException e) {
    switch (e.message.toLowerCase()) {
      case String msg when msg.contains('user already registered'):
      case String msg when msg.contains('email already registered'):
      case String msg when msg.contains('email already in use'):
        return 'Email is already registered. Please try logging in.';
      case String msg when msg.contains('invalid email'):
        return 'Please enter a valid email address.';
      case String msg when msg.contains('password'):
        return 'Password should be at least 6 characters long.';
      case String msg when msg.contains('weak password'):
        return 'Please choose a stronger password.';
      case String msg when msg.contains('invalid credentials'):
      case String msg when msg.contains('invalid login credentials'):
        return 'Invalid email or password.';
      case String msg when msg.contains('email not confirmed'):
        return 'Please check your email and confirm your account.';
      case String msg when msg.contains('too many requests'):
        return 'Too many attempts. Please try again later.';
      case String msg when msg.contains('signup disabled'):
        return 'Account registration is currently disabled.';
      case String msg when msg.contains('captcha'):
        return 'Please complete the captcha verification.';
      default:
        return e.message;
    }
  }
}
