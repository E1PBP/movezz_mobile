import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/marketplace_model.dart';

class MarketplaceRemoteDataSource {
  final http.Client client;

  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000', 
  );

  static const String _listingsPath = '/marketplace/api/listings/';

  MarketplaceRemoteDataSource({required this.client});

  Future<List<MarketplaceModel>> getListings() async {
    final uri = Uri.parse('$_baseUrl$_listingsPath');

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .map(
              (item) =>
                  MarketplaceModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          'Unexpected response format: expected List, got ${decoded.runtimeType}',
        );
      }
    } else {
      throw Exception(
        'Failed to load listings. Status code: ${response.statusCode}',
      );
    }
  }

  Future<MarketplaceModel> getListingDetail(String id) async {
    final String path = '/marketplace/api/listings/$id/'; // sesuaikan kalau beda
    final uri = Uri.parse('$_baseUrl$path');

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return MarketplaceModel.fromJson(decoded);
      } else if (decoded is List && decoded.isNotEmpty) {
        // Django serializers.serialize biasanya balikin list berisi 1 elemen
        return MarketplaceModel.fromJson(
          decoded.first as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Unexpected response format for detail: ${decoded.runtimeType}',
        );
      }
    } else {
      throw Exception(
        'Failed to load listing detail. Status code: ${response.statusCode}',
      );
    }
  }
}