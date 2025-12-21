import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';
import '../models/comment_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepository(this.remote);

  Future<ProfileEntry> getProfile(String username) {
    return remote.getProfile(username);
  }

  Future<bool> createPost({
    required String caption,
    String? sport,
    String? location,
    String? hashtags,
    String? hours,
    String? minutes,
    XFile? imageFile,
  }) {
    return remote.createPost(
      caption: caption,
      sport: sport,
      location: location,
      hashtags: hashtags,
      hours: hours,
      minutes: minutes,
      imageFile: imageFile,
    );
  }

  Future<bool> deletePost(String postId) {
    return remote.deletePost(postId);
  }

  Future<bool> updatePost(String postId, String newCaption) {
    return remote.updatePost(postId, newCaption);
  }

  Future<Map<String, dynamic>?> likePost(String postId) {
    return remote.likePost(postId);
  }

  Future<List<Comment>> getComments(String postId) {
    return remote.getComments(postId);
  }

  Future<Comment?> addComment(String postId, String text) {
    return remote.addComment(postId, text);
  }

  Future<bool> toggleFollow(String username) {
    return remote.toggleFollow(username);
  }

  Future<ProfileEntry> updateProfile({
    required String username,
    required String displayName,
    XFile? imageFile,
  }) {
    return remote.updateProfile(
      username: username, 
      displayName: displayName);
  }
}
