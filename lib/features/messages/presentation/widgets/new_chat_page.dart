import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' hide AppTextField, AppButton;
import 'package:provider/provider.dart';

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
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();

    setState(() => _isSearching = true);
    
    final results = await context.read<MessagesController>().searchUsers(query);
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _onUserTap(Map<String, dynamic> user) async {
    setState(() => _isSearching = true);
    
    final convoId = await context.read<MessagesController>().startChat(user['username']);
    
    setState(() => _isSearching = false);

    if (convoId != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailPage(
            conversationId: convoId,
            otherUserName: user['display_name'] ?? user['username'],
            otherUserAvatar: user['avatar_url'],
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
      appBar: AppBar(title: const Text("New Message")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppTextField(
              controller: _searchController,
              hintText: "Search user by name...",
              prefixIcon: const Icon(Icons.search),
              onChanged: (val) {
                _performSearch();
              },
            ),
          ),
          16.height,
          
          if (_isSearching)
            const CircularProgressIndicator(),

          if (!_isSearching && _searchResults.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['avatar_url'] != null
                          ? NetworkImage(user['avatar_url'])
                          : null,
                      child: user['avatar_url'] == null
                          ? Text((user['username'] as String)[0].toUpperCase())
                          : null,
                    ),
                    title: Text(user['display_name'] ?? user['username']),
                    subtitle: Text("@${user['username']}"),
                    onTap: () => _onUserTap(user),
                  );
                },
              ),
            ),

          if (!_isSearching && _searchResults.isEmpty)
            const Expanded(
              child: Center(
                child: Text("No users found"),
              ),
            ),
        ],
      ),
    );
  }
}