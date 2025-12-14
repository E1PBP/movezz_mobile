import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/feeds_model.dart';
import '../controllers/feeds_controller.dart';

class FeedCommentsSheet extends StatefulWidget {
  final FeedPost post;
  const FeedCommentsSheet({super.key, required this.post});

  @override
  State<FeedCommentsSheet> createState() => _FeedCommentsSheetState();
}

class _FeedCommentsSheetState extends State<FeedCommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedsController>().loadComments(widget.post.id);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    await context.read<FeedsController>().addComment(
      post: widget.post,
      commentText: text,
    );
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<FeedsController>();
    final loading = c.isCommentsLoading(widget.post.id);
    final err = c.commentsError(widget.post.id);
    final comments = c.commentsFor(widget.post.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            8.height,
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            12.height,
            Text('Comments', style: boldTextStyle(size: 16)),
            12.height,
            Divider(height: 1, color: AppColors.border.withOpacity(0.6)),
            Expanded(
              child: loading && comments.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : err != null && comments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 40,
                              color: Colors.grey.shade500,
                            ),
                            12.height,
                            Text(
                              'Failed to load comments',
                              style: boldTextStyle(),
                            ),
                            8.height,
                            Text(
                              err,
                              style: secondaryTextStyle(),
                              textAlign: TextAlign.center,
                            ),
                            14.height,
                            AppButton(
                              text: 'Retry',
                              color: AppColors.primary,
                              textColor: Colors.white,
                              onTap: () => c.loadComments(widget.post.id),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final cm = comments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.border,
                                backgroundImage: cm.avatarUrl != null
                                    ? NetworkImage(cm.avatarUrl!)
                                    : null,
                                child: cm.avatarUrl == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              12.width,
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: boxDecorationDefault(
                                    color: AppColors.layoutBackground,
                                    borderRadius: radius(14),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              cm.author.isNotEmpty
                                                  ? cm.author
                                                  : cm.username,
                                              style: boldTextStyle(size: 13),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if ((cm.createdAtLabel ?? '')
                                              .isNotEmpty)
                                            Text(
                                              cm.createdAtLabel!,
                                              style: secondaryTextStyle(
                                                size: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                      6.height,
                                      Text(
                                        cm.text,
                                        style: primaryTextStyle(size: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Divider(height: 1, color: AppColors.border.withOpacity(0.6)),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          filled: true,
                          fillColor: AppColors.layoutBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    10.width,
                    IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}