// TODO
class ProfileModel {
  final int userId;                 
  final String? displayName;
  final String? bio;
  final String? link;
  final String? avatarUrl;          
  final Sport? currentSport;        

  final int postCount;
  final int broadcastCount;
  final int followingCount;
  final int followersCount;
  final bool isVerified;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.userId,
    this.displayName,
    this.bio,
    this.link,
    this.avatarUrl,
    this.currentSport,
    this.postCount = 0,
    this.broadcastCount = 0,
    this.followingCount = 0,
    this.followersCount = 0,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user'] as int,
      displayName: json['display_name'] as String?,
      bio: json['bio'] as String?,
      link: json['link'] as String?,
      avatarUrl: json['avatar_url'] as String?, 

      currentSport: json['current_sport'] != null
          ? Sport.fromJson(json['current_sport'])
          : null,

      postCount: (json['post_count'] ?? 0) as int,
      broadcastCount: (json['broadcast_count'] ?? 0) as int,
      followingCount: (json['following_count'] ?? 0) as int,
      followersCount: (json['followers_count'] ?? 0) as int,
      isVerified: (json['is_verified'] ?? false) as bool,

      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'display_name': displayName,
      'bio': bio,
      'link': link,
      'avatar_url': avatarUrl,
      'current_sport': currentSport?.toJson(),
      'post_count': postCount,
      'broadcast_count': broadcastCount,
      'following_count': followingCount,
      'followers_count': followersCount,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? displayName,
    String? bio,
    String? link,
    String? avatarUrl,
    Sport? currentSport,
    int? postCount,
    int? broadcastCount,
    int? followingCount,
    int? followersCount,
    bool? isVerified,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      userId: userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      link: link ?? this.link,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentSport: currentSport ?? this.currentSport,
      postCount: postCount ?? this.postCount,
      broadcastCount: broadcastCount ?? this.broadcastCount,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Sport {
  final int id;
  final String name;

  const Sport({
    required this.id,
    required this.name,
  });

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Badge {
  final int id;
  final String name;
  final String? iconUrl;

  const Badge({
    required this.id,
    required this.name,
    this.iconUrl,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as int,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
    };
  }
}


