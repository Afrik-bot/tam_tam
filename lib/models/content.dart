import './user_profile.dart';

class Content {
  final String id;
  final String creatorId;
  final ContentType type;
  final String? title;
  final String? description;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? audioUrl;
  final List<String> tags;
  final String? location;
  final bool isPublic;
  final bool allowsComments;
  final bool allowsDuets;
  final bool featured;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int tipCount;
  final double totalTipsAmount;
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
    this.tags = const [],
    this.location,
    this.isPublic = true,
    this.allowsComments = true,
    this.allowsDuets = true,
    this.featured = false,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.tipCount = 0,
    this.totalTipsAmount = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    final List<dynamic> tagsJson = json['tags'] as List<dynamic>? ?? [];
    final List<String> tags = tagsJson.map((e) => e.toString()).toList();

    UserProfile? creator;
    if (json['user_profiles'] != null || json['creator'] != null) {
      final creatorJson = json['user_profiles'] ?? json['creator'];
      creator = UserProfile.fromJson(creatorJson as Map<String, dynamic>);
    }

    return Content(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      type: ContentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => ContentType.video,
      ),
      title: json['title'] as String?,
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      tags: tags,
      location: json['location'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      allowsComments: json['allows_comments'] as bool? ?? true,
      allowsDuets: json['allows_duets'] as bool? ?? true,
      featured: json['featured'] as bool? ?? false,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      tipCount: json['tip_count'] as int? ?? 0,
      totalTipsAmount: (json['total_tips_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      creator: creator,
    );
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
      'tags': tags,
      'location': location,
      'is_public': isPublic,
      'allows_comments': allowsComments,
      'allows_duets': allowsDuets,
      'featured': featured,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'tip_count': tipCount,
      'total_tips_amount': totalTipsAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get videoUrlWithFallback =>
      videoUrl ??
      'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';

  String get thumbnailUrlWithFallback =>
      thumbnailUrl ?? 'https://picsum.photos/400/600?random=${id.hashCode}';

  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }

  Content copyWith({
    String? title,
    String? description,
    List<String>? tags,
    String? location,
    bool? isPublic,
    bool? allowsComments,
    bool? allowsDuets,
    bool? featured,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? tipCount,
    double? totalTipsAmount,
  }) {
    return Content(
      id: id,
      creatorId: creatorId,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      audioUrl: audioUrl,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      isPublic: isPublic ?? this.isPublic,
      allowsComments: allowsComments ?? this.allowsComments,
      allowsDuets: allowsDuets ?? this.allowsDuets,
      featured: featured ?? this.featured,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      tipCount: tipCount ?? this.tipCount,
      totalTipsAmount: totalTipsAmount ?? this.totalTipsAmount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      creator: creator,
    );
  }
}

enum ContentType {
  video,
  image,
  text,
  liveStream,
}
