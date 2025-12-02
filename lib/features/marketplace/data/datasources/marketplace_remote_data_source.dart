import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import 'package:movezz_mobile/core/config/env.dart';
import '../models/marketplace_model.dart';

class MarketplaceRemoteDataSource {
  final CookieRequest cookieRequest;

  MarketplaceRemoteDataSource(this.cookieRequest);

  Future<List<MarketplaceModel>> getListings() async {
    final url = Env.api('/marketplace/api/listings/');
    final response = await cookieRequest.get(url);

    if (response is List) {
      return response.map((item) => MarketplaceModel.fromJson(item)).toList();
    } else {
      throw Exception('Format respon tidak valid');
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

    throw Exception('Gagal memuat detail listing');
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

    final headers = cookieRequest.headers;
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
      throw Exception('Sesi habis. Silakan login kembali.');
    }

    throw Exception('Gagal membuat listing: ${response.body}');
  }
}
