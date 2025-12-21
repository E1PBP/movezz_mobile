import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../../../features/profile/data/repositories/profile_repository.dart';
import '../../../../features/profile/presentation/controllers/profile_controller.dart';
import '../../../../features/profile/presentation/pages/profile_page.dart';

import '../../../../core/constant/polling_constant.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/messages_model.dart';
import '../controllers/messages_controller.dart';
import '../widgets/chat_bubble.dart';

class ChatDetailPage extends StatefulWidget {
  final ConversationModel? conversation;
  final String conversationId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? otherUserDisplayName;

  const ChatDetailPage({
    super.key,
    this.conversation,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.otherUserDisplayName,
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

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        context.read<MessagesController>().loadMoreMessages(
          widget.conversationId,
        );
      }
    });
  }

  void startPolling() {
    _pollingTimer = Timer.periodic(
      const Duration(seconds: PollingConstant.defaultIntervalSeconds),
      (timer) {
        if (mounted) {
          context.read<MessagesController>().pollNewMessages(
            widget.conversationId,
          );
        }
      },
    );
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
      backgroundColor: AppColors.layoutBackground,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: InkWell(
          onTap: () {
            final request = context.read<CookieRequest>();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider(
                  create: (_) {
                    final remoteDataSource = ProfileRemoteDataSource(request);
                    final repository = ProfileRepository(remoteDataSource);
                    return ProfileController(repository);
                  },
                  child: ProfilePage(
                    username: widget.otherUserName,
                    showBackButton: true,
                  ),
                ),
              ),
            ).then((_) {
              if (mounted) {
                context.read<MessagesController>().fetchMessages(
                  widget.conversationId,
                );
              }
            });
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.otherUserAvatar != null
                    ? NetworkImage(widget.otherUserAvatar!)
                    : null,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: widget.otherUserAvatar == null
                    ? Text(
                        widget.otherUserName[0].toUpperCase(),
                        style: boldTextStyle(color: AppColors.primary),
                      )
                    : null,
              ),
              12.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserDisplayName ?? widget.otherUserName,
                      style: boldTextStyle(color: Colors.black87, size: 16),
                    ),
                    Text(
                      "@" + widget.otherUserName,
                      style: secondaryTextStyle(color: Colors.grey, size: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.waving_hand_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        16.height,
                        Text("No messages yet", style: secondaryTextStyle()),
                        4.height,
                        Text(
                          "Say Hi to ${widget.otherUserName}!",
                          style: boldTextStyle(size: 16),
                        ),
                      ],
                    ),
                  );
                }

                final messages = controller.activeMessages.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount:
                      messages.length + (controller.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return ChatBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: context.width(),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Selected Image", style: boldTextStyle(size: 12)),
                  8.height,
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
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
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
              top: 8,
            ),
            decoration: const BoxDecoration(color: Colors.white),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey.shade700,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: secondaryTextStyle(),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  8.width,
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Consumer<MessagesController>(
                      builder: (context, controller, _) {
                        return InkWell(
                          onTap: controller.isSending ? null : _handleSend,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: controller.isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),
                        );
                      },
                    ),
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
