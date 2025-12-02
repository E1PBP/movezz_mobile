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

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: listings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = listings[index];
        final ownerId = item.fields.owner;
        final isOwner = item.isMine;
        final isWishlisted = wishlistIds.contains(item.pk);
         
        return ListingCard(
          listing: item,
          onTap: () => onItemTap?.call(item),
          onEdit: (isOwner && onEditTap != null)
              ? () => onEditTap!.call(item)
              : null,
          onDelete: (isOwner && onDeleteTap != null)
              ? () => onDeleteTap!.call(item)
              : null,
            
          isWishlisted: isWishlisted,
          onWishlistTap: onWishlistTap != null
              ? () => onWishlistTap!(item)
              : null,
        );
      },
    );
  }
}