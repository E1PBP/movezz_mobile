import 'package:flutter/material.dart';

import '../../data/models/marketplace_model.dart';
import 'listing_card.dart';

class MarketplaceWidget extends StatelessWidget {
  final List<MarketplaceModel> listings;
  final void Function(MarketplaceModel listing)? onItemTap;
  final void Function(MarketplaceModel listing)? onEditTap;
  final void Function(MarketplaceModel listing)? onDeleteTap;
  final int? currentUserId;
  final Set<String> wishlistIds;
  final void Function(MarketplaceModel listing)? onWishlistTap;

  const MarketplaceWidget({
    super.key,
    required this.listings,
    this.onItemTap,
    this.onEditTap,
    this.onDeleteTap,
    this.currentUserId,
    this.wishlistIds = const {},
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const Center(
        child: Text('No listings available.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        final isOwner = listing.isMine;

        final isWishlisted =
            !isOwner && wishlistIds.contains(listing.pk);

        return ListingCard(
          listing: listing,
          onTap: () => onItemTap?.call(listing),

          onEdit: (isOwner && onEditTap != null)
              ? () => onEditTap!.call(listing)
              : null,
          onDelete: (isOwner && onDeleteTap != null)
              ? () => onDeleteTap!.call(listing)
              : null,

          isWishlisted: isWishlisted,
          onWishlistTap: (!isOwner && onWishlistTap != null)
              ? () => onWishlistTap!(listing)
              : null,
        );
      },
    );
  }
}