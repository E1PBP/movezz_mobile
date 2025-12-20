import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import '../../../../core/config/env.dart';
import '../models/broadcast_model.dart';

class BroadcastRemoteDataSource {
  final CookieRequest request;

  BroadcastRemoteDataSource(this.request);

  Future<List<EventModel>> getTrendingEvents({int page = 1}) async {
    try {
      final response = await request.get(
        '${Env.api('/broadcast/api/trending/')}?page=$page',
      );

      if (response is Map && response['results'] is List) {
        return (response['results'] as List)
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch trending events: $e');
    }
  }

  Future<List<EventModel>> getLatestEvents({int page = 1}) async {
    try {
      final response = await request.get(
        '${Env.api('/broadcast/api/latest/')}?page=$page',
      );

      if (response is Map && response['results'] is List) {
        return (response['results'] as List)
            .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch latest events: $e');
    }
  }

  Future<EventModel> createEvent({
    required String description,
    required DateTime startTime,
    DateTime? endTime,
    String? locationName,
    double? locationLat,
    double? locationLng,
    int? fee,
    String? rsvpUrl,
    List<int>? imageBytes,
    String? imageMime,
    String? imageUrl,
  }) async {
    try {
      final Map<String, String> body = {
        'description': description,
        'start_time': startTime.toIso8601String(),
        'fee': (fee ?? 0).toString(),
      };

      if (endTime != null) {
        body['end_time'] = endTime.toIso8601String();
      }
      if (locationName != null && locationName.isNotEmpty) {
        body['location_name'] = locationName;
      }
      if (locationLat != null && locationLng != null) {
        body['location_lat'] = locationLat.toString();
        body['location_lng'] = locationLng.toString();
      }
      if (rsvpUrl != null && rsvpUrl.isNotEmpty) {
        body['rsvp_url'] = rsvpUrl;
      }
      if (imageBytes != null && imageMime != null) {
        final b64 = base64Encode(imageBytes);
        body['image_data'] = 'data:$imageMime;base64,$b64';
      }
      if (imageUrl != null && imageUrl.isNotEmpty) {
        body['image_url'] = imageUrl;
      }

      final response = await request.post(
        Env.api('/broadcast/api/events/create/'),
        body,
      );

      if (response['status'] == 'success') {
        return EventModel.fromJson(response['event']);
      }
      throw Exception(response['error'] ?? 'Failed to create event');
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<int> clickEvent(String eventId) async {
    try {
      final response = await request.post(
        Env.api('/broadcast/events/$eventId/click/'),
        {},
      );

      if (response['status'] == 'ok') {
        return response['total_click'] as int;
      }
      throw Exception('Failed to register click');
    } catch (e) {
      throw Exception('Failed to click event: $e');
    }
  }
}
