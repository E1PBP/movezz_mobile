import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../features/feeds/presentation/pages/feeds_page.dart';
import '../../features/feeds/presentation/widgets/create_post_sheet.dart';
import '../../features/broadcast/presentation/pages/broadcast_page.dart';
import '../../features/marketplace/presentation/pages/marketplace_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/messages/presentation/widgets/new_chat_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/messages/presentation/controllers/messages_controller.dart';
import '../theme/app_theme.dart';

import 'package:movezz_mobile/features/profile/presentation/pages/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FeedsPage(),
    const BroadcastPage(),
    const MarketplacePage(),
    const MessagesPage(),
    const ProfilePage(),
  ];

  List<Widget>? _getAppBarActions() {
    Widget actionIcon(IconData icon, String tooltip, VoidCallback onTap) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius(12),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: radius(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.primaryBlack),
            ),
          ),
        ),
      );
    }

    switch (_selectedIndex) {
      case 0:
        return [
          actionIcon(Icons.add, 'Create Post', () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CreatePostSheet(),
            );
          }),
        ];
      case 1:
        return [
          actionIcon(Icons.add, 'Create Broadcast', () {
            toast('Add Broadcast clicked!');
          }),
        ];
      case 2:
        return [
          actionIcon(Icons.add, 'Create Listing', () {
            toast('Add Listing clicked!');
          }),
        ];
      case 3:
        return [
          actionIcon(Icons.add, 'New Message', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewChatPage()),
            ).then((_) {
              if (mounted) {
                context.read<MessagesController>().fetchConversations();
              }
            });
          }),
        ];
      case 4:
        return [
          actionIcon(Icons.settings_outlined, 'Settings', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
        leadingWidth: 0,

        backgroundColor: context.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,

        title: Text(
          'Movezz',
          style: boldTextStyle(size: 22, color: AppColors.primaryBlack),
        ),
        centerTitle: false,
        titleSpacing: 16,

        actions: _getAppBarActions(),
      ),

      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: Container(
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
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          selectedItemColor: selectedColor,
          unselectedItemColor: Colors.grey,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home_filled),
              title: const Text("Home"),
              selectedColor: selectedColor,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.campaign_rounded),
              title: const Text("Events"),
              selectedColor: Colors.orange,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.shopping_bag_outlined),
              title: const Text("Shop"),
              selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text("Chat"),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              title: const Text("Profile"),
              selectedColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}
