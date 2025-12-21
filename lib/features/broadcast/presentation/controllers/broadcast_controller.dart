import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../data/repositories/broadcast_repository.dart';
import '../../data/models/broadcast_model.dart';

enum BroadcastTab { trending, latest }

class BroadcastController extends ChangeNotifier {
  final BroadcastRepository repository;

  BroadcastController(this.repository);

  BroadcastTab _currentTab = BroadcastTab.trending;
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  BroadcastTab get currentTab => _currentTab;
  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  void switchTab(BroadcastTab tab) {
    if (_currentTab == tab) return;
    _currentTab = tab;
    _events = [];
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
    loadEvents();
  }

  Future<void> loadEvents({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _events = [];
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<EventModel> newEvents;
      if (_currentTab == BroadcastTab.trending) {
        newEvents = await repository.getTrendingEvents(page: _currentPage);
      } else {
        newEvents = await repository.getLatestEvents(page: _currentPage);
      }

      if (refresh) {
        _events = newEvents;
      } else {
        _events.addAll(newEvents);
      }

      _hasMore = newEvents.isNotEmpty;
      if (_hasMore) _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await loadEvents();
  }

  Future<void> refresh() async {
    await loadEvents(refresh: true);
  }

  Future<void> clickEvent(String eventId) async {
    try {
      final newClickCount = await repository.clickEvent(eventId);
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = EventModel(
          id: _events[index].id,
          user_id: _events[index].user_id,
          author_display_name: _events[index].author_display_name,
          author_avatar_url: _events[index].author_avatar_url,
          author_badges_url: _events[index].author_badges_url,
          image_url: _events[index].image_url,
          description: _events[index].description,
          is_pinned: _events[index].is_pinned,
          location_name: _events[index].location_name,
          location_lat: _events[index].location_lat,
          location_lng: _events[index].location_lng,
          start_time: _events[index].start_time,
          end_time: _events[index].end_time,
          fee: _events[index].fee,
          total_click: newClickCount,
          rsvp_url: _events[index].rsvp_url,
          created_at: _events[index].created_at,
          updated_at: _events[index].updated_at,
          user_is_verified: _events[index].user_is_verified,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to register RSVP: $e';
      notifyListeners();
    }
  }

  Future<bool> createEvent({
    required String description,
    required DateTime startTime,
    DateTime? endTime,
    String? locationName,
    double? locationLat,
    double? locationLng,
    int? fee,
    String? rsvpUrl,
    Uint8List? imageBytes,
    String? imageMime,
    String? imageUrl,
  }) async {
    try {
      final created = await repository.createEvent(
        description: description,
        startTime: startTime,
        endTime: endTime,
        locationName: locationName,
        locationLat: locationLat,
        locationLng: locationLng,
        fee: fee,
        rsvpUrl: rsvpUrl,
        imageBytes: imageBytes?.toList(),
        imageMime: imageMime,
        imageUrl: imageUrl,
      );
      _events = [created, ..._events];
      notifyListeners();

      await refresh();
      return true;
    } catch (e) {
      _error = 'Failed to create event: $e';
      notifyListeners();
      return false;
    }
  }
}
