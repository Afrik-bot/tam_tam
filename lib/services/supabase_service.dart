import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  late final SupabaseClient _client;
  SupabaseClient get client => _client;

  Future<void> initialize() async {
    // Load environment configuration
    String configContent;

    if (kIsWeb) {
      // For web, you might need to handle this differently
      configContent =
          '{"SUPABASE_URL": "your_supabase_url", "SUPABASE_ANON_KEY": "your_supabase_anon_key"}';
    } else {
      try {
        final file = File('env.json');
        configContent = await file.readAsString();
      } catch (e) {
        // Fallback configuration
        configContent =
            '{"SUPABASE_URL": "your_supabase_url", "SUPABASE_ANON_KEY": "your_supabase_anon_key"}';
      }
    }

    final config = json.decode(configContent) as Map<String, dynamic>;
    final supabaseUrl = config['SUPABASE_URL'] as String;
    final supabaseAnonKey = config['SUPABASE_ANON_KEY'] as String;

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  // Authentication methods
  Future<AuthResponse> signUp(String email, String password,
      {String? username}) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Content methods
  Future<List<Map<String, dynamic>>> getViralContent({int limit = 10}) async {
    try {
      final response = await _client
          .from('content')
          .select('''
            *,
            user_profiles!creator_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score
            )
          ''')
          .eq('is_public', true)
          .order('view_count', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch viral content: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getFeedContent({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('content')
          .select('''
            *,
            user_profiles!creator_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score
            )
          ''')
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch feed content: $error');
    }
  }

  Future<Map<String, dynamic>> getContentById(String contentId) async {
    try {
      final response = await _client.from('content').select('''
            *,
            user_profiles!creator_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count
            )
          ''').eq('id', contentId).single();
      return response;
    } catch (error) {
      throw Exception('Failed to fetch content: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getContentComments(
      String contentId) async {
    try {
      final response = await _client
          .from('comments')
          .select('''
            *,
            user_profiles!user_id (
              id,
              username,
              full_name,
              avatar_url,
              verified
            )
          ''')
          .eq('content_id', contentId)
          .isFilter('parent_comment_id', null)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch comments: $error');
    }
  }

  Future<void> likeContent(String contentId, String userId) async {
    try {
      await _client.from('content_interactions').upsert({
        'user_id': userId,
        'content_id': contentId,
        'interaction_type': 'like',
      });
    } catch (error) {
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
      throw Exception('Failed to add comment: $error');
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
