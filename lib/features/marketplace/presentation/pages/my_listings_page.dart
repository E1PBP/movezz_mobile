import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import '../controllers/marketplace_controller.dart';
import '../../data/models/marketplace_model.dart';
import '../widgets/marketplace_widget.dart';
import 'listing_detail_page.dart';
import 'listing_form_page.dart';
import 'wishlist_page.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  final TextEditingController _searchController = TextEditingController();
  Condition? _selectedCondition;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<MarketplaceController>();
      controller.loadListings();
      controller.loadWishlistIds();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
  }

  Future<void> _confirmDeleteListing(MarketplaceModel listing) async {
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
  }

  Future<void> _openCreateListingForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingFormPage(
          onSubmit: ({
            required String title,
            required int price,
            required String location,
            required String imageUrl,
            required Condition condition,
            required String description,
          }) async {
            await context.read<MarketplaceController>().createListing(
              title: title,
              price: price,
              location: location,
              imageUrl: imageUrl,
              condition: condition,
              description: description,
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

    final int? currentUserId = request.jsonData['pk'] is int
        ? request.jsonData['pk'] as int
        : int.tryParse(request.jsonData['pk']?.toString() ?? '');

    return Consumer<MarketplaceController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "My Listings",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WishlistPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              _buildSearchAndFilterRow(controller),
              const SizedBox(height: 8),
              const SizedBox(height: 4),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshListings,
                  child: _buildBody(controller, currentUserId),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openCreateListingForm,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilterRow(MarketplaceController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search my listings...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                isDense: true,
              ),
              onSubmitted: (value) {
                controller.loadListings(
                  searchQuery: value,
                  condition: _selectedCondition,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Filter condition',
            color: Colors.grey.shade100,
            onSelected: (value) {
              if (value == 'ALL') {
                setState(() {
                  _selectedCondition = null;
                });

                controller.loadListings(
                  searchQuery: _searchController.text,
                  condition: null,
                );
              } else if (value == 'BRAND_NEW') {
                setState(() {
                  _selectedCondition = Condition.BRAND_NEW;
                });

                controller.loadListings(
                  searchQuery: _searchController.text,
                  condition: Condition.BRAND_NEW,
                );
              } else if (value == 'USED') {
                setState(() {
                  _selectedCondition = Condition.USED;
                });

                controller.loadListings(
                  searchQuery: _searchController.text,
                  condition: Condition.USED,
                );
              }
            },
            itemBuilder: (ctx) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'ALL', child: Text('All')),
              const PopupMenuItem<String>(
                value: 'BRAND_NEW',
                child: Text('Brand New'),
              ),
              const PopupMenuItem<String>(value: 'USED', child: Text('Used')),
            ],
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.tune, size: 18)),
                  if (_selectedCondition != null)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
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

    final myListings =
        controller.listings.where((listing) => listing.isMine).toList();

    if (myListings.isEmpty) {
      return const Center(
        child: Text("You don't have any listings yet."),
      );
    }

    return MarketplaceWidget(
      listings: myListings,
      onItemTap: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListingDetailPage(listing: item)),
        );
      },
      onEditTap: _openEditListingForm,
      onDeleteTap: _confirmDeleteListing,
      currentUserId: currentUserId,
      wishlistIds: controller.wishlistIds,
      onWishlistTap: (item) {
        context.read<MarketplaceController>().toggleWishlist(item.pk);
      },
    );
  }
}