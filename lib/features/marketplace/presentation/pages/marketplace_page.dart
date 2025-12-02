import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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

WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketplaceController>().loadListings();
    });
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

            await context.read<MarketplaceController>().createListing(
              title: title,
              price: price,
              location: location,
              imageUrl: imageUrl,
              condition: condition,
            );

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing berhasil dibuat')),
            );
          },
        ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk mendengarkan perubahan state dari Controller
    return Consumer<MarketplaceController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Marketplace')),
          body: RefreshIndicator(
            onRefresh: controller.refreshListings,
            child: _buildBody(controller),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openCreateListingForm,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
Widget _buildBody(MarketplaceController controller) {
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
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (controller.listings.isEmpty) {
      return const Center(child: Text('Belum ada listing yang tersedia.'));
    }

    return MarketplaceWidget(
      listings: controller.listings,
      onItemTap: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ListingDetailPage(listing: item)),
        );
      },
    );
  }
}