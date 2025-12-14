import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/feeds_model.dart';
import '../controllers/feeds_controller.dart';
import 'feed_comments_sheet.dart';

class FeedPostCard extends StatelessWidget {
  final FeedPost post;
  const FeedPostCard({super.key, required this.post});

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => FeedCommentsSheet(post: post),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FeedsController>();

    return Container(
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: radius(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: avatar + name + badges + time
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(url: post.avatarUrl),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.displayName.isNotEmpty
                                  ? post.displayName
                                  : post.username,
                              style: boldTextStyle(size: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.badgeIconUrls.isNotEmpty) ...[
                            6.width,
                            ...post.badgeIconUrls
                                .take(3)
                                .map((u) => _BadgeIcon(url: u)),
                          ],
                        ],
                      ),
                      2.height,
                      Row(
                        children: [
                          Text(
                            '@${post.username}',
                            style: secondaryTextStyle(size: 12),
                          ),
                          if ((post.createdAtRaw ?? '').isNotEmpty) ...[
                            8.width,
                            Text('•', style: secondaryTextStyle(size: 12)),
                            8.width,
                            Text(
                              post.createdAtRaw!,
                              style: secondaryTextStyle(size: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
          ),

          // BODY: text + chips
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(post.text, style: primaryTextStyle(size: 14)),
            ),

          if ((post.sport != null && post.sport!.trim().isNotEmpty) ||
              (post.locationName != null &&
                  post.locationName!.trim().isNotEmpty))
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (post.sport != null && post.sport!.trim().isNotEmpty)
                    _Chip(icon: Icons.sports_soccer, label: post.sport!),
                  if (post.locationName != null &&
                      post.locationName!.trim().isNotEmpty)
                    _Chip(
                      icon: Icons.location_on_outlined,
                      label: post.locationName!,
                    ),
                ],
              ),
            ),

          12.height,

          // ACTION ROW: like/comment/share
          Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: [
                _ActionButton(
                  icon: post.hasLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.hasLiked ? Colors.red : null,
                  label: '${post.likesCount}',
                  onTap: controller.isLiking(post.id)
                      ? null
                      : () => controller.toggleLike(post),
                ),
                10.width,
                _ActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: '${post.commentsCount}',
                  onTap: () => _openComments(context),
                ),
                const Spacer(),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    toast('Share is not implemented yet');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return const CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.border,
        child: Icon(Icons.person, color: Colors.white),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundImage: NetworkImage(url!),
      backgroundColor: AppColors.border,
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final String url;
  const _BadgeIcon({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.verified, size: 12, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.layoutBackground,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          6.width,
          Text(label, style: secondaryTextStyle(size: 12)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: radius(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? context.iconColor),
            6.width,
            Text(label, style: secondaryTextStyle(size: 12)),
          ],
        ),
      ),
    );
  }
}
