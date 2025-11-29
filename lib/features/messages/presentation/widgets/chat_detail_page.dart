import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/messages_model.dart';
import '../controllers/messages_controller.dart';
import '../widgets/chat_bubble.dart';

class ChatDetailPage extends StatefulWidget {
  final ConversationModel? conversation;
  final String conversationId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatDetailPage({
    super.key,
    this.conversation,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesController>().fetchMessages(widget.conversationId);
      startPolling();
    });
  }

  void startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        context.read<MessagesController>().pollNewMessages(
          widget.conversationId,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _handleSend() async {
    final text = _messageController.text;

    if (text.trim().isEmpty && _selectedImage == null) return;

    final imageToSend = _selectedImage;

    setState(() {
      _selectedImage = null;
      _messageController.clear();
    });

    final success = await context.read<MessagesController>().sendMessage(
      widget.conversationId,
      text,
      image: imageToSend,
    );

    if (!success) {
      toast("Failed to send message");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.otherUserAvatar != null
                  ? NetworkImage(widget.otherUserAvatar!)
                  : null,
              child: widget.otherUserAvatar == null
                  ? Text(widget.otherUserName[0].toUpperCase())
                  : null,
            ),
            12.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: boldTextStyle(color: Colors.white, size: 16),
                  ),
                  Text(
                    "Online",
                    style: secondaryTextStyle(color: Colors.white70, size: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessagesController>(
              builder: (context, controller, child) {
                if (controller.isLoadingMessages) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.activeMessages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        8.height,
                        Text("No messages yet", style: secondaryTextStyle()),
                        Text(
                          "Say Hi to ${widget.otherUserName}!",
                          style: primaryTextStyle(),
                        ),
                      ],
                    ),
                  );
                }

                final messages = controller.activeMessages.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),

          if (_selectedImage != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: context.cardColor,
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.image, color: AppColors.primary),
                    onPressed: _pickImage,
                  ),

                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: secondaryTextStyle(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.layoutBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  12.width,
                  Consumer<MessagesController>(
                    builder: (context, controller, _) {
                      return InkWell(
                        onTap: controller.isSending ? null : _handleSend,
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: controller.isSending
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
