import './supabase_service.dart';

class ContentService {
  static final _supabase = SupabaseService.instance;

  // Remove mock data and use real Supabase data
  static Future<List<Map<String, dynamic>>> getViralVideos() async {
    try {
      return await _supabase.getViralContent(limit: 20);
    } catch (e) {
      throw Exception('Failed to load viral videos: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getFeedContent({
    int page = 0,
    int limit = 10,
  }) async {
    try {
      return await _supabase.getFeedContent(
        limit: limit,
        offset: page * limit,
      );
    } catch (e) {
      throw Exception('Failed to load feed content: $e');
    }
  }

  static Future<Map<String, dynamic>> getContentDetails(
      String contentId) async {
    try {
      return await _supabase.getContentById(contentId);
    } catch (e) {
      throw Exception('Failed to load content details: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getContentComments(
      String contentId) async {
    try {
      return await _supabase.getContentComments(contentId);
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  static Future<void> likeContent(String contentId) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _supabase.likeContent(contentId, userId);
    } catch (e) {
      throw Exception('Failed to like content: $e');
    }
  }

  static Future<void> unlikeContent(String contentId) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _supabase.unlikeContent(contentId, userId);
    } catch (e) {
      throw Exception('Failed to unlike content: $e');
    }
  }

  static Future<void> addComment(String contentId, String commentText) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _supabase.addComment(contentId, userId, commentText);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  static Future<void> shareContent(String contentId) async {
    // Implementation for sharing content
    try {
      // Add share interaction
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

  static Future<List<Map<String, dynamic>>> getTrendingChallenges() async {
    try {
      final response = await _supabase.client
          .from('content')
          .select('''
            *,
            user_profiles!creator_id (username, full_name, avatar_url, verified)
          ''')
          .contains('tags', ['challenge'])
          .eq('is_public', true)
          .order('view_count', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to load trending challenges: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> searchContent(String query) async {
    try {
      final response = await _supabase.client
          .from('content')
          .select('''
            *,
            user_profiles!creator_id (username, full_name, avatar_url, verified)
          ''')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .eq('is_public', true)
          .order('view_count', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search content: $e');
    }
  }

  static Future<void> reportContent(String contentId, String reason) async {
    final userId = _supabase.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Add content report (you might want to create a reports table)
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
}
