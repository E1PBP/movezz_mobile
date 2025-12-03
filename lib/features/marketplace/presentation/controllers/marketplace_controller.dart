import 'package:flutter/foundation.dart';

import '../../data/repositories/marketplace_repository.dart';
import '../../data/models/marketplace_model.dart';

class MarketplaceController extends ChangeNotifier {
  final MarketplaceRepository repository;

  MarketplaceController(this.repository);

  bool _isLoading = false;
  String? _errorMessage;
  List<MarketplaceModel> _listings = [];
  List<MarketplaceModel> _wishlistListings = [];

  MarketplaceModel? _selectedListing;
  String _searchQuery = '';
  Condition? _conditionFilter;

  Set<String> _wishlistIds = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MarketplaceModel> get listings => _listings;
  MarketplaceModel? get selectedListing => _selectedListing;
  String get searchQuery => _searchQuery;
  Condition? get conditionFilter => _conditionFilter;
  Set<String> get wishlistIds => _wishlistIds;
  List<MarketplaceModel> get wishlistListings => _wishlistListings;

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

  void _setWishlistIds(Set<String> ids) {
    _wishlistIds = ids;
    notifyListeners();
  }
  
  void _setWishlistListings(List<MarketplaceModel> data) {
    _wishlistListings = data;
    notifyListeners();
  }

  Future<void> loadListings({String? searchQuery, Condition? condition}) async {
    _setLoading(true);
    _setError(null);

    if (searchQuery != null) {
      _searchQuery = searchQuery;
    }
    _conditionFilter = condition;

    try {
      final effectiveQuery = _searchQuery.trim().isEmpty
          ? null
          : _searchQuery.trim();

      final data = await repository.fetchListings(
        searchQuery: effectiveQuery,
        conditionFilter: _conditionFilter,
      );

      _setListings(data);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshListings() async {
    await loadListings(searchQuery: _searchQuery, condition: _conditionFilter);
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
    required String description,
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

      final effectiveQuery = _searchQuery.trim().isEmpty
          ? null
          : _searchQuery.trim();

      final data = await repository.fetchListings(
        searchQuery: effectiveQuery,
        conditionFilter: _conditionFilter,
      );
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

  Future<void> updateListing({
    required String id,
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
    required String description,
  }) async {
    _setError(null);
    _setLoading(true);

    try {
      await repository.updateListing(
        id: id,
        title: title,
        price: price,
        location: location,
        imageUrl: imageUrl,
        condition: condition,
        description: description,
      );

      final effectiveQuery = _searchQuery.trim().isEmpty
          ? null
          : _searchQuery.trim();

      final data = await repository.fetchListings(
        searchQuery: effectiveQuery,
        conditionFilter: _conditionFilter,
      );
      _setListings(data);
    } catch (e) {
      final msg = e.toString();
      _setError(msg);
      throw Exception(msg);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteListing(String id) async {
    _setError(null);
    _setLoading(true);

    try {
      await repository.deleteListing(id);

      if (_selectedListing != null && _selectedListing!.pk == id) {
        _setSelectedListing(null);
      }

      final effectiveQuery = _searchQuery.trim().isEmpty
          ? null
          : _searchQuery.trim();

      final data = await repository.fetchListings(
        searchQuery: effectiveQuery,
        conditionFilter: _conditionFilter,
      );
      _setListings(data);
    } catch (e) {
      final msg = e.toString();
      _setError(msg);
      throw Exception(msg);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadWishlistIds() async {
    try {
      final ids = await repository.fetchWishlistIds();
      _setWishlistIds(ids);
    } catch (e) {
      debugPrint('Failed to load wishlist ids: $e');
    }
  }

  Future<void> toggleWishlist(String listingId) async {
    _setError(null);

    try {
      final inWishlist = await repository.toggleWishlist(listingId);

      final updated = Set<String>.from(_wishlistIds);
      if (inWishlist) {
        updated.add(listingId);
      } else {
        updated.remove(listingId);
      }
      _setWishlistIds(updated);
    } catch (e) {
      final msg = e.toString();
      _setError(msg);
      throw Exception(msg);
    }
  }

  Future<void> loadWishlistListings() async {
    _setLoading(true);
    _setError(null);

    try {
      final data = await repository.fetchWishlistListings();
      _setWishlistListings(data);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
