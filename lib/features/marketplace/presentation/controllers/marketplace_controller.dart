import 'package:flutter/foundation.dart';

import '../../data/repositories/marketplace_repository.dart';
import '../../data/models/marketplace_model.dart';

class MarketplaceController extends ChangeNotifier {
  final MarketplaceRepository repository;

  MarketplaceController(this.repository);

  bool _isLoading = false;
  String? _errorMessage;
  List<MarketplaceModel> _listings = [];

  MarketplaceModel? _selectedListing;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MarketplaceModel> get listings => _listings;
  MarketplaceModel? get selectedListing => _selectedListing;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setListings(List<MarketplaceModel> data) {
    _listings = data;
    notifyListeners();
  }

  void _setSelectedListing(MarketplaceModel? listing) {
    _selectedListing = listing;
    notifyListeners();
  }

  Future<void> loadListings() async {
    _setLoading(true);
    _setError(null);

    try {
      final data = await repository.fetchListings();
      _setListings(data);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshListings() async {
    await loadListings();
  }

  Future<void> loadListingDetail(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final listing = await repository.fetchListingDetail(id);
      _setSelectedListing(listing);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clearSelectedListing() {
    _setSelectedListing(null);
  }

  Future<String> createListing({
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
    String? description,
  }) async {
    _setError(null);

    _setLoading(true);

    try {
      final id = await repository.createListing(
        title: title,
        price: price,
        location: location,
        imageUrl: imageUrl,
        condition: condition,
        description: description,
      );

      final data = await repository.fetchListings();
      _setListings(data);

      return id;
    } catch (e) {
      final msg = e.toString();
      _setError(msg);
      throw Exception(msg);
    } finally {
      _setLoading(false);
    }
  }
}