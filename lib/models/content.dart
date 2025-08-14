import './user_profile.dart';

enum ContentType { video, image, text, live_stream }

class Content {
  final String id;
  final String creatorId;
  final ContentType type;
  final String? title;
  final String? description;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? audioUrl;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int tipCount;
  final double totalTipsAmount;
  final List<String> tags;
  final String? location;
  final bool isPublic;
  final bool allowsComments;
  final bool allowsDuets;
  final bool featured;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserProfile? creator;

  Content({
    required this.id,
    required this.creatorId,
    required this.type,
    this.title,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
    this.audioUrl,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.tipCount,
    required this.totalTipsAmount,
    required this.tags,
    this.location,
    required this.isPublic,
    required this.allowsComments,
    required this.allowsDuets,
    required this.featured,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
  });

  // Fallback URLs for missing content
  String get videoUrlWithFallback => videoUrl?.isNotEmpty == true
      ? videoUrl!
      : 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';

  String get thumbnailUrlWithFallback => thumbnailUrl?.isNotEmpty == true
      ? thumbnailUrl!
      : 'https://picsum.photos/400/600?random=${id.hashCode}';

  String get audioUrlWithFallback =>
      audioUrl?.isNotEmpty == true ? audioUrl! : '';

  // Utility getters for display
  String get displayTitle => title?.isNotEmpty == true ? title! : 'Untitled';
  String get displayDescription => description?.isNotEmpty == true
      ? description!
      : 'No description available';

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      type: _parseContentType(json['type'] as String),
      title: json['title'] as String?,
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      tipCount: json['tip_count'] as int? ?? 0,
      totalTipsAmount: (json['total_tips_amount'] as num?)?.toDouble() ?? 0.0,
      tags: _parseTags(json['tags']),
      location: json['location'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      allowsComments: json['allows_comments'] as bool? ?? true,
      allowsDuets: json['allows_duets'] as bool? ?? true,
      featured: json['featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      creator: json['user_profiles'] != null
          ? UserProfile.fromJson(json['user_profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  static ContentType _parseContentType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return ContentType.video;
      case 'image':
        return ContentType.image;
      case 'text':
        return ContentType.text;
      case 'live_stream':
        return ContentType.live_stream;
      default:
        return ContentType.video;
    }
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    if (tags is List) {
      return tags.map((tag) => tag.toString()).toList();
    }
    if (tags is String) {
      try {
        // Try to parse as JSON array
        final decoded = tags.replaceAll('[', '').replaceAll(']', '').split(',');
        return decoded
            .map((tag) => tag.trim().replaceAll('"', ''))
            .where((tag) => tag.isNotEmpty)
            .toList();
      } catch (e) {
        return [tags];
      }
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'audio_url': audioUrl,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'tip_count': tipCount,
      'total_tips_amount': totalTipsAmount,
      'tags': tags,
      'location': location,
      'is_public': isPublic,
      'allows_comments': allowsComments,
      'allows_duets': allowsDuets,
      'featured': featured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_profiles': creator?.toJson(),
    };
  }

  Content copyWith({
    String? id,
    String? creatorId,
    ContentType? type,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    String? audioUrl,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? tipCount,
    double? totalTipsAmount,
    List<String>? tags,
    String? location,
    bool? isPublic,
    bool? allowsComments,
    bool? allowsDuets,
    bool? featured,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserProfile? creator,
  }) {
    return Content(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      tipCount: tipCount ?? this.tipCount,
      totalTipsAmount: totalTipsAmount ?? this.totalTipsAmount,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      isPublic: isPublic ?? this.isPublic,
      allowsComments: allowsComments ?? this.allowsComments,
      allowsDuets: allowsDuets ?? this.allowsDuets,
      featured: featured ?? this.featured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creator: creator ?? this.creator,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Content && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
