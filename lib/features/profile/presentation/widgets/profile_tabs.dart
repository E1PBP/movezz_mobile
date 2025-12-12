import 'package:flutter/material.dart';
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
        // HEADER
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
              Align(
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
              if (controller.isLoadingPosts) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = controller.postsEntry?.posts ?? [];

              if (posts.isEmpty) {
                return _buildEmptyState('No posts yet');
              }

              return _buildPostsGrid(context, posts, controller.profile);
            } else {
              return _buildEmptyState('No broadcasts yet');
            }
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        ),
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
            } else {
              print("Profile data is null, cannot navigate");
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
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
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
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
