import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/profile_controller.dart';
import '../../data/models/post_model.dart';
import '../pages/post_detail_page.dart';

class ProfilePostsGrid extends StatelessWidget {
  const ProfilePostsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        final PostEntry? postsEntry = controller.postsEntry;
        final bool isLoading = controller.isLoadingPosts;
        
        if (isLoading && (postsEntry == null || postsEntry.posts.isEmpty)) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (postsEntry == null || postsEntry.posts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.photo_library_outlined,
                  size: 40,
                  color: Color(0xFFA3A3A3),
                ),
                SizedBox(height: 8),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final posts = postsEntry.posts;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final post = posts[index];

            final hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;

            return GestureDetector(
              onTap: () {
                final profile = controller.profile;
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
                borderRadius: BorderRadius.circular(16),
                child: hasImage
                    ? Image.network(
                        post.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return _PostPlaceholder(caption: post.caption);
                        },
                      )
                    : _PostPlaceholder(caption: post.caption),
              ),
            );
          },
        );
      },
    );
  }
}

class _PostPlaceholder extends StatelessWidget {
  final String caption;

  const _PostPlaceholder({required this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.image_outlined,
              size: 28,
              color: Color(0xFFA3A3A3),
            ),
          ),
          if (caption.isNotEmpty)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                  ),
                ),
                child: Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
