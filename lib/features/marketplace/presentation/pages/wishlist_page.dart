import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../controllers/marketplace_controller.dart';
import '../../data/models/marketplace_model.dart';
import '../widgets/marketplace_widget.dart';
import 'listing_detail_page.dart';
import 'listing_form_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<MarketplaceController>();
      controller.loadWishlistIds();
      controller.loadWishlistListings();
    });
  }

  Future<void> _openEditListingForm(MarketplaceModel listing) async {
    final fields = listing.fields;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingFormPage(
          initialTitle: fields.title,
          initialPrice: fields.price,
          initialLocation: fields.location,
          initialImageUrl: fields.imageUrl,
          initialCondition: fields.condition,
          onSubmit: ({
            required String title,
            required int price,
            required String location,
            required String imageUrl,
            required Condition condition,
          }) async {
            await context.read<MarketplaceController>().updateListing(
                  id: listing.pk,
                  title: title,
                  price: price,
                  location: location,
                  imageUrl: imageUrl,
                  condition: condition,
                );

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing successfully updated')),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDeleteListing(MarketplaceModel listing) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listing deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    final int? currentUserId = request.jsonData['pk'] is int
        ? request.jsonData['pk'] as int
        : int.tryParse(request.jsonData['pk']?.toString() ?? '');

    return Consumer<MarketplaceController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Wishlist'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.loadWishlistIds();
              await controller.loadWishlistListings();
            },
            child: _buildBody(controller, currentUserId),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    MarketplaceController controller,
    int? currentUserId,
  ) {
    if (controller.isLoading && controller.wishlistListings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null &&
        controller.errorMessage!.isNotEmpty &&
        controller.wishlistListings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(controller.errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                controller.loadWishlistIds();
                controller.loadWishlistListings();
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (controller.wishlistListings.isEmpty) {
      return const Center(
        child: Text('No items in your wishlist.'),
      );
    }

    return MarketplaceWidget(
      listings: controller.wishlistListings,
      currentUserId: currentUserId,
      wishlistIds: controller.wishlistIds,
      onItemTap: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListingDetailPage(listing: item),
          ),
        );
      },
      onEditTap: _openEditListingForm,
      onDeleteTap: _confirmDeleteListing,
      onWishlistTap: (item) {
        context.read<MarketplaceController>().toggleWishlist(item.pk);
      },
    );
  }
}