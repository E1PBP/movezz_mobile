import 'package:flutter/material.dart';

import '../../data/models/marketplace_model.dart';

class ListingDetailPage extends StatelessWidget {
  final MarketplaceModel listing;

  const ListingDetailPage({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    final fields = listing.fields;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fields.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(fields.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildInfoSection(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final f = listing.fields;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          f.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Rp ${f.price}',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 18,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                f.location,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: Text(
                f.condition == Condition.BRAND_NEW ? 'New' : 'Used',
              ),
            ),
            Chip(
              avatar: const Icon(Icons.person, size: 18),
              label: Text('Owner ID: ${f.owner}'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'No additional description available for this product.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              // TODO: sambungkan ke fitur chat / contact owner kalau ada
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contact action not yet implemented.'),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Contact Owner'),
          ),
        ),
      ],
    );
  }
}