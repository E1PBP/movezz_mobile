import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/feeds_controller.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _text = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _hashtags = TextEditingController();
  final TextEditingController _sportId = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _text.dispose();
    _location.dispose();
    _hashtags.dispose();
    _sportId.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final text = _text.text.trim();
    if (text.isEmpty) {
      toast('Post cannot be empty');
      return;
    }

    setState(() => _submitting = true);
    try {
      final res = await context.read<FeedsController>().createPost(
        text: text,
        locationName: _location.text.trim(),
        hashtags: _hashtags.text.trim(),
        sportId: _sportId.text.trim(),
      );

      if (!mounted) return;

      if (res.success) {
        toast(res.message ?? 'Posted!');
        finish(context);
      } else {
        toast(res.message ?? 'Failed to create post');
      }
    } catch (e) {
      if (mounted) toast(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Create Post', style: boldTextStyle(size: 16)),
              ),
              IconButton(
                onPressed: () => finish(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          10.height,
          TextField(
            controller: _text,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Share your sport moment...",
              filled: true,
              fillColor: AppColors.layoutBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          12.height,
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _location,
                  decoration: InputDecoration(
                    hintText: 'Location (optional)',
                    filled: true,
                    fillColor: AppColors.layoutBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              10.width,
              Expanded(
                child: TextField(
                  controller: _hashtags,
                  decoration: InputDecoration(
                    hintText: 'Hashtags (comma)',
                    filled: true,
                    fillColor: AppColors.layoutBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          10.height,
          TextField(
            controller: _sportId,
            decoration: InputDecoration(
              hintText: 'Sport ID (optional, from backend)',
              filled: true,
              fillColor: AppColors.layoutBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          16.height,
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: _submitting ? 'Posting...' : 'Post',
              color: AppColors.primary,
              textColor: Colors.white,
              onTap: _submitting ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}