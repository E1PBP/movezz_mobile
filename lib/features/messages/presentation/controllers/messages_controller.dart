import 'package:flutter/foundation.dart';
import '../../data/models/messages_model.dart';
import '../../data/repositories/messages_repository.dart';
import 'dart:io';

class MessagesController extends ChangeNotifier {
  final MessagesRepository repository;

  MessagesController(this.repository);

  List<ConversationModel> conversations = [];
  bool isLoadingConversations = false;

  List<MessageModel> activeMessages = [];
  bool isLoadingMessages = false;
  bool isSending = false;

  Future<void> fetchConversations() async {
    isLoadingConversations = true;
    notifyListeners();

    try {
      conversations = await repository.getConversations();
    } catch (e) {
      if (kDebugMode) print("Error fetching conversations: $e");
    } finally {
      isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String conversationId) async {
    isLoadingMessages = true;
    activeMessages = [];
    notifyListeners();

    try {
      activeMessages = await repository.getMessages(conversationId);
    } catch (e) {
      if (kDebugMode) print("Error fetching messages: $e");
    } finally {
      isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(
    String conversationId,
    String body, {
    File? image,
  }) async {
    if (body.trim().isEmpty && image == null) return false;

    isSending = true;
    notifyListeners();

    try {
      final newMessage = await repository.sendMessage(
        conversationId,
        body,
        image: image,
      );

      if (newMessage != null) {
        activeMessages.add(newMessage);

        final index = conversations.indexWhere((c) => c.id == conversationId);
        if (index != -1) {
          fetchConversations();
        }

        isSending = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print("Error sending message: $e");
    }

    isSending = false;
    notifyListeners();
    return false;
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) {
    return repository.searchUsers(query);
  }

  Future<String?> startChat(String username) {
    return repository.startChat(username);
  }

  Future<void> pollNewMessages(String conversationId) async {
    if (isLoadingMessages || isSending) return;

    String lastMsgId = "";
    if (activeMessages.isNotEmpty) {
      lastMsgId = activeMessages.last.id;
    }

    try {
      final newMessages = await repository.pollMessages(
        conversationId,
        lastMsgId,
      );

      if (newMessages.isNotEmpty) {
        activeMessages.addAll(newMessages);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Polling error: $e");
    }
  }
}
