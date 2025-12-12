// To parse this JSON data, do
//
//     final postEntry = postEntryFromJson(jsonString);

import 'dart:convert';

PostEntry postEntryFromJson(String str) => PostEntry.fromJson(json.decode(str));

String postEntryToJson(PostEntry data) => json.encode(data.toJson());

class PostEntry {
    String username;
    int postCount;
    List<Post> posts;

    PostEntry({
        required this.username,
        required this.postCount,
        required this.posts,
    });

    factory PostEntry.fromJson(Map<String, dynamic> json) => PostEntry(
        username: json["username"],
        postCount: json["post_count"],
        posts: List<Post>.from(json["posts"].map((x) => Post.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "username": username,
        "post_count": postCount,
        "posts": List<dynamic>.from(posts.map((x) => x.toJson())),
    };
}

class Post {
    String id;
    String caption;
    String? sport;
    String? location; 
    int likesCount; 
    int commentsCount;
    bool hasLiked;
    String? imageUrl;
    DateTime createdAt;

    Post({
        required this.id,
        required this.caption,
        required this.sport,
        this.location,
        this.likesCount = 0,
        this.commentsCount = 0,
        this.hasLiked = false,
        required this.imageUrl,
        required this.createdAt,
    });

    factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        caption: json["caption"],
        sport: json["sport"],
        location: json["location"],
        likesCount: json["likes_count"] ?? 0,
        commentsCount: json["comments_count"] ?? 0,
        hasLiked: json["has_liked"] ?? false,
        imageUrl: json["image_url"],
        createdAt: DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "caption": caption,
        "sport": sport,
        "location": location,
        "likes_count": likesCount,
        "comments_count": commentsCount,
        "image_url": imageUrl,
        "created_at": createdAt.toIso8601String(),
    };
}
