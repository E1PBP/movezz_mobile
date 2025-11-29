import '../datasources/messages_remote_data_source.dart';
import '../models/messages_model.dart';
import 'dart:io';

class MessagesRepository {
  final MessagesRemoteDataSource remote;

  MessagesRepository(this.remote);

  Future<List<ConversationModel>> getConversations() {
    return remote.getConversations();
  }

  Future<List<MessageModel>> getMessages(String conversationId) {
    return remote.getMessages(conversationId);
  }

  Future<MessageModel?> sendMessage(
    String conversationId,
    String message, {
    File? image,
  }) {
    return remote.sendMessage(conversationId, message, image: image);
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) {
    return remote.searchUsers(query);
  }

  Future<String?> startChat(String username) {
    return remote.startChat(username);
  }

  Future<List<MessageModel>> pollMessages(
    String conversationId,
    String lastMsgId,
  ) {
    return remote.pollMessages(conversationId, lastMsgId);
  }
}
