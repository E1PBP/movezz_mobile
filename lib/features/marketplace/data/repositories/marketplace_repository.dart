import '../datasources/marketplace_remote_data_source.dart';
import '../models/marketplace_model.dart';

class MarketplaceRepository {
  final MarketplaceRemoteDataSource remote;

  MarketplaceRepository(this.remote);

  Future<List<MarketplaceModel>> fetchListings({
    String? searchQuery,
    Condition? conditionFilter,
  }) async {
      try {
        final listings = await remote.getListings(
          searchQuery: searchQuery,
          condition: conditionFilter,
        );
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
    required String description,
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

  Future<void> updateListing({
    required String id,
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
    required String description,
  }) async {
    try {
      await remote.updateListing(
        id: id,
        title: title,
        price: price,
        location: location,
        imageUrl: imageUrl,
        condition: condition,
        description: description,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await remote.deleteListing(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<Set<String>> fetchWishlistIds() async {
    try {
      final ids = await remote.getWishlistIds();
      return ids;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> toggleWishlist(String listingId) async {
    try {
      final inWishlist = await remote.toggleWishlist(listingId);
      return inWishlist;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MarketplaceModel>> fetchWishlistListings() async {
    try {
      final listings = await remote.getWishlistListings();
      return listings;
    } catch (e) {
      rethrow;
    }
  }
}
