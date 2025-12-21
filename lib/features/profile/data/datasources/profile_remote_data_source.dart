import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:movezz_mobile/core/config/env.dart';
import '../models/profile_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

class ProfileRemoteDataSource {
  final CookieRequest cookieRequest;

  ProfileRemoteDataSource(this.cookieRequest);

  Future<ProfileEntry> getProfile(String username) async {
    final url = Env.api('/profile/api/u/$username/');
    final response = await cookieRequest.get(url);

    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      return ProfileEntry.fromJson(map);
    } else {
      throw Exception("Gagal load profile: format data salah");
    }
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
    final url = Env.api('/feeds/create_post/');

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll(cookieRequest.headers);

    request.fields['caption'] = caption;
    request.fields['text'] = caption;

    if (sport != null && sport.isNotEmpty) request.fields['sport'] = sport;
    if (location != null && location.isNotEmpty)
      request.fields['location_name'] = location;
    if (hashtags != null && hashtags.isNotEmpty)
      request.fields['hashtags'] = hashtags;

    if (hours != null && hours.isNotEmpty) request.fields['time_h'] = hours;
    if (minutes != null && minutes.isNotEmpty)
      request.fields['time_m'] = minutes;

    if (imageFile != null) {
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');

      var pic = await http.MultipartFile.fromPath(
        "image",
        imageFile.path,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      );
      request.files.add(pic);
    }

    try {
      var streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return true;
        } else {
          if (kDebugMode) print("Gagal Upload (Logic): ${response.body}");
          return false;
        }
      } else {
        if (kDebugMode)
          print(
            "Gagal Upload (HTTP Error ${response.statusCode}): ${response.body}",
          );
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("Error Network createPost: $e");
      return false;
    }
  }

  Future<bool> updatePost(String postId, String newCaption) async {
    final url = Env.api('/profile/api/posts/$postId/update/');

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll(cookieRequest.headers);

    request.fields['caption'] = newCaption;

    try {
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] == true || data['status'] == 'success';
      } else {
        if (kDebugMode)
          print("Update failed [${response.statusCode}]: ${response.body}");
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("Remote Error updatePost: $e");
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    final url = Env.api('/profile/api/posts/$postId/delete/');

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll(cookieRequest.headers);

    try {
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['ok'] == true || data['status'] == 'success';
      } else {
        if (kDebugMode)
          print("Delete failed [${response.statusCode}]: ${response.body}");
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("Remote Error deletePost: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> likePost(String postId) async {
    final url = Env.api('/feeds/like_post/');
    try {
      final response = await cookieRequest.post(url, {'post_id': postId});
      return response;
    } catch (e) {
      if (kDebugMode) print("Error liking post: $e");
      return null;
    }
  }

  Future<List<Comment>> getComments(String postId) async {
    final url = Env.api('/feeds/get_comments/?post_id=$postId');
    try {
      final response = await cookieRequest.get(url);
      if (response['status'] == 'success') {
        final list = response['comments'] as List;
        return list.map((e) => Comment.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      if (kDebugMode) print("Error fetch comments: $e");
      return [];
    }
  }

  Future<Comment?> addComment(String postId, String text) async {
    final url = Env.api('/feeds/add_comment/');
    try {
      final response = await cookieRequest.post(url, {
        'post_id': postId,
        'comment_text': text,
      });

      if (response['status'] == 'success') {
        return Comment.fromJson(response['comment']);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print("Error add comment: $e");
      return null;
    }
  }

  Future<bool> toggleFollow(String username) async {
    final url = Env.api('/profile/api/follow/$username/toggle/');
    try {
      final response = await cookieRequest.post(url, {});
      return response['following'] != null;
    } catch (e) {
      if (kDebugMode) print("Error toggle follow: $e");
      return false;
    }
  }

  Future<ProfileEntry> updateProfile({
    required String username,
    required String displayName,
    XFile? imageFile,
  }) async {
    final url = Env.api('/profile/api/update/');

    try {
      if (imageFile != null && !kIsWeb) {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll(cookieRequest.headers);

        request.fields['display_name'] = displayName;

        final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
        final mimeSplit = mimeType.split('/');
        var imageFileMultipart = await http.MultipartFile.fromPath(
          'avatar',
          imageFile.path,
          contentType: MediaType(mimeSplit[0], mimeSplit[1]),
        );
        request.files.add(imageFileMultipart);

        var streamResponse = await request.send();
        var response = await http.Response.fromStream(streamResponse);

        if (kDebugMode) {
          print('MultipartRequest Status: ${response.statusCode}');
          print('MultipartRequest Response: ${response.body}');
        }

        if (response.statusCode != 200) {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to update profile');
        }

        final updateResponse = json.decode(response.body);

        if (updateResponse['status'] != 'success') {
          throw Exception(updateResponse['message'] ?? 'Update failed');
        }

        final profileUrl = Env.api('/profile/api/u/$username/');
        final profileResponse = await cookieRequest.get(profileUrl);

        if (profileResponse is Map) {
          return ProfileEntry.fromJson(
            Map<String, dynamic>.from(profileResponse),
          );
        } else {
          throw Exception('Failed to fetch updated profile');
        }
      } else {
        final updateResponse = await cookieRequest.post(url, {
          'display_name': displayName,
        });

        if (updateResponse is! Map || updateResponse['status'] != 'success') {
          throw Exception(
            updateResponse['message'] ?? 'Failed to update profile',
          );
        }

        final profileUrl = Env.api('/profile/api/u/$username/');
        final profileResponse = await cookieRequest.get(profileUrl);

        if (profileResponse is Map) {
          return ProfileEntry.fromJson(
            Map<String, dynamic>.from(profileResponse),
          );
        } else {
          throw Exception('Failed to fetch updated profile');
        }
      }
    } catch (e) {
      if (kDebugMode) print('Error in updateProfile: $e');
      rethrow;
    }
  }

  String _getCookieString() {
    return '';
  }
}