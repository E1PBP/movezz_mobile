// To parse this JSON data, do
//
//     final profileEntry = profileEntryFromJson(jsonString);

import 'dart:convert';

ProfileEntry profileEntryFromJson(String str) => ProfileEntry.fromJson(json.decode(str));

String profileEntryToJson(ProfileEntry data) => json.encode(data.toJson());

class ProfileEntry {
    String username;
    String? displayName;
    String?bio;
    String? link;
    String? avatarUrl;
    String? currentSport;
    int postCount;
    int broadcastCount;
    int followingCount;
    int followersCount;
    bool isVerified;
    bool isFollowing;
    DateTime createdAt;
    DateTime updatedAt;

    ProfileEntry({
        required this.username,
        this.displayName,
        this.bio,
        this.link,
        this.avatarUrl,
        this.currentSport,
        required this.postCount,
        required this.broadcastCount,
        required this.followingCount,
        required this.followersCount,
        required this.isVerified,
        this.isFollowing = false,
        required this.createdAt,
        required this.updatedAt,
    });

    factory ProfileEntry.fromJson(Map<String, dynamic> json) => ProfileEntry(
        username: json["username"] ?? '',
        displayName: json["display_name"],
        bio: json["bio"],
        link: json["link"],
        avatarUrl: json["avatar_url"],
        currentSport: json["current_sport"],
        postCount: json['post_count'] ?? 0,
        broadcastCount: json["broadcast_count"] ?? 0,
        followersCount: json['followers_count'] ?? 0,
        followingCount: json['following_count'] ?? 0,
        isVerified: json["is_verified"] ?? false,
        isFollowing: json["is_following"] ?? false,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "display_name": displayName,
        "bio": bio,
        "link": link,
        "avatar_url": avatarUrl,
        "current_sport": currentSport,
        "post_count": postCount,
        "broadcast_count": broadcastCount,
        "following_count": followingCount,
        "followers_count": followersCount,
        "is_verified": isVerified,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}
