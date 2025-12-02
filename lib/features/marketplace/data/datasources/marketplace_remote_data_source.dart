import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import 'package:movezz_mobile/core/config/env.dart';
import '../models/marketplace_model.dart';
import 'package:flutter/foundation.dart';

class MarketplaceRemoteDataSource {
  final CookieRequest cookieRequest;

  MarketplaceRemoteDataSource(this.cookieRequest);

  Future<List<MarketplaceModel>> getListings({
    String? searchQuery,
    Condition? condition,
  }) async {
    final baseUri = Uri.parse(Env.api('/marketplace/api/listings/'));

    final Map<String, String> params = {};

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      params['q'] = searchQuery.trim();
    }

    if (condition != null) {
      final conditionStr = conditionValues.reverse[condition];
      if (conditionStr != null) {
        params['condition'] = conditionStr;
      }
    }

    final uri = params.isEmpty
        ? baseUri
        : baseUri.replace(queryParameters: params);
        debugPrint('GET listings: $uri');
    final response = await cookieRequest.get(uri.toString());

    if (response is List) {
      return response.map((item) => MarketplaceModel.fromJson(item)).toList();
    } else {
      throw Exception('Invalid response format');
    }
  }

  Future<MarketplaceModel> getListingDetail(String id) async {
    final url = Env.api('/marketplace/api/listings/$id/');
    final response = await cookieRequest.get(url);

    if (response is List && response.isNotEmpty) {
      return MarketplaceModel.fromJson(response.first);
    } else if (response is Map<String, dynamic>) {
      return MarketplaceModel.fromJson(response);
    }

    throw Exception('Failed to load listing detail');
  }

  Future<String> createListing({
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
    String? description,
  }) async {
    final url = Env.api('/marketplace/api/listings/create-ajax/');

    final Map<String, String> body = {
      'title': title,
      'price': price.toString(),
      'location': location,
      'image_url': imageUrl,
      'condition': conditionValues.reverse[condition] ?? 'USED',
      'description': description ?? '',
    };

    final headers = Map<String, String>.from(cookieRequest.headers);
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['status'] == 'created' || decoded['status'] == 'ok') {
        return decoded['id'].toString();
      }
    } else if (response.statusCode == 302) {
      throw Exception('Session expired. Please log in again.');
    }

    throw Exception('Failed to create listing: ${response.body}');
  }

  Future<void> updateListing({
    required String id,
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
    String? description,
  }) async {
    final url = Env.api('/marketplace/listing/$id/edit-ajax/');

    final Map<String, String> body = {
      'title': title,
      'price': price.toString(),
      'location': location,
      'image_url': imageUrl,
      'condition': conditionValues.reverse[condition] ?? 'USED',
      'description': description ?? '',
    };

    final headers = Map<String, String>.from(cookieRequest.headers);
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return;
      }

      final decoded = jsonDecode(response.body);
      final status = decoded['status']?.toString().toLowerCase();

      if (status == 'updated' || status == 'ok' || status == 'success') {
        return;
      }

      throw Exception('Failed to update listing: ${response.body}');
    } else if (response.statusCode == 302) {
      throw Exception('Session expired. Please log in again.');
    }

    throw Exception('Failed to update listing: ${response.body}');
  }

  Future<void> deleteListing(String id) async {
    final url = Env.api('/marketplace/listing/$id/delete-ajax/');

    final headers = Map<String, String>.from(cookieRequest.headers);
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: const {},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      if (response.body.isEmpty) {
        return;
      }

      final decoded = jsonDecode(response.body);
      final status = decoded['status']?.toString().toLowerCase();

      if (status == 'deleted' || status == 'ok' || status == 'success') {
        return;
      }

      throw Exception('Gagal menghapus listing: ${response.body}');
    } else if (response.statusCode == 302) {
      throw Exception('Sesi habis. Silakan login kembali.');
    }

    throw Exception('Failed to delete listing: ${response.body}');
  }

  Future<Set<String>> getWishlistIds() async {
    final url = Env.api('/marketplace/api/wishlist/ids/');

    final response = await cookieRequest.get(url);

    if (response is List) {
      return response.map((e) => e.toString()).toSet();
    }

    throw Exception('Invalid wishlist_ids response: $response');
  }

  Future<bool> toggleWishlist(String listingId) async {
    final url = Env.api('/marketplace/api/wishlist/toggle/');

    final headers = Map<String, String>.from(cookieRequest.headers);
    headers['Content-Type'] = 'application/x-www-form-urlencoded';

    final body = {
      'listing_id': listingId,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Empty wishlist_toggle response');
      }

      final decoded = jsonDecode(response.body);

      final status = decoded['status']?.toString().toLowerCase();

      if (status == 'added') {
        return true;
      } else if (status == 'removed') {
        return false;
      }

      throw Exception('Unknown wishlist_toggle status: $status');
    } else if (response.statusCode == 302) {
      throw Exception('Session expired. Please log in again.');
    }

    throw Exception(
      'Failed to toggle wishlist (${response.statusCode}): ${response.body}',
    );
  }

  Future<List<MarketplaceModel>> getWishlistListings() async {
    final url = Env.api('/marketplace/api/wishlist/list/');

    final response = await cookieRequest.get(url);

    if (response is List) {
      return response.map((item) => MarketplaceModel.fromJson(item)).toList();
    }

    throw Exception('Invalid wishlist_listings response: $response');
  }
}
