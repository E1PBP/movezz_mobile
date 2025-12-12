import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:mime/mime.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:movezz_mobile/core/config/env.dart';
import '../models/profile_model.dart';
import '../models/comment_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

    Map<String, dynamic> data = {
      'caption': caption,
      'sport': sport ?? "",
      'location': location ?? "",
      'hashtags': hashtags ?? "",
      'time_h': hours ?? "",
      'time_m': minutes ?? "",
    };

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);
      data['image'] = base64Image; // Kirim sebagai string, bukan file
    }

    try {
      final response = await cookieRequest.post(url, data);

      if (response['status'] == 'success') {
        print("Sukses Upload!");
        return true;
      } else {
        print("Gagal Upload: $response");
        return false;
      }
    } catch (e) {
      print("Error Network: $e");
      return false;
    }
  }

  Future<bool> updatePost(String postId, String newCaption) async {
    final url = Env.api('/profile/api/posts/$postId/update/');
    try {
      final response = await cookieRequest.post(url, {'caption': newCaption});
      return response['ok'] == true || response['status'] == 'success';
    } catch (e) {
      print("Remote Error updatePost: $e");
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
      final url = Env.api('/profile/api/posts/$postId/delete/');
      try {
        final response = await cookieRequest.post(url, {});
        return response['ok'] == true || response['status'] == 'success';
      } catch (e) {
        print("Remote Error deletePost: $e");
        return false;
      }
  }

  Future<Map<String, dynamic>?> likePost(String postId) async {
    final url = Env.api('/feeds/like_post/');
    try {
      final response = await cookieRequest.post(url, {'post_id': postId});
      return response;
    } catch (e) {
      print("Error liking post: $e");
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
      print("Error fetch comments: $e");
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
      print("Error add comment: $e");
      return null;
    }
  }

  Future<bool> toggleFollow(String username) async {
    final url = Env.api('/profile/api/follow/$username/toggle/'); 
    try {
      final response = await cookieRequest.post(url, {});
      return response['following'] != null;
    } catch (e) {
      print("Error toggle follow: $e");
      return false;
    }
  }
}