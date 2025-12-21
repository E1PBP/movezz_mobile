class FeedsPageResponse {
  final List<FeedPost> posts;
  final bool hasNext;
  final int? nextPageNumber;

  const FeedsPageResponse({
    required this.posts,
    required this.hasNext,
    required this.nextPageNumber,
  });

  factory FeedsPageResponse.fromJson(Map<String, dynamic> json) {
    final rawPosts = (json['posts'] as List?) ?? const [];
    return FeedsPageResponse(
      posts: rawPosts
          .whereType<Map>()
          .map((e) => FeedPost.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      hasNext: _asBool(json['has_next']) ?? false,
      nextPageNumber: _asInt(json['next_page_number']),
    );
  }
}

class FeedPost {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final List<String> badgeIconUrls;
  final List<String> imageUrls;
  final List<String> hashtags;

  final String text;
  final String? sport;
  final String? locationName;

  int likesCount;
  int commentsCount;
  bool hasLiked;
  final DateTime? createdAt;

  FeedPost({
    required this.id,
    required this.username,
    required this.displayName,
    required this.text,
    required this.likesCount,
    required this.commentsCount,
    required this.hasLiked,
    required this.badgeIconUrls,
    this.avatarUrl,
    this.sport,
    this.locationName,
    this.createdAt,
    this.imageUrls = const [],
    this.hashtags = const [],
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    final username = (json['user'] ?? json['username'] ?? '').toString();
    final displayName =
        (json['author_display_name'] ?? json['display_name'] ?? username)
            .toString();

    final rawBadges = (json['author_badges_url'] ?? '').toString();
    final badgeUrls = rawBadges
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    final rawImageUrls = (json['image_urls'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    final rawHashtags = (json['hashtags'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    // tolerant key
    final text = (json['text'] ?? json['content'] ?? '').toString();
    final sport = (json['sport_type'] ?? json['sport'] ?? json['sport_name'])
        ?.toString();

    final createdAtRaw = json['created_at']?.toString();
    DateTime? createdAt;
    if (createdAtRaw != null && createdAtRaw.isNotEmpty) {
      createdAt = DateTime.tryParse(createdAtRaw.replaceFirst(' ', 'T'));
    }

    return FeedPost(
      id: (json['id'] ?? '').toString(),
      username: username,
      displayName: displayName,
      avatarUrl: (json['author_avatar_url'] as String?)?.isEmpty == true
          ? null
          : json['author_avatar_url']?.toString(),
      badgeIconUrls: badgeUrls,
      imageUrls: rawImageUrls,
      hashtags: rawHashtags,
      text: text,
      sport: (sport != null && sport.trim().isEmpty) ? null : sport,
      locationName: json['location_name']?.toString(),
      likesCount: _asInt(json['likes_count']) ?? 0,
      commentsCount: _asInt(json['comments_count']) ?? 0,
      hasLiked: _asBool(json['has_liked']) ?? false,
      createdAt: createdAt,
    );
  }
}

class FeedComment {
  final String text;
  final String author;
  final String username;
  final String? avatarUrl;
  final String? createdAtLabel;

  const FeedComment({
    required this.text,
    required this.author,
    required this.username,
    this.avatarUrl,
    this.createdAtLabel,
  });

  factory FeedComment.fromJson(Map<String, dynamic> json) {
    return FeedComment(
      text: (json['text'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] as String?)?.isEmpty == true
          ? null
          : json['avatar_url']?.toString(),
      createdAtLabel: json['created_at']?.toString(),
    );
  }
}

class LikeResult {
  final bool liked;
  final int likesCount;

  const LikeResult({required this.liked, required this.likesCount});

  factory LikeResult.fromJson(Map<String, dynamic> json) {
    return LikeResult(
      liked: _asBool(json['liked']) ?? false,
      likesCount: _asInt(json['likes_count']) ?? 0,
    );
  }
}

class CreatePostResult {
  final bool success;
  final String? message;

  const CreatePostResult({required this.success, this.message});

  factory CreatePostResult.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final ok = status == true || status == 'success' || status == 'ok';
    return CreatePostResult(success: ok, message: json['message']?.toString());
  }
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString());
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase().trim();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return null;
}