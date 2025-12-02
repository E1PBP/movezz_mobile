// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../models/marketplace_model.dart';

// class MarketplaceRemoteDataSource {
//   final http.Client client;

//   static const String _baseUrl = String.fromEnvironment(
//     'BACKEND_BASE_URL',
//     defaultValue: 'http://10.0.2.2:8000',
//   );

//   static const String _listingsPath = '/marketplace/api/listings/';
//   static const String _createListingPath = '/marketplace/api/listings/create-ajax/';

//   MarketplaceRemoteDataSource({required this.client});

//   Future<List<MarketplaceModel>> getListings() async {
//     final uri = Uri.parse('$_baseUrl$_listingsPath');

//     final response = await client.get(uri);

//     if (response.statusCode == 200) {
//       final dynamic decoded = jsonDecode(response.body);

//       if (decoded is List) {
//         final List<dynamic> list = decoded;

//         final List<MarketplaceModel> results = list
//             .map(
//               (item) =>
//                   MarketplaceModel.fromJson(item as Map<String, dynamic>),
//             )
//             .toList();

//         return results;
//       } else {
//         throw Exception(
//           'Unexpected response format: expected List, got ${decoded.runtimeType}',
//         );
//       }
//     } else {
//       throw Exception(
//         'Failed to load listings. Status code: ${response.statusCode}',
//       );
//     }
//   }

//   Future<MarketplaceModel> getListingDetail(String id) async {
//     final String path = '/marketplace/api/listings/$id/';
//     final uri = Uri.parse('$_baseUrl$path');

//     final response = await client.get(uri);

//     if (response.statusCode == 200) {
//       final dynamic decoded = jsonDecode(response.body);

//       if (decoded is Map<String, dynamic>) {
//         return MarketplaceModel.fromJson(decoded);
//       } else if (decoded is List && decoded.isNotEmpty) {
//         return MarketplaceModel.fromJson(
//           decoded.first as Map<String, dynamic>,
//         );
//       } else {
//         throw Exception(
//           'Unexpected response format for detail: ${decoded.runtimeType}',
//         );
//       }
//     } else {
//       throw Exception(
//         'Failed to load listing detail. Status code: ${response.statusCode}',
//       );
//     }
//   }

//   Future<String> createListing({
//     required String title,
//     required int price,
//     required String location,
//     required String imageUrl,
//     required Condition condition,
//     String? description,
//   }) async {
//     final uri = Uri.parse('$_baseUrl$_createListingPath');

//     final Map<String, String> body = {
//       'title': title,
//       'price': price.toString(),
//       'location': location,
//       'image_url': imageUrl,
//       'condition': conditionValues.reverse[condition] ?? 'USED',
//       'description': description ?? '',
//     };

//     final response = await client.post(
//       uri,
//       headers: {
//         'Accept': 'application/json',
//       },
//       body: body,
//     );

//     final int status = response.statusCode;
//     print('Response Status: $status');
//     print("response biody: ${response.body}");
//     final dynamic decoded = 
//         response.body.isNotEmpty ? jsonDecode(response.body) : null;

//     if (status == 201 || status == 200) {
//       if (decoded is Map<String, dynamic>) {
//         final statusField = decoded['status'];
//         final idField = decoded['id']?.toString();

//         if ((statusField == 'created' || statusField == 'ok') &&
//             idField != null &&
//             idField.isNotEmpty) {
//           return idField;
//         }

//         throw Exception('Unexpected response when creating listing');
//       } else {
//         throw Exception('Unexpected response format when creating listing');
//       }
//     } else {
//       String message = 'Failed to create listing. Status code: $status';

//       if (decoded is Map<String, dynamic>) {
//         final error = decoded['error'];
//         final msg = decoded['message'];
//         if (error != null || msg != null) {
//           message = 'Failed to create listing: ${error ?? msg}';
//         }
//       }

//       throw Exception(message);
//     }
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/marketplace_model.dart';

class MarketplaceRemoteDataSource {
  final http.Client client;

  final String? djangoSessionId;

  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String _listingsPath = '/marketplace/api/listings/';
  static const String _createListingPath =
      '/marketplace/api/listings/create-ajax/';

  MarketplaceRemoteDataSource({
    required this.client,
    this.djangoSessionId,
  });

  Future<List<MarketplaceModel>> getListings() async {
    final uri = Uri.parse('$_baseUrl$_listingsPath');

    final response = await client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (djangoSessionId != null) 'Cookie': 'sessionid=$djangoSessionId',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is List) {
        final List<dynamic> list = decoded;

        final List<MarketplaceModel> results = list
            .map(
              (item) =>
                  MarketplaceModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        return results;
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
    final String path = '/marketplace/api/listings/$id/';
    final uri = Uri.parse('$_baseUrl$path');

    final response = await client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (djangoSessionId != null) 'Cookie': 'sessionid=$djangoSessionId',
      },
    );

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return MarketplaceModel.fromJson(decoded);
      } else if (decoded is List && decoded.isNotEmpty) {
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

  Future<String> createListing({
    required String title,
    required int price,
    required String location,
    required String imageUrl,
    required Condition condition,
    String? description,
  }) async {
    final uri = Uri.parse('$_baseUrl$_createListingPath');

    final Map<String, String> body = {
      'title': title,
      'price': price.toString(),
      'location': location,
      'image_url': imageUrl,
      'condition': conditionValues.reverse[condition] ?? 'USED',
      'description': description ?? '',
    };

    final response = await client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-Requested-With': 'XMLHttpRequest',
        if (djangoSessionId != null) 'Cookie': 'sessionid=$djangoSessionId',
      },
      body: body,
    );

    final int status = response.statusCode;
    print('Response Status: $status');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');

    if (status == 301 || status == 302 || status == 303 || status == 307 || status == 308) {
      final location = response.headers['location'];
      throw Exception(
        'Request got redirected (HTTP $status) ke $location. '
        'Ini biasanya karena belum login / sessionid tidak valid.',
      );
    }

    final dynamic decoded =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (status == 201 || status == 200) {
      if (decoded is Map<String, dynamic>) {
        final statusField = decoded['status'];
        final idField = decoded['id']?.toString();

        if ((statusField == 'created' || statusField == 'ok') &&
            idField != null &&
            idField.isNotEmpty) {
          return idField;
        }

        throw Exception('Unexpected response when creating listing');
      } else {
        throw Exception('Unexpected response format when creating listing');
      }
    } else {
      String message = 'Failed to create listing. Status code: $status';

      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        final msg = decoded['message'];
        if (error != null || msg != null) {
          message = 'Failed to create listing: ${error ?? msg}';
        }
      }

      throw Exception(message);
    }
  }
}