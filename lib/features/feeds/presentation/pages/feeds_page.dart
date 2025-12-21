import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/feeds_controller.dart';
import '../widgets/feed_posts_list.dart';
import '../widgets/create_post_sheet.dart';

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [('For You', 'foryou'), ('Following', 'following')];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final tabKey = _tabs[_tabController.index].$2;
        context.read<FeedsController>().switchTab(tabKey);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedsController>().initIfNeeded();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CreatePostSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.layoutBackground,
      body: Column(
        children: [
          // "What's on your mind?" quick composer (SocialV-like)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.border,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                12.width,
                Expanded(
                  child: InkWell(
                    onTap: _openCreatePost,
                    borderRadius: radius(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: boxDecorationDefault(
                        color: AppColors.layoutBackground,
                        borderRadius: radius(16),
                      ),
                      child: Text(
                        "What's on your mind?",
                        style: secondaryTextStyle(size: 13),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _openCreatePost,
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  iconSize: 28,
                  padding: const EdgeInsets.all(12),
                  tooltip: 'Create Post',
                ),
              ],
            ),
          ),

          // Keep filtering tabs: "For You" & "Following"
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryBlack,
              unselectedLabelColor: AppColors.iconSecondaryDark,
              labelStyle: boldTextStyle(size: 13),
              unselectedLabelStyle: secondaryTextStyle(size: 13),
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              tabs: _tabs.map((t) => Tab(text: t.$1)).toList(growable: false),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: _tabs
                  .map((t) {
                    final tabKey = t.$2;
                    return FeedPostsList(tab: tabKey);
                  })
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}
