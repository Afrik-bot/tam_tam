import '../models/content.dart';
import '../models/comment.dart';
import './supabase_service.dart';

class ContentService {
  static final _supabase = SupabaseService.instance;

  static Future<List<Content>> getViralVideos() async {
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
          .eq('type', 'video')
          .eq('is_public', true)
          .gte('view_count', 1000)
          .order('view_count', ascending: false)
          .limit(20);

      return response.map<Content>((json) => Content.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load viral videos: $e');
    }
  }

  static Future<List<Content>> getFeedContent({
    int page = 0,
    int limit = 10,
  }) async {
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
          .eq('type', 'video')
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .range(page * limit, (page * limit) + limit - 1);

      final content =
          response.map<Content>((json) => Content.fromJson(json)).toList();

      if (content.isEmpty && page == 0) {
        throw Exception(
            'No videos available. Database might be empty or videos may be loading.');
      }

      return content;
    } catch (e) {
      if (e.toString().contains('No videos available')) {
        throw Exception('No videos found. Pull to refresh or try again later.');
      } else if (e.toString().contains('network')) {
        throw Exception('Network error. Check your internet connection.');
      } else {
        throw Exception('Failed to load videos: $e');
      }
    }
  }

  static Future<Content> getContentDetails(String contentId) async {
    try {
      final response = await _supabase.client.from('content').select('''
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
          ''').eq('id', contentId).single();

      return Content.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load content details: $e');
    }
  }

  static Future<List<Comment>> getContentComments(String contentId) async {
    try {
      final response = await _supabase.client
          .from('comments')
          .select('''
            *,
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

      return response.map<Comment>((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  static Future<void> likeContent(String contentId) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Check if user already liked this content
      final existingLike = await _supabase.client
          .from('content_interactions')
          .select('id')
          .eq('user_id', userId)
          .eq('content_id', contentId)
          .eq('interaction_type', 'like')
          .maybeSingle();

      if (existingLike != null) {
        // Unlike the content
        await _supabase.client
            .from('content_interactions')
            .delete()
            .eq('user_id', userId)
            .eq('content_id', contentId)
            .eq('interaction_type', 'like');
      } else {
        // Like the content
        await _supabase.client.from('content_interactions').insert({
          'user_id': userId,
          'content_id': contentId,
          'interaction_type': 'like',
        });
      }
    } catch (e) {
      throw Exception('Failed to like content: $e');
    }
  }

  static Future<void> unlikeContent(String contentId) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _supabase.client
          .from('content_interactions')
          .delete()
          .eq('user_id', userId)
          .eq('content_id', contentId)
          .eq('interaction_type', 'like');
    } catch (e) {
      throw Exception('Failed to unlike content: $e');
    }
  }

  static Future<void> addComment(String contentId, String commentText) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _supabase.client.from('comments').insert({
        'content_id': contentId,
        'user_id': userId,
        'text_content': commentText,
      });
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  static Future<void> shareContent(String contentId) async {
    try {
      final userId = _supabase.currentUser?.id;
      if (userId != null) {
        await _supabase.client.from('content_interactions').upsert({
          'user_id': userId,
          'content_id': contentId,
          'interaction_type': 'share',
        });
      }
    } catch (e) {
      throw Exception('Failed to share content: $e');
    }
  }

  static Future<List<Content>> getTrendingChallenges() async {
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
          .contains('tags', ['challenge'])
          .eq('is_public', true)
          .order('view_count', ascending: false)
          .limit(10);

      return response.map<Content>((json) => Content.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load trending challenges: $e');
    }
  }

  static Future<List<Content>> searchContent(String query) async {
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
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('is_public', true)
          .order('view_count', ascending: false)
          .limit(20);

      return response.map<Content>((json) => Content.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search content: $e');
    }
  }

  static Future<void> reportContent(String contentId, String reason) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _supabase.client.from('notifications').insert({
        'user_id': userId,
        'type': 'system',
        'title': 'Content Reported',
        'message': 'Content has been reported for: $reason',
        'data': {'content_id': contentId, 'reason': reason},
      });
    } catch (e) {
      throw Exception('Failed to report content: $e');
    }
  }

  // Helper method to convert Map<String, dynamic> to Content for backward compatibility
  static Content mapToContent(Map<String, dynamic> data) {
    return Content.fromJson(data);
  }

  // Helper method to convert Map<String, dynamic> to Comment for backward compatibility
  static Comment mapToComment(Map<String, dynamic> data) {
    return Comment.fromJson(data);
  }
}
