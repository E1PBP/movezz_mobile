import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:movezz_mobile/core/config/env.dart';
import '../models/messages_model.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class MessagesRemoteDataSource {
  final CookieRequest cookieRequest;

  MessagesRemoteDataSource(this.cookieRequest);

  Future<List<ConversationModel>> getConversations() async {
    final url = Env.api('/messages/api/conversations/');
    final response = await cookieRequest.get(url);

    if (response['conversations'] != null) {
      final list = response['conversations'] as List;
      return list.map((e) => ConversationModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final url = Env.api(
      '/messages/api/conversations/$conversationId/messages/',
    );
    final response = await cookieRequest.get(url);

    if (response['messages'] != null) {
      final list = response['messages'] as List;
      return list.map((e) => MessageModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<MessageModel?> sendMessage(
    String conversationId,
    String message, {
    File? image,
  }) async {
    final url = Env.api('/messages/api/conversations/$conversationId/send/');
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(cookieRequest.headers);
    if (message.isNotEmpty) {
      request.fields['message'] = message;
    }
    if (image != null) {
      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
      final mimeSplit = mimeType.split('/');

      var pic = await http.MultipartFile.fromPath(
        "image",
        image.path,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      );
      request.files.add(pic);
    }

    var streamResponse = await request.send();
    var response = await http.Response.fromStream(streamResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      data['is_self'] = true;
      return MessageModel.fromJson(data);
    } else {
      print("Upload failed [${response.statusCode}]: ${response.body}");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final url = Env.api('/messages/api/users/search/?q=$query');
    final response = await cookieRequest.get(url);

    if (response['users'] != null) {
      return List<Map<String, dynamic>>.from(response['users']);
    }
    return [];
  }

  Future<String?> startChat(String username) async {
    final url = Env.api('/messages/api/start/$username/');
    final response = await cookieRequest.post(url, {});

    if (response['conversation_id'] != null) {
      return response['conversation_id'];
    }
    return null;
  }

  Future<List<MessageModel>> pollMessages(
    String conversationId,
    String lastMsgId,
  ) async {
    final url = Env.api(
      '/messages/api/conversations/$conversationId/poll/?last_msg_id=$lastMsgId',
    );

    final response = await cookieRequest.get(url);

    if (response['messages'] != null) {
      final list = response['messages'] as List;
      return list.map((e) => MessageModel.fromJson(e)).toList();
    }
    return [];
  }
}
