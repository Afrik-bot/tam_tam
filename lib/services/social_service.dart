import '../models/user_profile.dart';
import '../models/content.dart';
import '../models/notification.dart';
import './supabase_service.dart';

class SocialService {
  static final _supabase = SupabaseService.instance;

  static Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  static Future<UserProfile?> getCurrentUserProfile() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) return null;

    try {
      return await getUserProfile(userId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Content>> getUserContent(String userId) async {
    try {
      final response = await _supabase.client
          .from('content')
          .select('''
            *,
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
          .eq('creator_id', userId)
          .eq('is_public', true)
          .order('created_at', ascending: false);

      return response.map<Content>((json) => Content.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load user content: $e');
    }
  }

  static Future<void> followUser(String userId) async {
    final currentUserId = _supabase.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _supabase.client.from('user_relationships').insert({
        'follower_id': currentUserId,
        'following_id': userId,
        'type': 'following',
      });
    } catch (e) {
      throw Exception('Failed to follow user: $e');
    }
  }

  static Future<void> unfollowUser(String userId) async {
    final currentUserId = _supabase.currentUser?.id;
    if (currentUserId == null) throw Exception('User not authenticated');

    try {
      await _supabase.client
          .from('user_relationships')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', userId);
    } catch (e) {
      throw Exception('Failed to unfollow user: $e');
    }
  }

  static Future<bool> isFollowing(String userId) async {
    final currentUserId = _supabase.currentUser?.id;
    if (currentUserId == null) return false;

    try {
      final response = await _supabase.client
          .from('user_relationships')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .eq('type', 'following');

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<List<UserProfile>> getFollowers(String userId) async {
    try {
      final response = await _supabase.client
          .from('user_relationships')
          .select('''
            user_profiles!follower_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count,
              following_count,
              email,
              bio,
              cover_image_url,
              country_code,
              language_preference,
              role,
              is_active,
              total_tips_received,
              created_at,
              updated_at
            )
          ''')
          .eq('following_id', userId)
          .eq('type', 'following')
          .order('created_at', ascending: false);

      return response
          .map<UserProfile>((item) => UserProfile.fromJson(
              item['user_profiles'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load followers: $e');
    }
  }

  static Future<List<UserProfile>> getFollowing(String userId) async {
    try {
      final response = await _supabase.client
          .from('user_relationships')
          .select('''
            user_profiles!following_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count,
              following_count,
              email,
              bio,
              cover_image_url,
              country_code,
              language_preference,
              role,
              is_active,
              total_tips_received,
              created_at,
              updated_at
            )
          ''')
          .eq('follower_id', userId)
          .eq('type', 'following')
          .order('created_at', ascending: false);

      return response
          .map<UserProfile>((item) => UserProfile.fromJson(
              item['user_profiles'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load following: $e');
    }
  }

  static Future<List<NotificationModel>> getNotifications() async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final response = await _supabase.client
          .from('notifications')
          .select('''
            *,
            sender:user_profiles!sender_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count,
              following_count,
              email,
              bio,
              cover_image_url,
              country_code,
              language_preference,
              role,
              is_active,
              total_tips_received,
              created_at,
              updated_at
            ),
            content:content!content_id (
              id,
              creator_id,
              type,
              title,
              description,
              video_url,
              thumbnail_url,
              audio_url,
              tags,
              location,
              is_public,
              allows_comments,
              allows_duets,
              featured,
              view_count,
              like_count,
              comment_count,
              share_count,
              tip_count,
              total_tips_amount,
              created_at,
              updated_at
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return response
          .map<NotificationModel>((json) => NotificationModel.fromJson(json))
          .toList();
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
          .eq('read', false)
          .count();

      return response.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<List<UserProfile>> getTrendingUsers() async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .select('*')
          .eq('is_active', true)
          .order('clout_score', ascending: false)
          .limit(20);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load trending users: $e');
    }
  }

  static Future<List<UserProfile>> searchUsers(String query) async {
    try {
      final response = await _supabase.client
          .from('user_profiles')
          .select('*')
          .or('username.ilike.%$query%,full_name.ilike.%$query%')
          .eq('is_active', true)
          .order('followers_count', ascending: false)
          .limit(20);

      return response
          .map<UserProfile>((json) => UserProfile.fromJson(json))
          .toList();
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
