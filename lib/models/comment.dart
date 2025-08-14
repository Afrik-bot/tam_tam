import './user_profile.dart';

class Comment {
  final String id;
  final String contentId;
  final String userId;
  final String textContent;
  final int likeCount;
  final String? parentCommentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? user;

  Comment({
    required this.id,
    required this.contentId,
    required this.userId,
    required this.textContent,
    required this.likeCount,
    this.parentCommentId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  // Helper method to display relative time
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      contentId: json['content_id'] as String,
      userId: json['user_id'] as String,
      textContent: json['text_content'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      parentCommentId: json['parent_comment_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user_profiles'] != null
          ? UserProfile.fromJson(json['user_profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content_id': contentId,
      'user_id': userId,
      'text_content': textContent,
      'like_count': likeCount,
      'parent_comment_id': parentCommentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_profiles': user?.toJson(),
    };
  }

  Comment copyWith({
    String? id,
    String? contentId,
    String? userId,
    String? textContent,
    int? likeCount,
    String? parentCommentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? user,
  }) {
    return Comment(
      id: id ?? this.id,
      contentId: contentId ?? this.contentId,
      userId: userId ?? this.userId,
      textContent: textContent ?? this.textContent,
      likeCount: likeCount ?? this.likeCount,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
