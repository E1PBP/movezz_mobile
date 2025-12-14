import 'package:flutter/foundation.dart';
import '../../data/models/feeds_model.dart';
import '../../data/repositories/feeds_repository.dart';

class FeedsController extends ChangeNotifier {
  final FeedsRepository repository;

  FeedsController(this.repository);

  String _activeTab = 'foryou';
  String get activeTab => _activeTab;

  final Map<String, List<FeedPost>> _postsByTab = {
    'foryou': <FeedPost>[],
    'following': <FeedPost>[],
  };

  final Map<String, bool> _hasNextByTab = {'foryou': true, 'following': true};

  final Map<String, int> _pageByTab = {'foryou': 1, 'following': 1};

  bool _isLoadingInitial = false;
  bool get isLoadingInitial => _isLoadingInitial;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final Set<String> _likingPostIds = <String>{};
  bool isLiking(String postId) => _likingPostIds.contains(postId);

  final Map<String, List<FeedComment>> _commentsCache = {};
  final Map<String, bool> _commentsLoading = {};
  final Map<String, String?> _commentsError = {};

  List<FeedPost> get posts =>
      List.unmodifiable(_postsByTab[_activeTab] ?? const []);

  bool get hasNext => _hasNextByTab[_activeTab] ?? false;

  int get currentPage => _pageByTab[_activeTab] ?? 1;

  List<FeedComment> commentsFor(String postId) =>
      List.unmodifiable(_commentsCache[postId] ?? const []);

  bool isCommentsLoading(String postId) => _commentsLoading[postId] ?? false;

  String? commentsError(String postId) => _commentsError[postId];

  Future<void> initIfNeeded() async {
    // panggil ini sekali dari UI (mis. initState)
    if ((_postsByTab[_activeTab] ?? const []).isNotEmpty) return;
    await refresh();
  }

  Future<void> switchTab(String tab) async {
    if (tab == _activeTab) return;
    _activeTab = tab;
    _errorMessage = null;
    notifyListeners();

    if ((_postsByTab[_activeTab] ?? const []).isEmpty) {
      await refresh();
    }
  }

  Future<void> refresh({String? tab}) async {
    final t = tab ?? _activeTab;
    _isLoadingInitial = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await repository.fetchPosts(tab: t, page: 1);
      _postsByTab[t] = res.posts;
      _hasNextByTab[t] = res.hasNext;
      _pageByTab[t] = 1;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) return;
    if (!hasNext) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = currentPage + 1;
      final res = await repository.fetchPosts(tab: _activeTab, page: nextPage);

      final current = _postsByTab[_activeTab] ?? <FeedPost>[];
      _postsByTab[_activeTab] = [...current, ...res.posts];
      _hasNextByTab[_activeTab] = res.hasNext;
      _pageByTab[_activeTab] = nextPage;
    } catch (e) {
      // keep silent, user can retry by scrolling
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(FeedPost post) async {
    if (post.id.isEmpty) return;
    if (_likingPostIds.contains(post.id)) return;

    // optimistic update
    final oldLiked = post.hasLiked;
    final oldCount = post.likesCount;

    post.hasLiked = !post.hasLiked;
    post.likesCount = post.hasLiked
        ? (post.likesCount + 1)
        : (post.likesCount - 1);
    _likingPostIds.add(post.id);
    notifyListeners();

    try {
      final res = await repository.toggleLike(post.id);
      post.hasLiked = res.liked;
      post.likesCount = res.likesCount;
    } catch (e) {
      // rollback
      post.hasLiked = oldLiked;
      post.likesCount = oldCount;
    } finally {
      _likingPostIds.remove(post.id);
      notifyListeners();
    }
  }

  Future<void> loadComments(String postId) async {
    if (postId.isEmpty) return;
    if (_commentsLoading[postId] == true) return;

    _commentsLoading[postId] = true;
    _commentsError[postId] = null;
    notifyListeners();

    try {
      final comments = await repository.fetchComments(postId);
      _commentsCache[postId] = comments;
    } catch (e) {
      _commentsError[postId] = e.toString();
    } finally {
      _commentsLoading[postId] = false;
      notifyListeners();
    }
  }

  Future<void> addComment({
    required FeedPost post,
    required String commentText,
  }) async {
    final postId = post.id;
    if (postId.isEmpty) return;
    final text = commentText.trim();
    if (text.isEmpty) return;

    try {
      final newComment = await repository.addComment(
        postId: postId,
        commentText: text,
      );

      final current = _commentsCache[postId] ?? <FeedComment>[];
      _commentsCache[postId] = [...current, newComment];

      post.commentsCount = post.commentsCount + 1;
      notifyListeners();
    } catch (e) {
      // ignore for now; UI can show snackbar
    }
  }

  Future<CreatePostResult> createPost({
    required String text,
    String? locationName,
    String? hashtags,
    String? sportId,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const CreatePostResult(
        success: false,
        message: 'Post cannot be empty',
      );
    }

    final res = await repository.createPost(
      text: trimmed,
      locationName: locationName,
      hashtags: hashtags,
      sportId: sportId,
    );

    // jika sukses, refresh tab aktif supaya post baru muncul
    if (res.success) {
      await refresh();
    }
    return res;
  }
}
