import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/marketplace_controller.dart';
import '../../data/models/marketplace_model.dart';
import '../widgets/marketplace_widget.dart';
import 'listing_detail_page.dart';
import 'listing_form_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter/foundation.dart'; // untuk debugPrint

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceController>().loadListings();
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
                id: listing.pk, // ⬅️ pake pk
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
    final shouldDelete =
        await showDialog<bool>(
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Listing deleted')));
  }

  Future<void> _openCreateListingForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingFormPage(
          onSubmit:
              ({
                required String title,
                required int price,
                required String location,
                required String imageUrl,
                required Condition condition,
              }) async {
                await context.read<MarketplaceController>().createListing(
                  title: title,
                  price: price,
                  location: location,
                  imageUrl: imageUrl,
                  condition: condition,
                );

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Listing successfully created')),
                );
              },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // sesuaikan key-nya kalau di login JSON namanya beda (misal 'user_id' atau 'pk')
    final int? currentUserId = request.jsonData['pk'] is int
        ? request.jsonData['pk'] as int
        : int.tryParse(request.jsonData['pk']?.toString() ?? '');

    return Consumer<MarketplaceController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Marketplace')),
          body: RefreshIndicator(
            onRefresh: controller.refreshListings,
            child: _buildBody(controller, currentUserId),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openCreateListingForm,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(MarketplaceController controller, int? currentUserId) {
    if (controller.isLoading && controller.listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null &&
        controller.errorMessage!.isNotEmpty &&
        controller.listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(controller.errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.loadListings,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (controller.listings.isEmpty) {
      return const Center(child: Text('No listings available.'));
    }

    return MarketplaceWidget(
      listings: controller.listings,
      onItemTap: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListingDetailPage(listing: item)),
        );
      },
      onEditTap: _openEditListingForm,
      onDeleteTap: _confirmDeleteListing,
      currentUserId: currentUserId,
    );
  }
}
