import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart' hide AppTextField;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/utils/format.dart';
import '../controllers/messages_controller.dart';
import '../widgets/chat_detail_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesController>().fetchConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AppTextField(
                controller: _searchController,
                hintText: "Search user by name...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                onChanged: (val) {
                  context.read<MessagesController>().searchLocalConversations(
                    val,
                  );
                },
              ),
            ),
          ),

          Expanded(
            child: Consumer<MessagesController>(
              builder: (context, controller, child) {
                if (controller.isLoadingConversations) {
                  return const Center(child: CircularProgressIndicator());
                }

                bool isSearching = _searchController.text.isNotEmpty;
                if (controller.filteredConversations.isEmpty && !isSearching) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                        24.height,
                        Text("No chats yet", style: boldTextStyle(size: 20)),
                        8.height,
                        Text(
                          "Start connecting with sports enthusiasts!",
                          style: secondaryTextStyle(),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.filteredConversations.isEmpty && isSearching) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 50,
                          color: Colors.grey.shade300,
                        ),
                        16.height,
                        Text(
                          "No users found for '${_searchController.text}'",
                          style: secondaryTextStyle(),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchConversations(),
                  color: AppColors.primary,
                  backgroundColor: Colors.white,
                  child: ListView.separated(
                    itemCount: controller.filteredConversations.length,
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 84,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final convo = controller.filteredConversations[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailPage(
                                conversation: convo,
                                conversationId: convo.id,
                                otherUserName: convo.otherUserUsername,
                                otherUserAvatar: convo.otherUserAvatar,
                                otherUserDisplayName:
                                    convo.otherUserDisplayName,
                              ),
                            ),
                          ).then((_) {
                            controller.fetchConversations();
                            _searchController.clear();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: convo.otherUserAvatar != null
                                      ? NetworkImage(convo.otherUserAvatar!)
                                      : null,
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.1),
                                  child: convo.otherUserAvatar == null
                                      ? Text(
                                          convo.otherUserUsername[0]
                                              .toUpperCase(),
                                          style: boldTextStyle(
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              16.width,

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            convo.otherUserDisplayName,
                                            style: boldTextStyle(size: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        if (convo.lastMessageAt != null)
                                          Text(
                                            FormatUtils.formatMessageDateTimeChat(
                                              convo.lastMessageAt,
                                            ),
                                            style: secondaryTextStyle(
                                              size: 11,
                                              color: AppColors.primary,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                    6.height,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            convo.lastMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: secondaryTextStyle(
                                              size: 14,
                                              color: Colors.grey.shade600,
                                              weight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
