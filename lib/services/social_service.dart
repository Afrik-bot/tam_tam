import './supabase_service.dart';

class SocialService {
  static final _supabase = SupabaseService.instance;

  // Remove all mock data and use real Supabase data
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      return await _supabase.getUserProfile(userId);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return null;

    try {
      return await _supabase.getUserProfile(userId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserContent(
      String userId) async {
    try {
      return await _supabase.getUserContent(userId);
    } catch (e) {
      throw Exception('Failed to load user content: $e');
    }
  }

  static Future<void> followUser(String userId) async {
    final currentUserId = _supabase.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _supabase.followUser(currentUserId, userId);
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  static Future<void> unfollowUser(String userId) async {
    final currentUserId = _supabase.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _supabase.unfollowUser(currentUserId, userId);
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  static Future<bool> isFollowing(String userId) async {
    final currentUserId = _supabase.currentUser?.id;
    if (currentUserId == null) return false;

    try {
      return await _supabase.isFollowing(currentUserId, userId);
    } catch (e) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      final response = await _supabase.client
          .from('user_relationships')
          .select('''
            follower:user_profiles!follower_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count
            )
          ''')
          .eq('following_id', userId)
          .eq('type', 'following')
          .order('created_at', ascending: false);

      return response
          .map<Map<String, dynamic>>((item) => item['follower'])
          .toList();
    } catch (e) {
      throw Exception('Failed to load followers: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      final response = await _supabase.client
          .from('user_relationships')
          .select('''
            following:user_profiles!following_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count
            )
          ''')
          .eq('follower_id', userId)
          .eq('type', 'following')
          .order('created_at', ascending: false);

      return response
          .map<Map<String, dynamic>>((item) => item['following'])
          .toList();
    } catch (e) {
      throw Exception('Failed to load following: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final response = await _supabase.client
          .from('notifications')
          .select('''
            *,
            sender:user_profiles!sender_id (username, full_name, avatar_url, verified),
            content:content!content_id (id, title, thumbnail_url)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase.client
          .from('notifications')
          .update({'read': true}).eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  static Future<int> getUnreadNotificationCount() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return 0;

    try {
      final response = await _supabase.client
          .from('notifications')
          .select('*')
          .eq('user_id', userId)
          .eq('read', false);

      return response.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<List<Map<String, dynamic>>> getTrendingUsers() async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .select('*')
          .eq('is_active', true)
          .order('clout_score', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load trending users: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .select('*')
          .or('username.ilike.%$query%,full_name.ilike.%$query%')
          .eq('is_active', true)
          .order('followers_count', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  static Future<void> updateUserProfile({
    String? bio,
    String? avatarUrl,
    String? coverImageUrl,
  }) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final updateData = <String, dynamic>{};
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      if (coverImageUrl != null) updateData['cover_image_url'] = coverImageUrl;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.client
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  static Future<void> blockUser(String userId) async {
    final currentUserId = _supabase.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _supabase.client.from('user_relationships').upsert({
        'follower_id': currentUserId,
        'following_id': userId,
        'type': 'blocked',
      });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  static Future<void> reportUser(String userId, String reason) async {
    final currentUserId = _supabase.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _supabase.client.from('notifications').insert({
        'user_id': currentUserId,
        'sender_id': userId,
        'type': 'system',
        'title': 'User Reported',
        'message': 'User has been reported for: $reason',
        'data': {'reported_user_id': userId, 'reason': reason},
      });
    } catch (e) {
      throw Exception('Failed to report user: $e');
    }
  }
}