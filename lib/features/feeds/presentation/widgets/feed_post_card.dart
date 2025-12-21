import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movezz_mobile/core/config/env.dart';
import 'package:movezz_mobile/core/utils/extensions.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../profile/presentation/pages/profile_page.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/feeds_model.dart';
import '../controllers/feeds_controller.dart';
import 'feed_comments_sheet.dart';

class _HashtagChip extends StatelessWidget {
  final String tag;
  const _HashtagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => toast('Hashtag: #$tag'),
      borderRadius: radius(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: radius(100),
        ),
        child: Text(
          '#$tag',
          style: primaryTextStyle(color: AppColors.primary, size: 12),
        ),
      ),
    );
  }
}

class _CaptionWithInlineHashtags extends StatelessWidget {
  final String text;
  final List<String> hashtags;
  final TextStyle? style;

  const _CaptionWithInlineHashtags({
    required this.text,
    this.hashtags = const [],
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty) {
      return Text(text, style: style);
    }

    final spans = <TextSpan>[];
    final pattern = RegExp(r'(#\w+)');
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        final tag = match.group(0);
        if (tag != null) {
          spans.add(
            TextSpan(
              text: tag,
              style: (style ?? const TextStyle()).copyWith(
                color: AppColors.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  toast('Hashtag: $tag');
                },
            ),
          );
        }
        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(text: nonMatch, style: style));
        return '';
      },
    );

    return RichText(
      text: TextSpan(
        style: style ?? primaryTextStyle(size: 14),
        children: spans,
      ),
    );
  }
}

class _ImageSection extends StatefulWidget {
  final List<String> imageUrls;
  const _ImageSection({required this.imageUrls});

  @override
  State<_ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<_ImageSection> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => index = i),
            itemBuilder: (context, index) {
              return Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          if (widget.imageUrls.length > 1)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${index + 1}/${widget.imageUrls.length}',
                  style: secondaryTextStyle(color: Colors.white, size: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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

  void _handleShare(BuildContext context, FeedPost post) {
    final String shareUrl =
        "${Env.backendBaseUrl}/profile/u/${post.username}/p/${post.id}/";

    Clipboard.setData(ClipboardData(text: shareUrl));
    context.showSnackBar("Link copied to clipboard!", isError: false);
  }

  void _onProfileTap(BuildContext context) {
    final authController = context.read<AuthController>();
    final currentUser = authController.currentUser;

    if (currentUser == null || currentUser.username == post.username) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final request = context.read<CookieRequest>();
          return ChangeNotifierProvider(
            create: (_) => ProfileController(
              ProfileRepository(ProfileRemoteDataSource(request)),
            ),
            child: ProfilePage(username: post.username, showBackButton: true),
          );
        },
      ),
    );
  }

  String _createdAtText(FeedPost post) {
    try {
      final dynamic p = post;
      final raw = p.createdAtRaw;
      if (raw is String && raw.trim().isNotEmpty) return raw.trim();
    } catch (_) {}

    try {
      final dynamic p = post;
      final dt = p.createdAt;
      if (dt is DateTime) return dt.timeAgo;
    } catch (_) {}

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FeedsController>();
    final createdAtText = _createdAtText(post);

    return Container(
      decoration: boxDecorationDefault(
        color: context.cardColor,
        borderRadius: radius(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _onProfileTap(context),
                    borderRadius: BorderRadius.circular(8),
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
                                  if (createdAtText.isNotEmpty) ...[
                                    8.width,
                                    Text(
                                      '•',
                                      style: secondaryTextStyle(size: 12),
                                    ),
                                    8.width,
                                    Text(
                                      createdAtText,
                                      style: secondaryTextStyle(size: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.more_horiz),
                // ),
              ],
            ),
          ),

          // BODY: text + chips
          if (post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _CaptionWithInlineHashtags(
                text: post.text,
                hashtags: post.hashtags,
                style: primaryTextStyle(size: 14),
              ),
            ),

          if (post.hashtags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.hashtags
                    .map((t) => _HashtagChip(tag: t))
                    .toList(),
              ),
            ),

          if (post.imageUrls.isNotEmpty) ...[
            10.height,
            _ImageSection(imageUrls: post.imageUrls),
          ],

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
                  onTap: () => _handleShare(context, post),
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
