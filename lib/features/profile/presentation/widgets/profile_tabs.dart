import 'package:flutter/material.dart';
import 'package:movezz_mobile/features/broadcast/presentation/widgets/broadcast_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/post_model.dart';
import '../../data/models/profile_model.dart';
import '../pages/post_detail_page.dart';

class ProfileTabs extends StatefulWidget {
  final String username;

  const ProfileTabs({super.key, required this.username});

  @override
  State<ProfileTabs> createState() => _ProfileTabsState();
}

class _ProfileTabsState extends State<ProfileTabs> {
  int _selectedIndex = 0; // 0 = Posts, 1 = Broadcasts

  @override
  Widget build(BuildContext context) {
    final isPosts = _selectedIndex == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildTab(
              index: 0,
              icon: Icons.grid_view_rounded,
              label: 'Posts',
              isSelected: isPosts,
            ),
            _buildTab(
              index: 1,
              icon: Icons.campaign_rounded,
              label: 'Broadcasts',
              isSelected: !isPosts,
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 2,
          width: double.infinity,
          child: Stack(
            children: [
              Container(color: const Color(0xFFE5E7EB)),
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: isPosts
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Consumer<ProfileController>(
          builder: (context, controller, _) {
            if (isPosts) {
              return _buildPostsContent(context, controller);
            } else {
              return _buildBroadcastsContent(context, controller);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPostsContent(
    BuildContext context,
    ProfileController controller,
  ) {
    if (controller.isLoadingPosts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final posts = controller.postsEntry?.posts ?? [];

    if (posts.isEmpty) {
      return _buildEmptyState('No posts yet');
    }

    return _buildPostsGrid(context, posts, controller.profile);
  }

  Widget _buildBroadcastsContent(
    BuildContext context,
    ProfileController controller,
  ) {
    if (controller.isLoadingBroadcasts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final broadcasts = controller.broadcasts;

    if (broadcasts.isEmpty) {
      return _buildEmptyState('No broadcasts yet');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: broadcasts.length,
      itemBuilder: (context, index) {
        final event = broadcasts[index];
        return EventCard(event: event);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsGrid(
    BuildContext context,
    List<Post> items,
    ProfileEntry? profile,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final post = items[index];
        final imageUrl = post.imageUrl;

        return GestureDetector(
          onTap: () {
            if (profile != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PostDetailPage(post: post, profile: profile),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildTab({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected ? AppColors.primary : const Color(0xFFA3A3A3);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => _selectedIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
