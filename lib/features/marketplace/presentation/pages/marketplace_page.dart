import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/marketplace_remote_data_source.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../controllers/marketplace_controller.dart';
import '../../data/models/marketplace_model.dart';
import '../widgets/marketplace_widget.dart';
import 'listing_detail_page.dart';
import 'listing_form_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  late final MarketplaceController _controller;

  @override
  void initState() {
    super.initState();

    final client = http.Client();
    final remote = MarketplaceRemoteDataSource(client: client);
    final repo = MarketplaceRepository(remote);
    _controller = MarketplaceController(repo);

    _controller.addListener(_onControllerUpdated);

    _controller.loadListings();
  }

  void _onControllerUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdated);
    _controller.dispose();
    super.dispose();
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
          }) async {
            try {
              await _controller.createListing(
                title: title,
                price: price,
                location: location,
                imageUrl: imageUrl,
                condition: condition,
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing berhasil dibuat'),
                ),
              );
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal membuat listing: $e'),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: RefreshIndicator(
        onRefresh: _controller.refreshListings,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateListingForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.listings.isEmpty) {
      // Loading pertama kali
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null &&
        _controller.errorMessage!.isNotEmpty &&
        _controller.listings.isEmpty) {
      return _buildErrorState();
    }

    if (_controller.listings.isEmpty) {
      return _buildEmptyState();
    }

    return _buildList();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              'Terjadi kesalahan:\n${_controller.errorMessage}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _controller.loadListings,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Belum ada listing yang tersedia.'));
  }

  Widget _buildList() {
    return MarketplaceWidget(
      listings: _controller.listings,
      onItemTap: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListingDetailPage(listing: item)),
        );
      },
    );
  }
}
