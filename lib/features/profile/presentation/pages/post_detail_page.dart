import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/post_model.dart';
import '../../data/models/profile_model.dart';
import '../controllers/profile_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/extensions.dart';
import 'package:flutter/services.dart';
import 'package:movezz_mobile/core/config/env.dart';
import '../widgets/comment_page.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  final ProfileEntry profile;

  const PostDetailPage({super.key, required this.post, required this.profile});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late String currentCaption;
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    currentCaption = widget.post.caption;
    isLiked = widget.post.hasLiked;
    likeCount = widget.post.likesCount;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        "${widget.post.createdAt.day}/${widget.post.createdAt.month}/${widget.post.createdAt.year}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Post",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          // BUTTON TITIK TIGA
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context);
              } else if (value == 'delete') {
                _showDeleteDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Edit Post', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Delete Post',
                      style: TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child:
                          (widget.profile.avatarUrl != null &&
                              widget.profile.avatarUrl.toString().isNotEmpty)
                          ? Image.network(
                              widget.profile.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) =>
                                  SvgPicture.asset(
                                    'assets/icon/logo-navbar.svg',
                                    fit: BoxFit.cover,
                                  ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: SvgPicture.asset(
                                'assets/icon/logo-navbar.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.profile.displayName ??
                                  widget.profile.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (widget.profile.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                        if (widget.post.location != null &&
                            widget.post.location!.isNotEmpty)
                          Text(
                            widget.post.location!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // IMAGE
            if (widget.post.imageUrl != null)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 200),
                color: Colors.grey[100],
                child: Image.network(
                  widget.post.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),

            // ACTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  // Tombol LIKE
                  InkWell(
                    onTap: _handleLike,
                    child: Row(
                      children: [
                        Icon(
                          isLiked
                              ? Icons.favorite
                              : Icons.favorite_border_rounded,
                          size: 24,
                          color: isLiked ? Colors.red : Colors.black87,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          likeCount.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Comment Button
                  _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: widget.post.commentsCount.toString(),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled:
                            true, // Supaya bisa full height / custom height
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            CommentBottomSheet(postId: widget.post.id),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  // Share Button
                  _ActionButton(
                    icon: Icons.share_outlined,
                    label: "Share",
                    onTap: _handleShare,
                  ),
                ],
              ),
            ),

            // CAPTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: "${widget.profile.username} ",
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: currentCaption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Created at : $dateStr",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  if (widget.post.sport != null &&
                      widget.post.sport!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildHashtagChip(
                          label: "#${widget.post.sport}",
                          color: const Color(0xFFA3E635),
                          textColor: const Color(0xFF3F6212),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Delete Modal
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 308,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 4,
                offset: Offset(0, 2),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 6,
                offset: Offset(0, 4),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO: tambah logo movezz
              const SizedBox(height: 12),
              const Text(
                'Delete Post?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF171717),
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This action is permanent and cannot be undone. Are you sure you want to permanently remove this post from your profile?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF525252),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF97316)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFFF97316),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final success = await context
                            .read<ProfileController>()
                            .deletePost(widget.post.id);
                        if (mounted) {
                          Navigator.pop(ctx);
                          if (success) {
                            Navigator.pop(context);
                            context.showSnackBar(
                              "Post deleted successfully",
                              isError: false,
                            );
                          } else {
                            context.showSnackBar(
                              "Failed to delete post",
                              isError: true,
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Color(0xFFFFF7ED),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final editController = TextEditingController(text: currentCaption);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: 308,
          padding: const EdgeInsets.all(12),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 4,
                offset: Offset(0, 2),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 6,
                offset: Offset(0, 4),
                spreadRadius: -1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Post',
                style: TextStyle(
                  color: Color(0xFF171717),
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${widget.profile.username}',
                style: const TextStyle(
                  color: Color(0xFF525252),
                  fontSize: 12,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Edit Text Field
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFA3A3A3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: TextField(
                  controller: editController,
                  maxLines: 4,
                  style: const TextStyle(
                    color: Color(0xFF171717),
                    fontSize: 12,
                  ),
                  decoration: const InputDecoration.collapsed(
                    hintText: "Write a caption...",
                    hintStyle: TextStyle(
                      color: Color(0xFFA3A3A3),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF365314),
                          ), // Lime-900 border for Cancel
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF365314),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final newText = editController.text;
                        final success = await context
                            .read<ProfileController>()
                            .updatePost(widget.post.id, newText);

                        if (mounted) {
                          Navigator.pop(ctx);
                          if (success) {
                            setState(() {
                              currentCaption = newText;
                            });
                            context.showSnackBar(
                              "Post updated!",
                              isError: false,
                            );
                          } else {
                            context.showSnackBar(
                              "Failed to update post",
                              isError: true,
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3E635),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            color: Color(0xFF365314),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleShare() {
    final String shareUrl =
        "${Env.backendBaseUrl}/profile/u/${widget.profile.username}/p/${widget.post.id}/";

    Clipboard.setData(ClipboardData(text: shareUrl));
    context.showSnackBar("Link copied to clipboard!", isError: false);
  }

  void _handleLike() async {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });

    final success = await context.read<ProfileController>().togglePostLike(
      widget.post.id,
    );

    if (!success && mounted) {
      setState(() {
        isLiked = !isLiked;
        likeCount += isLiked ? 1 : -1;
      });
      context.showSnackBar("Failed to like post", isError: true);
    }
  }

  Widget _buildHashtagChip({
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
