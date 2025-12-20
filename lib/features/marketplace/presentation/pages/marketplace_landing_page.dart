import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../controllers/marketplace_controller.dart';
import '../../data/models/marketplace_model.dart';
import '../widgets/marketplace_widget.dart';
import '../widgets/listing_card.dart';
import 'listing_detail_page.dart';
import 'marketplace_page.dart';
import 'my_listings_page.dart';

class MarketplaceLandingPage extends StatefulWidget {
  const MarketplaceLandingPage({super.key});

  @override
  State<MarketplaceLandingPage> createState() => _MarketplaceLandingPageState();
}

class _MarketplaceLandingPageState extends State<MarketplaceLandingPage> {
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
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    final int? currentUserId = request.jsonData['pk'] is int
        ? request.jsonData['pk'] as int
        : int.tryParse(request.jsonData['pk']?.toString() ?? '');

    return Consumer<MarketplaceController>(
      builder: (context, controller, child) {
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: controller.refreshListings,
            child: _buildBody(
              context: context,
              controller: controller,
              currentUserId: currentUserId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required MarketplaceController controller,
    required int? currentUserId,
  }) {
    if (controller.isLoading && controller.listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null &&
        controller.errorMessage!.isNotEmpty &&
        controller.listings.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Center(child: Text(controller.errorMessage!)),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: controller.loadListings,
              child: const Text('Try again'),
            ),
          ),
        ],
      );
    }

    if (controller.listings.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No listings available.')),
        ],
      );
    }

    final all = controller.listings;

    final List<MarketplaceModel> listingsSection = all.length <= 10
        ? all
        : all.sublist(0, 10);

    final List<MarketplaceModel> myListingsSection = all
        .where((listing) => listing.isMine)
        .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 0),
          const _BannerSection(),
          const SizedBox(height: 5),

          _SectionHeader(
            title: 'Listings',
            actionText: 'Show all',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketplacePage()),
              );
            },
          ),
          const SizedBox(height: 0),
          _ListingsHorizontalSection(
            listings: listingsSection,
            wishlistIds: controller.wishlistIds,
            onItemTap: (item) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ListingDetailPage(listing: item),
                ),
              );
            },
            onWishlistTap: (item) {
              context.read<MarketplaceController>().toggleWishlist(item.pk);
            },
          ),

          const SizedBox(height: 10),

          _SectionHeader(
            title: 'Manage Listings',
            actionText: 'Show all',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyListingsPage()),
              );
            },
          ),
          const SizedBox(height: 0),
          SizedBox(
            height: 480,
            child: MarketplaceWidget(
              listings: myListingsSection,
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
              onWishlistTap: (item) {
                context.read<MarketplaceController>().toggleWishlist(item.pk);
              },
              onEditTap: null,
              onDeleteTap: null,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// banner, bisa diganti2 isinya
class _BannerSection extends StatelessWidget {
  const _BannerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 209, 56, 66),
            Color.fromARGB(255, 205, 139, 133),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Christmas Sale!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Up to 80% OFF on selected items',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onTap;

  const _SectionHeader({required this.title, this.actionText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          if (actionText != null)
            TextButton(onPressed: onTap, child: Text(actionText!)),
        ],
      ),
    );
  }
}

class _ListingsHorizontalSection extends StatelessWidget {
  final List<MarketplaceModel> listings;
  final Set<String> wishlistIds;
  final void Function(MarketplaceModel listing)? onItemTap;
  final void Function(MarketplaceModel listing)? onWishlistTap;

  const _ListingsHorizontalSection({
    required this.listings,
    required this.wishlistIds,
    this.onItemTap,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No listings available.')),
      );
    }

    return SizedBox(
      height: 260,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: listings.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final listing = listings[index];
          final isOwner = listing.isMine;

          final isWishlisted = !isOwner && wishlistIds.contains(listing.pk);

          return SizedBox(
            width: 200,
            child: ListingCard(
              listing: listing,
              onTap: () => onItemTap?.call(listing),
              onEdit: null,
              onDelete: null,
              isWishlisted: isWishlisted,
              onWishlistTap: (!isOwner && onWishlistTap != null)
                  ? () => onWishlistTap!(listing)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
