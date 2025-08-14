import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  late final SupabaseClient _client;
  SupabaseClient get client => _client;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('Supabase already initialized');
      return;
    }

    try {
      // Load environment configuration
      String configContent;

      if (kIsWeb) {
        // For web, load from assets
        try {
          configContent = await rootBundle.loadString('env.json');
        } catch (e) {
          debugPrint('Failed to load env.json from assets: $e');
          // Try alternative method for web
          configContent = await _loadEnvForWeb();
        }
      } else {
        try {
          final file = File('env.json');
          configContent = await file.readAsString();
        } catch (e) {
          debugPrint('Failed to load env.json from file system: $e');
          throw Exception(
              'env.json file not found. Please create env.json with your Supabase credentials.');
        }
      }

      final config = json.decode(configContent) as Map<String, dynamic>;
      final supabaseUrl = config['SUPABASE_URL'] as String?;
      final supabaseAnonKey = config['SUPABASE_ANON_KEY'] as String?;

      // Validate that we have real values
      if (supabaseUrl == null ||
          supabaseUrl.isEmpty ||
          supabaseAnonKey == null ||
          supabaseAnonKey.isEmpty ||
          supabaseUrl.contains('your_supabase_url') ||
          supabaseAnonKey.contains('your_supabase_anon_key')) {
        throw Exception(
            'Please configure your Supabase URL and anon key in env.json');
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      _client = Supabase.instance.client;
      _isInitialized = true;

      debugPrint('Supabase connection established successfully');
      debugPrint(
          'Connected to: ${supabaseUrl.replaceAll(RegExp(r'://.*@'), '://***@')}');

      // Test the connection by checking auth status
      final user = _client.auth.currentUser;
      debugPrint('Current auth user: ${user?.email ?? 'Not authenticated'}');
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<String> _loadEnvForWeb() async {
    // Alternative method for web - you might need to adjust this based on your deployment
    try {
      // Try to load from root directory
      final response = await rootBundle.loadString('env.json');
      return response;
    } catch (e) {
      debugPrint('Could not load env.json for web: $e');
      throw Exception(
          'Please ensure env.json is accessible for web deployment');
    }
  }

  // Connection health check
  Future<bool> testConnection() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Simple query to test database connection
      final response =
          await _client.from('user_profiles').select('count').limit(1);

      debugPrint('Database connection test successful');
      return true;
    } catch (e) {
      debugPrint('Database connection test failed: $e');
      return false;
    }
  }

  // Enhanced authentication methods with better error handling and logging
  Future<AuthResponse> signUp(String email, String password,
      {String? username, String? fullName}) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }

    try {
      debugPrint('Attempting signup for email: $email');

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          if (username != null && username.isNotEmpty) 'username': username,
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
          'role': 'user',
        },
      );

      if (response.user != null) {
        debugPrint('Signup successful for user: ${response.user!.id}');

        if (response.session == null) {
          debugPrint(
              'Email confirmation required for user: ${response.user!.email}');
        } else {
          debugPrint('User signed in successfully: ${response.user!.email}');
        }
      }

      return response;
    } catch (error) {
      debugPrint('Signup failed: $error');
      throw Exception('Sign-up failed: $error');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    if (!_isInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }

    try {
      debugPrint('Attempting signin for email: $email');

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('Signin successful for user: ${response.user!.id}');
      }

      return response;
    } catch (error) {
      debugPrint('Signin failed: $error');
      throw Exception('Sign-in failed: $error');
    }
  }

  Future<void> signOut() async {
    if (!_isInitialized) return;

    try {
      await _client.auth.signOut();
      debugPrint('User signed out successfully');
    } catch (error) {
      debugPrint('Signout failed: $error');
      throw Exception('Sign-out failed: $error');
    }
  }

  User? get currentUser => _isInitialized ? _client.auth.currentUser : null;
  Session? get currentSession =>
      _isInitialized ? _client.auth.currentSession : null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<List<Map<String, dynamic>>> getFeedContent({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('content')
          .select('''
            id,
            title,
            description,
            video_url,
            thumbnail_url,
            audio_url,
            view_count,
            like_count,
            comment_count,
            share_count,
            tip_count,
            total_tips_amount,
            tags,
            location,
            type,
            is_public,
            allows_comments,
            allows_duets,
            featured,
            created_at,
            updated_at,
            user_profiles!creator_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count,
              following_count
            )
          ''')
          .eq('type', 'video')
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Process the response to handle nested user profiles
      final processedResponse = response.map((item) {
        final Map<String, dynamic> processedItem = Map.from(item);

        // Flatten user_profiles data for easier access
        if (processedItem['user_profiles'] != null) {
          final userProfile =
              processedItem['user_profiles'] as Map<String, dynamic>;
          processedItem['creator'] = userProfile;
          processedItem['creator_id'] = userProfile['id'];
          processedItem['creator_username'] = userProfile['username'];
          processedItem['creator_full_name'] = userProfile['full_name'];
          processedItem['creator_avatar_url'] = userProfile['avatar_url'];
          processedItem['creator_verified'] = userProfile['verified'] ?? false;
          processedItem['creator_clout_score'] =
              userProfile['clout_score'] ?? 0;
          processedItem['creator_followers_count'] =
              userProfile['followers_count'] ?? 0;
          processedItem['creator_following_count'] =
              userProfile['following_count'] ?? 0;
        }

        // Ensure required fields have default values
        processedItem['view_count'] = processedItem['view_count'] ?? 0;
        processedItem['like_count'] = processedItem['like_count'] ?? 0;
        processedItem['comment_count'] = processedItem['comment_count'] ?? 0;
        processedItem['share_count'] = processedItem['share_count'] ?? 0;
        processedItem['tip_count'] = processedItem['tip_count'] ?? 0;
        processedItem['total_tips_amount'] =
            processedItem['total_tips_amount'] ?? 0.0;
        processedItem['tags'] = processedItem['tags'] ?? [];

        // Provide fallback content for missing media
        if (processedItem['video_url'] == null ||
            processedItem['video_url'].toString().isEmpty) {
          processedItem['video_url'] =
              'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
        }

        if (processedItem['thumbnail_url'] == null ||
            processedItem['thumbnail_url'].toString().isEmpty) {
          processedItem['thumbnail_url'] =
              'https://picsum.photos/400/600?random=${processedItem['id'].hashCode}';
        }

        if (processedItem['creator_avatar_url'] == null ||
            processedItem['creator_avatar_url'].toString().isEmpty) {
          processedItem['creator_avatar_url'] =
              'https://ui-avatars.com/api/?name=${processedItem['creator_username'] ?? 'User'}&background=random&size=150';
        }

        return processedItem;
      }).toList();

      return processedResponse;
    } catch (error) {
      print('Error fetching feed content: $error');
      throw Exception('Failed to fetch feed content: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getViralContent({int limit = 10}) async {
    try {
      final response = await _client
          .from('content')
          .select('''
            id,
            title,
            description,
            video_url,
            thumbnail_url,
            audio_url,
            view_count,
            like_count,
            comment_count,
            share_count,
            tip_count,
            total_tips_amount,
            tags,
            location,
            type,
            is_public,
            allows_comments,
            allows_duets,
            featured,
            created_at,
            updated_at,
            user_profiles!creator_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count,
              following_count
            )
          ''')
          .eq('type', 'video')
          .eq('is_public', true)
          .gte('view_count', 1000)
          .order('view_count', ascending: false)
          .limit(limit);

      // Process the response similar to getFeedContent
      final processedResponse = response.map((item) {
        final Map<String, dynamic> processedItem = Map.from(item);

        // Flatten user_profiles data for easier access
        if (processedItem['user_profiles'] != null) {
          final userProfile =
              processedItem['user_profiles'] as Map<String, dynamic>;
          processedItem['creator'] = userProfile;
          processedItem['creator_id'] = userProfile['id'];
          processedItem['creator_username'] = userProfile['username'];
          processedItem['creator_full_name'] = userProfile['full_name'];
          processedItem['creator_avatar_url'] = userProfile['avatar_url'];
          processedItem['creator_verified'] = userProfile['verified'] ?? false;
          processedItem['creator_clout_score'] =
              userProfile['clout_score'] ?? 0;
          processedItem['creator_followers_count'] =
              userProfile['followers_count'] ?? 0;
          processedItem['creator_following_count'] =
              userProfile['following_count'] ?? 0;
        }

        // Ensure required fields have default values
        processedItem['view_count'] = processedItem['view_count'] ?? 0;
        processedItem['like_count'] = processedItem['like_count'] ?? 0;
        processedItem['comment_count'] = processedItem['comment_count'] ?? 0;
        processedItem['share_count'] = processedItem['share_count'] ?? 0;
        processedItem['tip_count'] = processedItem['tip_count'] ?? 0;
        processedItem['total_tips_amount'] =
            processedItem['total_tips_amount'] ?? 0.0;
        processedItem['tags'] = processedItem['tags'] ?? [];

        // Provide fallback content for missing media
        if (processedItem['video_url'] == null ||
            processedItem['video_url'].toString().isEmpty) {
          processedItem['video_url'] =
              'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
        }

        if (processedItem['thumbnail_url'] == null ||
            processedItem['thumbnail_url'].toString().isEmpty) {
          processedItem['thumbnail_url'] =
              'https://picsum.photos/400/600?random=${processedItem['id'].hashCode}';
        }

        if (processedItem['creator_avatar_url'] == null ||
            processedItem['creator_avatar_url'].toString().isEmpty) {
          processedItem['creator_avatar_url'] =
              'https://ui-avatars.com/api/?name=${processedItem['creator_username'] ?? 'User'}&background=random&size=150';
        }

        return processedItem;
      }).toList();

      return processedResponse;
    } catch (error) {
      print('Error fetching viral content: $error');
      throw Exception('Failed to fetch viral content: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getContentComments(
      String contentId) async {
    try {
      final response = await _client
          .from('comments')
          .select('''
            id,
            content_id,
            user_id,
            text_content,
            created_at,
            updated_at,
            parent_comment_id,
            user_profiles!user_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score
            )
          ''')
          .eq('content_id', contentId)
          .isFilter('parent_comment_id', null)
          .order('created_at', ascending: false);

      return response.map((comment) {
        final Map<String, dynamic> processedComment = Map.from(comment);

        // Flatten user_profiles data
        if (processedComment['user_profiles'] != null) {
          final userProfile =
              processedComment['user_profiles'] as Map<String, dynamic>;
          processedComment['user'] = userProfile;
          processedComment['username'] = userProfile['username'];
          processedComment['full_name'] = userProfile['full_name'];
          processedComment['avatar_url'] = userProfile['avatar_url'] ??
              'https://ui-avatars.com/api/?name=${userProfile['username'] ?? 'User'}&background=random&size=150';
          processedComment['verified'] = userProfile['verified'] ?? false;
          processedComment['clout_score'] = userProfile['clout_score'] ?? 0;
        }

        return processedComment;
      }).toList();
    } catch (error) {
      print('Error fetching comments: $error');
      throw Exception('Failed to fetch comments: $error');
    }
  }

  Future<void> likeContent(String contentId, String userId) async {
    try {
      // Check if user already liked this content
      final existingLike = await _client
          .from('content_interactions')
          .select('id')
          .eq('user_id', userId)
          .eq('content_id', contentId)
          .eq('interaction_type', 'like')
          .maybeSingle();

      if (existingLike != null) {
        // Unlike the content
        await _client
            .from('content_interactions')
            .delete()
            .eq('user_id', userId)
            .eq('content_id', contentId)
            .eq('interaction_type', 'like');
      } else {
        // Like the content
        await _client.from('content_interactions').insert({
          'user_id': userId,
          'content_id': contentId,
          'interaction_type': 'like',
        });
      }
    } catch (error) {
      print('Error toggling like: $error');
      throw Exception('Failed to like content: $error');
    }
  }

  Future<void> unlikeContent(String contentId, String userId) async {
    try {
      await _client
          .from('content_interactions')
          .delete()
          .eq('user_id', userId)
          .eq('content_id', contentId)
          .eq('interaction_type', 'like');
    } catch (error) {
      print('Error unliking content: $error');
      throw Exception('Failed to unlike content: $error');
    }
  }

  Future<void> addComment(String contentId, String userId, String text) async {
    try {
      await _client.from('comments').insert({
        'content_id': contentId,
        'user_id': userId,
        'text_content': text,
      });
    } catch (error) {
      print('Error adding comment: $error');
      throw Exception('Failed to add comment: $error');
    }
  }

  Future<Map<String, dynamic>> getContentDetails(String contentId) async {
    try {
      final response = await _client.from('content').select('''
            id,
            title,
            description,
            video_url,
            thumbnail_url,
            audio_url,
            view_count,
            like_count,
            comment_count,
            share_count,
            tip_count,
            total_tips_amount,
            tags,
            location,
            type,
            is_public,
            allows_comments,
            allows_duets,
            featured,
            created_at,
            updated_at,
            user_profiles!creator_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count,
              following_count
            )
          ''').eq('id', contentId).single();

      // Process single content item
      if (response['user_profiles'] != null) {
        final userProfile = response['user_profiles'] as Map<String, dynamic>;
        response['creator'] = userProfile;
        response['creator_id'] = userProfile['id'];
        response['creator_username'] = userProfile['username'];
        response['creator_full_name'] = userProfile['full_name'];
        response['creator_avatar_url'] = userProfile['avatar_url'] ??
            'https://ui-avatars.com/api/?name=${userProfile['username'] ?? 'User'}&background=random&size=150';
        response['creator_verified'] = userProfile['verified'] ?? false;
        response['creator_clout_score'] = userProfile['clout_score'] ?? 0;
        response['creator_followers_count'] =
            userProfile['followers_count'] ?? 0;
        response['creator_following_count'] =
            userProfile['following_count'] ?? 0;
      }

      return response;
    } catch (error) {
      print('Error fetching content details: $error');
      throw Exception('Failed to fetch content details: $error');
    }
  }

  // User profile methods
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();
      return response;
    } catch (error) {
      print('Error fetching user profile: $error');
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getUserContent(String userId) async {
    try {
      final response = await _client
          .from('content')
          .select('*')
          .eq('creator_id', userId)
          .eq('is_public', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error fetching user content: $error');
      throw Exception('Failed to fetch user content: $error');
    }
  }

  Future<void> followUser(String followerId, String followingId) async {
    try {
      await _client.from('user_relationships').insert({
        'follower_id': followerId,
        'following_id': followingId,
        'type': 'following',
      });
    } catch (error) {
      print('Error following user: $error');
      throw Exception('Failed to follow user: $error');
    }
  }

  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      await _client
          .from('user_relationships')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
    } catch (error) {
      print('Error unfollowing user: $error');
      throw Exception('Failed to unfollow user: $error');
    }
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final response = await _client
          .from('user_relationships')
          .select('id')
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
      return response.isNotEmpty;
    } catch (error) {
      print('Error checking follow status: $error');
      return false;
    }
  }

  // Wallet methods
  Future<Map<String, dynamic>> getUserWallet(String userId) async {
    try {
      final response = await _client
          .from('wallets')
          .select('*')
          .eq('user_id', userId)
          .single();
      return response;
    } catch (error) {
      print('Error fetching wallet: $error');
      throw Exception('Failed to fetch wallet: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getWalletTransactions(
      String userId) async {
    try {
      final response = await _client
          .from('wallet_transactions')
          .select('''
            *,
            from_user:user_profiles!from_user_id (username, full_name, avatar_url),
            to_user:user_profiles!to_user_id (username, full_name, avatar_url)
          ''')
          .or('from_user_id.eq.$userId,to_user_id.eq.$userId')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print('Error fetching transactions: $error');
      throw Exception('Failed to fetch transactions: $error');
    }
  }

  Future<void> sendTip(String fromUserId, String toUserId, double amount,
      String contentId) async {
    try {
      final wallet = await getUserWallet(fromUserId);
      await _client.from('wallet_transactions').insert({
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'wallet_id': wallet['id'],
        'amount': amount,
        'currency': 'tam_token',
        'transaction_type': 'tip',
        'status': 'completed',
        'metadata': {'content_id': contentId},
      });
    } catch (error) {
      print('Error sending tip: $error');
      throw Exception('Failed to send tip: $error');
    }
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToContent() {
    return _client
        .channel('public:content')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'content',
          callback: (payload) {
            // Handle real-time content updates
            print('Content update: ${payload.eventType}');
          },
        )
        .subscribe();
  }

  RealtimeChannel subscribeToComments(String contentId) {
    return _client
        .channel('comments:$contentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'content_id',
            value: contentId,
          ),
          callback: (payload) {
            // Handle new comments
            print('New comment on content $contentId');
          },
        )
        .subscribe();
  }

  void dispose() {
    _client.dispose();
  }
}
