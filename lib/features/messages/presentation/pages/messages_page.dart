import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/messages_controller.dart';
import '../widgets/chat_detail_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesController>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MessagesController>(
        builder: (context, controller, child) {
          if (controller.isLoadingConversations) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mark_chat_unread_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  16.height,
                  Text("No conversations yet", style: boldTextStyle(size: 18)),
                  8.height,
                  Text(
                    "Start a new chat from the top right button!",
                    style: secondaryTextStyle(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchConversations(),
            child: ListView.separated(
              itemCount: controller.conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final convo = controller.conversations[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: convo.otherUserAvatar != null
                        ? NetworkImage(convo.otherUserAvatar!)
                        : null,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: convo.otherUserAvatar == null
                        ? Text(
                            convo.otherUserUsername[0].toUpperCase(),
                            style: boldTextStyle(color: AppColors.primary),
                          )
                        : null,
                  ),
                  title: Text(
                    convo.otherUserDisplayName,
                    style: boldTextStyle(size: 16),
                  ),
                  subtitle: Text(
                    convo.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: secondaryTextStyle(),
                  ),
                  trailing: Text(
                    convo.lastMessageAt != null
                        ? convo.lastMessageAt!.split(' ').last
                        : '',
                    style: secondaryTextStyle(size: 12),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                          conversation: convo,
                          conversationId: convo.id,
                          otherUserName: convo.otherUserDisplayName,
                          otherUserAvatar: convo.otherUserAvatar,
                        ),
                      ),
                    ).then((_) {
                      controller.fetchConversations();
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
