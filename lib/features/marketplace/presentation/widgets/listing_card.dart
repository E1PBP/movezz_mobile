import 'package:flutter/material.dart';

import '../../data/models/marketplace_model.dart';

class ListingCard extends StatelessWidget {
  final MarketplaceModel listing;
  final VoidCallback? onTap;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fields = listing.fields;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(fields.imageUrl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildInfo(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl) {
    const double size = 80;

    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final f = listing.fields;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          f.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${f.price}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          f.location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          f.condition == Condition.BRAND_NEW ? 'New' : 'Used',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}