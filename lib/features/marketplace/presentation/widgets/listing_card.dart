import 'package:flutter/material.dart';
import '../../data/models/marketplace_model.dart';

class ListingCard extends StatelessWidget {
  final MarketplaceModel listing;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onWishlistTap,
    this.isWishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    final fields = listing.fields;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail / gambar
              SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: fields.imageUrl.isNotEmpty
                            ? Image.network(
                              fields.imageUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              width: 72,
                              height: 72,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            ),
                        ),
                        if (onWishlistTap != null)
                          Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: onWishlistTap,
                            child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: isWishlisted ? Colors.pink : Colors.grey.shade600,
                            ),
                            ),
                          ),
                          ),
                        ],
                      ),
                      ),

                      const SizedBox(width: 12),

              // Info + action
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fields.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${fields.price}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            fields.location,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            tooltip: 'Edit listing',
                            onPressed: onEdit,
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            tooltip: 'Delete listing',
                            onPressed: onDelete,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}