class UserProfile {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String? countryCode;
  final String languagePreference;
  final UserRole role;
  final bool isActive;
  final bool verified;
  final int followersCount;
  final int followingCount;
  final int cloutScore;
  final double totalTipsReceived;
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
    this.countryCode,
    this.languagePreference = 'en',
    this.role = UserRole.user,
    this.isActive = true,
    this.verified = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.cloutScore = 0,
    this.totalTipsReceived = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      countryCode: json['country_code'] as String?,
      languagePreference: json['language_preference'] as String? ?? 'en',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.user,
      ),
      isActive: json['is_active'] as bool? ?? true,
      verified: json['verified'] as bool? ?? false,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      cloutScore: json['clout_score'] as int? ?? 0,
      totalTipsReceived:
          (json['total_tips_received'] as num?)?.toDouble() ?? 0.0,
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
      'country_code': countryCode,
      'language_preference': languagePreference,
      'role': role.toString().split('.').last,
      'is_active': isActive,
      'verified': verified,
      'followers_count': followersCount,
      'following_count': followingCount,
      'clout_score': cloutScore,
      'total_tips_received': totalTipsReceived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => fullName.isNotEmpty ? fullName : username;

  String get avatarUrlWithFallback =>
      avatarUrl ??
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=FF6B35&color=fff&size=150';

  UserProfile copyWith({
    String? bio,
    String? avatarUrl,
    String? coverImageUrl,
    String? countryCode,
    String? languagePreference,
    bool? verified,
    int? followersCount,
    int? followingCount,
    int? cloutScore,
    double? totalTipsReceived,
  }) {
    return UserProfile(
      id: id,
      email: email,
      username: username,
      fullName: fullName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      countryCode: countryCode ?? this.countryCode,
      languagePreference: languagePreference ?? this.languagePreference,
      role: role,
      isActive: isActive,
      verified: verified ?? this.verified,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      cloutScore: cloutScore ?? this.cloutScore,
      totalTipsReceived: totalTipsReceived ?? this.totalTipsReceived,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

enum UserRole {
  user,
  creator,
  admin,
  moderator,
}
