import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/feeds_controller.dart';
import '../widgets/feed_post_card.dart';

class FeedPostsList extends StatefulWidget {
  final String tab;
  const FeedPostsList({super.key, required this.tab});

  @override
  State<FeedPostsList> createState() => _FeedPostsListState();
}

class _FeedPostsListState extends State<FeedPostsList> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final controller = context.read<FeedsController>();
    if (controller.activeTab != widget.tab) return;

    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedsController>(
      builder: (context, controller, _) {
        // kalau bukan tab aktif, jangan render data tab lain (biar konsisten)
        if (controller.activeTab != widget.tab) {
          return const SizedBox.shrink();
        }

        final posts = controller.posts;

        if (controller.isLoadingInitial && posts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage != null && posts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, size: 42, color: Colors.grey.shade500),
                  12.height,
                  Text(
                    'Failed to load feeds',
                    style: boldTextStyle(size: 16),
                  ),
                  8.height,
                  Text(
                    controller.errorMessage!,
                    style: secondaryTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                  16.height,
                  AppButton(
                    text: 'Retry',
                    color: AppColors.primary,
                    textColor: Colors.white,
                    onTap: () => controller.refresh(),
                  )
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: posts.length + 1,
            itemBuilder: (context, index) {
              if (index == posts.length) {
                if (controller.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (!controller.hasNext) {
                  return const SizedBox(height: 100);
                }
                return const SizedBox(height: 60);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FeedPostCard(post: posts[index]),
              );
            },
          ),
        );
      },
    );
  }
}