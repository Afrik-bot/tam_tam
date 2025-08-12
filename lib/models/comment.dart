import './user_profile.dart';

class Comment {
  final String id;
  final String contentId;
  final String userId;
  final String textContent;
  final String? parentCommentId;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? user;

  Comment({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.textContent,
    this.parentCommentId,
    this.likeCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    UserProfile? user;
    if (json['user_profiles'] != null || json['user'] != null) {
      final userJson = json['user_profiles'] ?? json['user'];
      user = UserProfile.fromJson(userJson as Map<String, dynamic>);
    }

    return Comment(
      id: json['id'] as String,
      contentId: json['content_id'] as String,
      userId: json['user_id'] as String,
      textContent: json['text_content'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'user_id': userId,
      'text_content': textContent,
      'parent_comment_id': parentCommentId,
      'like_count': likeCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}
