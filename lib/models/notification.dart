import './content.dart';
import './user_profile.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String? senderId;
  final String? contentId;
  final NotificationType type;
  final String title;
  final String? message;
  final Map<String, dynamic> data;
  final bool read;
  final DateTime createdAt;
  final UserProfile? sender;
  final Content? content;

  NotificationModel({
    required this.id,
    required this.userId,
    this.senderId,
    this.contentId,
    required this.type,
    required this.title,
    this.message,
    this.data = const {},
    this.read = false,
    required this.createdAt,
    this.sender,
    this.content,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    UserProfile? sender;
    Content? content;

    if (json['sender'] != null) {
      sender = UserProfile.fromJson(json['sender'] as Map<String, dynamic>);
    }

    if (json['content'] != null) {
      content = Content.fromJson(json['content'] as Map<String, dynamic>);
    }

    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      senderId: json['sender_id'] as String?,
      contentId: json['content_id'] as String?,
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.system,
      ),
      title: json['title'] as String,
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? {},
      read: json['read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      sender: sender,
      content: content,
    );
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

  String get iconName {
    switch (type) {
      case NotificationType.like:
        return 'favorite';
      case NotificationType.comment:
        return 'chat_bubble';
      case NotificationType.follow:
        return 'person_add';
      case NotificationType.tip:
        return 'attach_money';
      case NotificationType.mention:
        return 'alternate_email';
      case NotificationType.system:
        return 'info';
    }
  }
}

enum NotificationType {
  like,
  comment,
  follow,
  tip,
  mention,
  system,
}
