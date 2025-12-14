import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:movezz_mobile/core/config/env.dart';
import '../models/feeds_model.dart';

class FeedsRemoteDataSource {
  final CookieRequest cookieRequest;

  FeedsRemoteDataSource(this.cookieRequest);

  Future<FeedsPageResponse> fetchPosts({
    required String tab,
    required int page,
  }) async {
    final url = Env.api('/feeds/api/load_more/?tab=$tab&page=$page');
    final response = await cookieRequest.get(url);

    if (response is! Map) throw Exception('Unexpected response from feeds API');
    return FeedsPageResponse.fromJson(Map<String, dynamic>.from(response));
  }

  Future<LikeResult> toggleLike({required String postId}) async {
    final url = Env.api('/feeds/api/like_post/');
    final body = jsonEncode({'post_id': postId});
    final response = await cookieRequest.postJson(url, body);

    if (response is! Map) throw Exception('Unexpected response from like API');
    return LikeResult.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<FeedComment>> fetchComments({required String postId}) async {
    final url = Env.api('/feeds/api/get_comments/?post_id=$postId');
    final response = await cookieRequest.get(url);

    if (response is! Map)
      throw Exception('Unexpected response from comments API');

    final json = Map<String, dynamic>.from(response);
    final raw = (json['comments'] as List?) ?? const [];

    return raw
        .whereType<Map>()
        .map((e) => FeedComment.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<FeedComment> addComment({
    required String postId,
    required String commentText,
  }) async {
    final url = Env.api('/feeds/api/add_comment/');
    final body = jsonEncode({'post_id': postId, 'comment_text': commentText});
    final response = await cookieRequest.postJson(url, body);

    if (response is! Map)
      throw Exception('Unexpected response from add comment API');

    final json = Map<String, dynamic>.from(response);
    final commentJson = json['comment'];

    if (commentJson is Map) {
      return FeedComment.fromJson(Map<String, dynamic>.from(commentJson));
    }

    return FeedComment(
      text: commentText,
      author: 'You',
      username: '',
      avatarUrl: null,
      createdAtLabel: null,
    );
  }

  Future<CreatePostResult> createPost({
    required String text,
    String? locationName,
    String? hashtags,
    String? sportId,
  }) async {
    final url = Env.api('/feeds/api/create_post/');
    final payload = <String, dynamic>{
      'text': text,
      if (locationName != null) 'location_name': locationName,
      if (hashtags != null) 'hashtags': hashtags,
      if (sportId != null) 'sport': sportId,
    };

    final response = await cookieRequest.postJson(url, jsonEncode(payload));
    if (response is! Map)
      throw Exception('Unexpected response from create post API');

    return CreatePostResult.fromJson(Map<String, dynamic>.from(response));
  }
}
