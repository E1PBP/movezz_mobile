import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:movezz_mobile/features/messages/presentation/controllers/messages_controller.dart';
import 'package:movezz_mobile/features/messages/presentation/widgets/chat_detail_page.dart';
import '../controllers/marketplace_controller.dart';
import '../../data/models/marketplace_model.dart';
import 'listing_form_page.dart';

class ListingDetailPage extends StatefulWidget {
  final MarketplaceModel listing;

  const ListingDetailPage({super.key, required this.listing});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceController>().loadListingDetail(
        widget.listing.pk,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MarketplaceController>().clearSelectedListing();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MarketplaceController>();

    final listing = controller.selectedListing ?? widget.listing;
    final fields = listing.fields;

    final bool isOwner = widget.listing.isMine || listing.isMine;
    final bool isWishlisted = controller.wishlistIds.contains(listing.pk);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Details",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: controller.isLoading && controller.selectedListing == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(context, fields.imageUrl),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildInfoSection(context, listing),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: isOwner
            ? _buildOwnerButtons(context, listing)
            : _buildBuyerButtons(context, listing, isWishlisted),
      ),
    );
  }

  Widget _buildOwnerButtons(BuildContext context, MarketplaceModel listing) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openEditListingForm(context, listing),
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => _confirmDeleteListing(context, listing),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ),
      ],
    );
  }

  Widget _buildBuyerButtons(
    BuildContext context,
    MarketplaceModel listing,
    bool isWishlisted,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 216, 27, 55),
              side: BorderSide(color: Colors.pink.shade200),
            ),
            onPressed: () {
              context.read<MarketplaceController>().toggleWishlist(listing.pk);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isWishlisted
                        ? 'Removed from wishlist'
                        : 'Added to wishlist',
                  ),
                ),
              );
            },
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: Colors.pink.shade400,
            ),
            label: const Text('Wishlist'),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              final ownerUsername = listing.fields.ownerUsername;
              if (ownerUsername.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Owner information is missing')),
                );
                return;
              }
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (c) =>
                    const Center(child: CircularProgressIndicator()),
              );

              try {
                final msgController = context.read<MessagesController>();
                final conversationId = await msgController.startChat(
                  ownerUsername,
                );

                if (context.mounted) Navigator.pop(context);

                if (conversationId != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailPage(
                        conversationId: conversationId,
                        otherUserName: ownerUsername,
                        otherUserDisplayName: ownerUsername,
                        otherUserAvatar: null,
                      ),
                    ),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to start conversation'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Contact Owner'),
          ),
        ),
      ],
    );
  }

Future<void> _openEditListingForm(
  BuildContext context,
  MarketplaceModel listing,
) async {
  final fields = listing.fields;

  final didUpdate = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => ListingFormPage(
        initialTitle: fields.title,
        initialPrice: fields.price,
        initialLocation: fields.location,
        initialImageUrl: fields.imageUrl,
        initialCondition: fields.condition,
        initialDescription: fields.description,
        onSubmit: ({
          required String title,
          required int price,
          required String location,
          required String imageUrl,
          required Condition condition,
          required String description,
        }) async {
          await context.read<MarketplaceController>().updateListing(
                id: listing.pk,
                title: title,
                price: price,
                location: location,
                imageUrl: imageUrl,
                condition: condition,
                description: description,
              );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing successfully updated')),
          );
        },
      ),
    ),
  );

  if (!mounted) return;
  if (didUpdate == true) {
    await context.read<MarketplaceController>().loadListingDetail(listing.pk);
  }
}

  Future<void> _confirmDeleteListing(
    BuildContext context,
    MarketplaceModel listing,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Colors.grey[100],
              title: const Text('Delete listing'),
              content: Text(
                'Are you sure you want to delete "${listing.fields.title}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) return;

    await context.read<MarketplaceController>().deleteListing(listing.pk);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Listing deleted')));

    Navigator.pop(context);
  }

  Widget _buildImageSection(BuildContext context, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  "http://10.0.2.2:8000/marketplace/proxy-image/?url=${Uri.encodeComponent(imageUrl)}",
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48),
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, MarketplaceModel listing) {
    final f = listing.fields;
    final theme = Theme.of(context);

    final bool isBrandNew = f.condition == Condition.BRAND_NEW;
    final String conditionLabel = isBrandNew ? 'Brand New' : 'Used';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConditionChip(label: conditionLabel, isBrandNew: isBrandNew),
        const SizedBox(height: 8),

        // Title
        Text(
          f.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Price
        Text(
          'Rp ${f.price}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),

        // Location row
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(f.location, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Description
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          f.description.isNotEmpty ? f.description : 'No description provided.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final String label;
  final bool isBrandNew;

  const _ConditionChip({required this.label, required this.isBrandNew});

  @override
  Widget build(BuildContext context) {
    final Color bg = isBrandNew
        ? Colors.green.withOpacity(0.15)
        : Colors.orange.withOpacity(0.15);

    final Color fg = isBrandNew
        ? Colors.green.shade700
        : Colors.orange.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: fg),
      ),
    );
  }
}
