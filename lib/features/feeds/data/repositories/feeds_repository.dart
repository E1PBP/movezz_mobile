import '../datasources/feeds_remote_data_source.dart';
import '../models/feeds_model.dart';

abstract class FeedsRepository {
  Future<FeedsPageResponse> fetchPosts({
    required String tab,
    required int page,
  });
  Future<LikeResult> toggleLike(String postId);
  Future<List<FeedComment>> fetchComments(String postId);
  Future<FeedComment> addComment({
    required String postId,
    required String commentText,
  });
  Future<CreatePostResult> createPost({
    required String text,
    String? locationName,
    String? hashtags,
    String? sportId,
  });
}

class FeedsRepositoryImpl implements FeedsRepository {
  final FeedsRemoteDataSource remote;
  FeedsRepositoryImpl(this.remote);

  @override
  Future<FeedsPageResponse> fetchPosts({
    required String tab,
    required int page,
  }) => remote.fetchPosts(tab: tab, page: page);

  @override
  Future<LikeResult> toggleLike(String postId) =>
      remote.toggleLike(postId: postId);

  @override
  Future<List<FeedComment>> fetchComments(String postId) =>
      remote.fetchComments(postId: postId);

  @override
  Future<FeedComment> addComment({
    required String postId,
    required String commentText,
  }) => remote.addComment(postId: postId, commentText: commentText);

  @override
  Future<CreatePostResult> createPost({
    required String text,
    String? locationName,
    String? hashtags,
    String? sportId,
  }) => remote.createPost(
    text: text,
    locationName: locationName,
    hashtags: hashtags,
    sportId: sportId,
  );
}