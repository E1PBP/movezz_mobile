import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../data/repositories/profile_repository.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/comment_model.dart';
import 'package:movezz_mobile/core/config/env.dart';
import 'package:image_picker/image_picker.dart'; 


class ProfileController extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileController(this.repository);

  ProfileEntry? profile;
  bool isLoading = false;
  String? errorMessage;
  bool isLoadingPosts = false;
  PostEntry? postsEntry;

  Future<void> loadProfile(String username) async {
    if (username.isEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await repository.getProfile(username);
    } catch (e) {
      if (kDebugMode) print("Error loading profile: $e");
      errorMessage = 'Failed to load profile';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPosts(String username) async {
    isLoadingPosts = true;
    notifyListeners();
    try {
      final url = Env.api('/profile/api/u/$username/posts/');
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        postsEntry = postEntryFromJson(response.body);
        if (profile != null && postsEntry != null) {
          profile!.postCount = postsEntry!.postCount;
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error loading posts: $e");
    }
    isLoadingPosts = false;
    notifyListeners();
  }

  Future<bool> createPost({
    required String caption,
    String? sport,
    String? location,
    String? hashtags,
    String? hours,
    String? minutes,
    XFile? imageFile, 
  }) async {
    if (caption.isEmpty && imageFile == null) return false;

    try {
      final success = await repository.createPost(
        caption: caption,
        sport: sport,
        location: location,
        hashtags: hashtags,
        hours: hours,
        minutes: minutes,
        imageFile: imageFile, 
      );

      if (success) {
        if (profile != null) {
          await loadUserPosts(profile!.username);
          if (postsEntry != null) {
            profile!.postCount = postsEntry!.postCount;
          }
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      if (kDebugMode) print("Controller Error createPost: $e");
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    final success = await repository.deletePost(postId);
    if (success && postsEntry != null) {
      postsEntry!.posts.removeWhere((p) => p.id == postId);
      if (profile != null) profile!.postCount = (profile!.postCount - 1).clamp(0, 9999);
      notifyListeners();
    }
    return success;
  }

  Future<bool> updatePost(String postId, String newCaption) async {
    final success = await repository.updatePost(postId, newCaption);
    if (success && postsEntry != null) {
      final index = postsEntry!.posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        postsEntry!.posts[index].caption = newCaption;
        notifyListeners();
      }
    }
    return success;
  }

  Future<bool> togglePostLike(String postId) async {
    final result = await repository.likePost(postId);
    if (result != null && result['status'] == 'success' && postsEntry != null) {
      final index = postsEntry!.posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        postsEntry!.posts[index].likesCount = result['likes_count'];
        postsEntry!.posts[index].hasLiked = result['liked'];
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<List<Comment>> fetchComments(String postId) async {
    return await repository.getComments(postId);
  }

  Future<Comment?> postComment(String postId, String text) async {
    final newComment = await repository.addComment(postId, text);
    if (newComment != null && postsEntry != null) {
      final index = postsEntry!.posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        postsEntry!.posts[index].commentsCount += 1;
        notifyListeners();
      }
    }
    return newComment;
  }

  Future<void> toggleFollowUser() async {
    if (profile == null) return;
    profile!.isFollowing = !profile!.isFollowing;
    profile!.followersCount += profile!.isFollowing ? 1 : -1;
    notifyListeners();
    await repository.toggleFollow(profile!.username);
  }
}