import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' hide AppTextField, AppButton;
import 'package:provider/provider.dart';
import '../../data/models/messages_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/messages_controller.dart';
import 'chat_detail_page.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  final _searchController = TextEditingController();
  List<ChatUserModel> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final results = await context.read<MessagesController>().searchUsers(query);

    if (!mounted) return;

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _onUserTap(ChatUserModel user) async {
    setState(() => _isSearching = true);

    final convoId = await context.read<MessagesController>().startChat(
      user.username,
    );

    if (!mounted) return;
    setState(() => _isSearching = false);

    if (convoId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailPage(
            conversationId: convoId,
            otherUserName: user.displayName,
            otherUserAvatar: user.avatarUrl,
          ),
        ),
      );
    } else {
      toast("Failed to start chat");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("New Message", style: boldTextStyle(size: 18)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
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
                  _performSearch();
                },
              ),
            ),
          ),

          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            16.height,
            Text("Searching users...", style: secondaryTextStyle()),
          ],
        ),
      );
    }

    if (!_hasSearched && _searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: 50,
                color: Colors.grey.shade400,
              ),
            ),
            16.height,
            Text("Find People", style: boldTextStyle(size: 18)),
            8.height,
            Text(
              "Search for your friends to start chatting",
              style: secondaryTextStyle(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_hasSearched && _searchResults.isEmpty) {
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

    return ListView.separated(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 84, color: AppColors.divider),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final displayName = user.displayName;
        final username = user.username;
        final avatarUrl = user.avatarUrl;

        return InkWell(
          onTap: () => _onUserTap(user),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: avatarUrl == null
                        ? Text(
                            (username as String)[0].toUpperCase(),
                            style: boldTextStyle(
                              color: AppColors.primary,
                              size: 18,
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
                      Text(displayName, style: boldTextStyle(size: 16)),
                      4.height,
                      Text("@$username", style: secondaryTextStyle(size: 14)),
                    ],
                  ),
                ),

                Icon(Icons.navigate_next, color: Colors.grey.shade300),
              ],
            ),
          ),
        );
      },
    );
  }
}
