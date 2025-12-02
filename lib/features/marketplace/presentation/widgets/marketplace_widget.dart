import 'package:flutter/material.dart';

import '../../data/models/marketplace_model.dart';
import 'listing_card.dart';

class MarketplaceWidget extends StatelessWidget {
  final List<MarketplaceModel> listings;
  final void Function(MarketplaceModel listing)? onItemTap;
  final void Function(MarketplaceModel listing)? onEditTap;
  final void Function(MarketplaceModel listing)? onDeleteTap;

  const MarketplaceWidget({
    super.key,
    required this.listings,
    this.onItemTap,
    this.onEditTap,
    this.onDeleteTap,
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

        return ListingCard(
          listing: item,
          onTap: () => onItemTap?.call(item),
          onEdit: onEditTap != null ? () => onEditTap!.call(item) : null,
          onDelete: onDeleteTap != null ? () => onDeleteTap!.call(item) : null,
        );
      },
    );
  }
}