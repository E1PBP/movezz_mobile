import '../datasources/broadcast_remote_data_source.dart';
import '../models/broadcast_model.dart';

class BroadcastRepository {
  final BroadcastRemoteDataSource remote;

  BroadcastRepository(this.remote);

  Future<List<EventModel>> getTrendingEvents({int page = 1}) async {
    return await remote.getTrendingEvents(page: page);
  }

  Future<List<EventModel>> getLatestEvents({int page = 1}) async {
    return await remote.getLatestEvents(page: page);
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
    return await remote.createEvent(
      description: description,
      startTime: startTime,
      endTime: endTime,
      locationName: locationName,
      locationLat: locationLat,
      locationLng: locationLng,
      fee: fee,
      rsvpUrl: rsvpUrl,
      imageBytes: imageBytes,
      imageMime: imageMime,
      imageUrl: imageUrl,
    );
  }

  Future<int> clickEvent(String eventId) async {
    return await remote.clickEvent(eventId);
  }
}
