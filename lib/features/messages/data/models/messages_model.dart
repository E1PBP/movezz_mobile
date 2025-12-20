class ConversationModel {
  final String id;
  final String otherUserUsername;
  final String otherUserDisplayName;
  final String? otherUserAvatar;
  final String lastMessage;
  final String? lastMessageAt;

  ConversationModel({
    required this.id,
    required this.otherUserUsername,
    required this.otherUserDisplayName,
    this.otherUserAvatar,
    required this.lastMessage,
    this.lastMessageAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      otherUserUsername: json['other_user_username'] ?? 'Unknown',
      otherUserDisplayName: json['other_user_display_name'] ?? 'Unknown',
      otherUserAvatar: json['other_user_avatar'],
      lastMessage: json['last_message'] ?? '',
      lastMessageAt: json['last_message_at'],
    );
  }
}

class MessageModel {
  final String id;
  final String sender;
  final String body;
  final String? imageUrl;
  final bool isSelf;
  final String createdAt;
  final String? senderAvatar;

  MessageModel({
    required this.id,
    required this.sender,
    required this.body,
    this.imageUrl,
    required this.isSelf,
    required this.createdAt,
    this.senderAvatar,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      sender: json['sender'] ?? 'Unknown',
      body: json['body'] ?? '',
      imageUrl: json['image_url'],
      isSelf: json['is_self'] ?? false,
      createdAt: json['created_at'] ?? '',
      senderAvatar: json['sender_avatar'],
    );
  }
}


class ChatUserModel {
  final String username;
  final String displayName;
  final String? avatarUrl;

  ChatUserModel({
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory ChatUserModel.fromJson(Map<String, dynamic> json) {
    return ChatUserModel(
      username: json['username'] ?? '',
      // Fallback ke username jika display_name kosong/null
      displayName: json['display_name'] ?? json['username'] ?? '',
      avatarUrl: json['avatar_url'],
    );
  }
}