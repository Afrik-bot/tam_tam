import 'package:flutter/foundation.dart';

import './supabase_service.dart';

class ContentService {
  static ContentService? _instance;
  static ContentService get instance => _instance ??= ContentService._();

  ContentService._();

  // Get live streaming content with real-time data
  Future<List<Map<String, dynamic>>> getLiveStreamContent({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('content')
          .select('''
            id,
            title,
            description,
            video_url,
            thumbnail_url,
            view_count,
            like_count,
            comment_count,
            created_at,
            type,
            user_profiles!creator_id (
              id,
              username,
              full_name,
              avatar_url,
              verified,
              clout_score,
              followers_count
            )
          ''')
          .eq('type', 'live_stream')
          .eq('is_public', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Process and add fallback data
      return response.map((item) {
        final Map<String, dynamic> processedItem = Map.from(item);

        // Handle user profile data
        if (processedItem['user_profiles'] != null) {
          final userProfile =
              processedItem['user_profiles'] as Map<String, dynamic>;
          processedItem['creator'] = userProfile;
          processedItem['creator_username'] =
              userProfile['username'] ?? 'Unknown';
          processedItem['creator_full_name'] =
              userProfile['full_name'] ?? 'Unknown User';
          processedItem['creator_avatar_url'] = userProfile['avatar_url'] ??
              'https://ui-avatars.com/api/?name=${userProfile['username'] ?? 'User'}&background=random&size=150';
          processedItem['creator_verified'] = userProfile['verified'] ?? false;
          processedItem['creator_followers_count'] =
              userProfile['followers_count'] ?? 0;
        }

        // Ensure required fields have default values
        processedItem['view_count'] = processedItem['view_count'] ?? 0;
        processedItem['like_count'] = processedItem['like_count'] ?? 0;
        processedItem['comment_count'] = processedItem['comment_count'] ?? 0;

        return processedItem;
      }).toList();
    } catch (error) {
      debugPrint('Error fetching live stream content: $error');

      // Return fallback mock data for development/preview
      return _getFallbackLiveStreamData();
    }
  }

  // Get live stream comments
  Future<List<Map<String, dynamic>>> getLiveStreamComments(
    String? contentId, {
    int limit = 50,
  }) async {
    try {
      if (contentId == null) {
        return _getFallbackComments();
      }

      final client = SupabaseService.instance.client;

      final response = await client
          .from('comments')
          .select('''
            id,
            text_content,
            created_at,
            user_profiles!user_id (
              id,
              username,
              full_name,
              avatar_url,
              verified
            )
          ''')
          .eq('content_id', contentId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((comment) {
        final Map<String, dynamic> processedComment = Map.from(comment);

        if (processedComment['user_profiles'] != null) {
          final userProfile =
              processedComment['user_profiles'] as Map<String, dynamic>;
          processedComment['username'] = userProfile['username'] ?? 'Anonymous';
          processedComment['full_name'] =
              userProfile['full_name'] ?? 'Unknown User';
          processedComment['avatar'] = userProfile['avatar_url'] ??
              'https://ui-avatars.com/api/?name=${userProfile['username'] ?? 'User'}&background=random&size=150';
          processedComment['verified'] = userProfile['verified'] ?? false;
        }

        processedComment['message'] = processedComment['text_content'] ?? '';
        processedComment['type'] = 'comment';
        processedComment['timestamp'] =
            DateTime.parse(processedComment['created_at']);

        return processedComment;
      }).toList();
    } catch (error) {
      debugPrint('Error fetching comments: $error');
      return _getFallbackComments();
    }
  }

  // Add comment to live stream
  Future<void> addLiveStreamComment(String? contentId, String message) async {
    try {
      if (contentId == null) {
        debugPrint('Cannot add comment: content ID is null');
        return;
      }

      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        debugPrint('Cannot add comment: user not authenticated');
        return;
      }

      await client.from('comments').insert({
        'content_id': contentId,
        'user_id': user.id,
        'text_content': message,
      });
    } catch (error) {
      debugPrint('Error adding comment: $error');
      // In development mode, we'll just log the error and continue
    }
  }

  // Get active live battles
  Future<List<Map<String, dynamic>>> getActiveBattles({int limit = 10}) async {
    try {
      final client = SupabaseService.instance.client;

      final response = await client
          .from('live_battles')
          .select('''
            id,
            title,
            description,
            creator1_tips,
            creator2_tips,
            total_tips,
            started_at,
            user_profiles!creator1_id (
              id,
              username,
              full_name,
              avatar_url
            ),
            creator2:user_profiles!creator2_id (
              id,
              username,
              full_name,
              avatar_url
            )
          ''')
          .eq('status', 'active')
          .order('started_at', ascending: false)
          .limit(limit);

      return response.map((battle) {
        final Map<String, dynamic> processedBattle = Map.from(battle);

        // Process creator1 data
        if (processedBattle['user_profiles'] != null) {
          final creator1 =
              processedBattle['user_profiles'] as Map<String, dynamic>;
          processedBattle['creator1'] = {
            'name': creator1['username'] ?? 'Creator1',
            'avatar': creator1['avatar_url'] ??
                'https://ui-avatars.com/api/?name=${creator1['username'] ?? 'Creator1'}&background=random&size=150',
            'score':
                ((processedBattle['creator1_tips'] ?? 0.0) as num).toDouble(),
          };
        }

        // Process creator2 data
        if (processedBattle['creator2'] != null) {
          final creator2 = processedBattle['creator2'] as Map<String, dynamic>;
          processedBattle['creator2'] = {
            'name': creator2['username'] ?? 'Creator2',
            'avatar': creator2['avatar_url'] ??
                'https://ui-avatars.com/api/?name=${creator2['username'] ?? 'Creator2'}&background=random&size=150',
            'score':
                ((processedBattle['creator2_tips'] ?? 0.0) as num).toDouble(),
          };
        }

        processedBattle['tipPool'] =
            ((processedBattle['total_tips'] ?? 0.0) as num).toDouble();

        // Calculate time remaining (assuming 5 minute battles for demo)
        final startTime = DateTime.parse(processedBattle['started_at']);
        final elapsed = DateTime.now().difference(startTime);
        final remaining = Duration(minutes: 5) - elapsed;
        final minutes = remaining.inMinutes.clamp(0, 5);
        final seconds = (remaining.inSeconds % 60).clamp(0, 59);
        processedBattle['timeRemaining'] =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

        return processedBattle;
      }).toList();
    } catch (error) {
      debugPrint('Error fetching battles: $error');
      return _getFallbackBattleData();
    }
  }

  // Like/unlike content
  Future<void> toggleContentLike(String? contentId) async {
    try {
      if (contentId == null) return;

      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        debugPrint('Cannot like content: user not authenticated');
        return;
      }

      // Check if already liked
      final existingLike = await client
          .from('content_interactions')
          .select('id')
          .eq('user_id', user.id)
          .eq('content_id', contentId)
          .eq('interaction_type', 'like')
          .maybeSingle();

      if (existingLike != null) {
        // Unlike
        await client
            .from('content_interactions')
            .delete()
            .eq('user_id', user.id)
            .eq('content_id', contentId)
            .eq('interaction_type', 'like');
      } else {
        // Like
        await client.from('content_interactions').insert({
          'user_id': user.id,
          'content_id': contentId,
          'interaction_type': 'like',
        });
      }
    } catch (error) {
      debugPrint('Error toggling like: $error');
    }
  }

  // Fallback data for development/preview mode
  List<Map<String, dynamic>> _getFallbackLiveStreamData() {
    return [
      {
        "id": "demo-live-1",
        "title": "Live Gaming Session",
        "description": "Playing the latest games with viewers!",
        "video_url":
            "https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4",
        "thumbnail_url": "https://picsum.photos/400/600?random=1",
        "view_count": 1247,
        "like_count": 234,
        "comment_count": 89,
        "creator_username": "GameMaster_Pro",
        "creator_full_name": "Alex Gaming",
        "creator_avatar_url":
            "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=150",
        "creator_verified": true,
        "creator_followers_count": 12500,
        "type": "live_stream",
        "created_at": DateTime.now().toIso8601String(),
      }
    ];
  }

  List<Map<String, dynamic>> _getFallbackComments() {
    return [
      {
        "id": "comment-1",
        "username": "Sarah_K",
        "full_name": "Sarah Kim",
        "avatar":
            "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=150",
        "message": "Amazing stream! Love the energy! 🔥",
        "type": "comment",
        "verified": false,
        "timestamp": DateTime.now().subtract(Duration(minutes: 2)),
      },
      {
        "id": "comment-2",
        "username": "Mike_Crypto",
        "full_name": "Mike Johnson",
        "avatar":
            "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=150",
        "message": "Just sent you 50 Tam Tokens! Keep it up!",
        "type": "tip",
        "amount": "\$25.00",
        "verified": true,
        "timestamp": DateTime.now().subtract(Duration(minutes: 1)),
      },
      {
        "id": "comment-3",
        "username": "Luna_Star",
        "full_name": "Luna Star",
        "avatar":
            "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=150",
        "message": "Can you show that product again?",
        "type": "comment",
        "verified": false,
        "timestamp": DateTime.now().subtract(Duration(seconds: 30)),
      },
    ];
  }

  List<Map<String, dynamic>> _getFallbackBattleData() {
    return [
      {
        "creator1": {
          "name": "Alex_Creator",
          "avatar":
              "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=150",
          "score": 75.0,
        },
        "creator2": {
          "name": "Jordan_Live",
          "avatar":
              "https://images.pexels.com/photos/1674752/pexels-photo-1674752.jpeg?auto=compress&cs=tinysrgb&w=150",
          "score": 68.0,
        },
        "tipPool": 450.75,
        "timeRemaining": "02:45",
      }
    ];
  }

  // Real-time subscription for live stream comments
  Stream<List<Map<String, dynamic>>> subscribeToLiveComments(
      String? contentId) {
    if (contentId == null) {
      return Stream.value(_getFallbackComments());
    }

    try {
      final client = SupabaseService.instance.client;

      return client
          .from('comments')
          .stream(primaryKey: ['id'])
          .eq('content_id', contentId)
          .order('created_at')
          .map((data) => data.map((comment) {
                final Map<String, dynamic> processedComment = Map.from(comment);
                processedComment['message'] =
                    processedComment['text_content'] ?? '';
                processedComment['type'] = 'comment';
                processedComment['timestamp'] =
                    DateTime.parse(processedComment['created_at']);
                return processedComment;
              }).toList());
    } catch (error) {
      debugPrint('Error subscribing to comments: $error');
      return Stream.value(_getFallbackComments());
    }
  }

  // Static method for getting feed content
  static Future<List<Map<String, dynamic>>> getFeedContent(
      {int limit = 20, int offset = 0}) async {
    return await instance.getLiveStreamContent(limit: limit, offset: offset);
  }

  // Static method for reporting content
  static Future<void> reportContent(String contentId, String reason) async {
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        debugPrint('Cannot report content: user not authenticated');
        return;
      }

      await client.from('content_reports').insert({
        'content_id': contentId,
        'user_id': user.id,
        'reason': reason,
        'status': 'pending',
      });
    } catch (error) {
      debugPrint('Error reporting content: $error');
    }
  }

  // Static method for liking content
  static Future<void> likeContent(String contentId) async {
    await instance.toggleContentLike(contentId);
  }

  // Static method for getting content comments
  static Future<List<Map<String, dynamic>>> getContentComments(
      String contentId) async {
    return await instance.getLiveStreamComments(contentId);
  }

  // Static method for adding comments
  static Future<void> addComment(String contentId, String comment) async {
    await instance.addLiveStreamComment(contentId, comment);
  }

  // Static method for sharing content
  static Future<void> shareContent(String contentId) async {
    try {
      final client = SupabaseService.instance.client;
      final user = client.auth.currentUser;

      if (user == null) {
        debugPrint('Cannot share content: user not authenticated');
        return;
      }

      // Record the share interaction
      await client.from('content_interactions').insert({
        'user_id': user.id,
        'content_id': contentId,
        'interaction_type': 'share',
      });

      // Update share count
      await client.rpc('increment_content_shares', params: {
        'content_id_param': contentId,
      });
    } catch (error) {
      debugPrint('Error sharing content: $error');
    }
  }
}
