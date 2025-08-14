class UserProfile {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String? coverImageUrl;
  final bool verified;
  final bool isActive;
  final String role;
  final int followersCount;
  final int followingCount;
  final int cloutScore;
  final double totalTipsReceived;
  final String? countryCode;
  final String languagePreference;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    this.coverImageUrl,
    required this.verified,
    required this.isActive,
    required this.role,
    required this.followersCount,
    required this.followingCount,
    required this.cloutScore,
    required this.totalTipsReceived,
    this.countryCode,
    required this.languagePreference,
    required this.createdAt,
    required this.updatedAt,
  });

  // Fallback URL for avatar
  String get avatarUrlWithFallback => avatarUrl?.isNotEmpty == true
      ? avatarUrl!
      : 'https://ui-avatars.com/api/?name=${username}&background=random&size=150';

  // Fallback URL for cover image
  String get coverImageUrlWithFallback => coverImageUrl?.isNotEmpty == true
      ? coverImageUrl!
      : 'https://picsum.photos/800/300?random=${id.hashCode}';

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      verified: json['verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      role: json['role'] as String? ?? 'user',
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      cloutScore: json['clout_score'] as int? ?? 0,
      totalTipsReceived:
          (json['total_tips_received'] as num?)?.toDouble() ?? 0.0,
      countryCode: json['country_code'] as String?,
      languagePreference: json['language_preference'] as String? ?? 'en',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'cover_image_url': coverImageUrl,
      'verified': verified,
      'is_active': isActive,
      'role': role,
      'followers_count': followersCount,
      'following_count': followingCount,
      'clout_score': cloutScore,
      'total_tips_received': totalTipsReceived,
      'country_code': countryCode,
      'language_preference': languagePreference,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? coverImageUrl,
    bool? verified,
    bool? isActive,
    String? role,
    int? followersCount,
    int? followingCount,
    int? cloutScore,
    double? totalTipsReceived,
    String? countryCode,
    String? languagePreference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      verified: verified ?? this.verified,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      cloutScore: cloutScore ?? this.cloutScore,
      totalTipsReceived: totalTipsReceived ?? this.totalTipsReceived,
      countryCode: countryCode ?? this.countryCode,
      languagePreference: languagePreference ?? this.languagePreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum UserRole {
  user,
  creator,
  admin,
  moderator,
}
