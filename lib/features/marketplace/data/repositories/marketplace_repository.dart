import '../datasources/marketplace_remote_data_source.dart';
import '../models/marketplace_model.dart';

class MarketplaceRepository {
  final MarketplaceRemoteDataSource remote;

  MarketplaceRepository(this.remote);

  Future<List<MarketplaceModel>> fetchListings() async {
    try {
      final listings = await remote.getListings();
      return listings;
    } catch (e) {
      rethrow;
    }
  }

  Future<MarketplaceModel> fetchListingDetail(String id) async {
    try {
      final listing = await remote.getListingDetail(id);
      return listing;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createListing({
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
    String? description,
  }) async {
    try {
      final id = await remote.createListing(
        title: title,
        price: price,
        location: location,
        imageUrl: imageUrl,
        condition: condition,
        description: description,
      );
      return id;
    } catch (e) {
      rethrow;
    }
  }
}