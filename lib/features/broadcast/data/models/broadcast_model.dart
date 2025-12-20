class EventModel {
  final String id;
  final int? user_id;
  final String? author_display_name;
  final String? author_avatar_url;
  final String? author_badges_url;
  final String? image_url;
  final String? description;
  final bool is_pinned;
  final String? location_name;
  final double? location_lat;
  final double? location_lng;
  final DateTime start_time;
  final DateTime? end_time;
  final int? fee;
  final int total_click;
  final String? rsvp_url;
  final DateTime created_at;
  final DateTime updated_at;
  final bool? user_is_verified;

  EventModel({
    required this.id,
    this.user_id,
    this.author_display_name,
    this.author_avatar_url,
    this.author_badges_url,
    this.image_url,
    this.description,
    this.is_pinned = false,
    this.location_name,
    this.location_lat,
    this.location_lng,
    required this.start_time,
    this.end_time,
    this.fee,
    this.total_click = 0,
    this.rsvp_url,
    required this.created_at,
    required this.updated_at,
    this.user_is_verified,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    DateTime _parseDate(dynamic v) {
      try {
        final s = v?.toString();
        if (s == null || s.isEmpty) return DateTime.now();
        return DateTime.parse(s);
      } catch (_) {
        return DateTime.now();
      }
    }

    int? _parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      final s = v.toString();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    bool? _parseBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;
      return null;
    }

    return EventModel(
      id: (json['id'] ?? '').toString(),
      user_id: _parseInt(json['user_id']),
      author_display_name: json['author_display_name']?.toString(),
      author_avatar_url: json['author_avatar_url']?.toString(),
      author_badges_url: json['author_badges_url']?.toString(),
      image_url: json['image_url']?.toString(),
      description: json['description']?.toString(),
      is_pinned: (json['is_pinned'] as bool?) ?? false,
      location_name: json['location_name']?.toString(),
      location_lat: json['location_lat'] != null
          ? double.tryParse(json['location_lat'].toString())
          : null,
      location_lng: json['location_lng'] != null
          ? double.tryParse(json['location_lng'].toString())
          : null,
      start_time: _parseDate(json['start_time']),
      end_time: json['end_time'] != null ? _parseDate(json['end_time']) : null,
      fee: _parseInt(json['fee']),
      total_click: _parseInt(json['total_click']) ?? 0,
      rsvp_url: json['rsvp_url']?.toString(),
      created_at: _parseDate(json['created_at']),
      updated_at: _parseDate(json['updated_at']),
      user_is_verified: _parseBool(json['user_is_verified']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'author_display_name': author_display_name,
      'author_avatar_url': author_avatar_url,
      'author_badges_url': author_badges_url,
      'image_url': image_url,
      'description': description,
      'is_pinned': is_pinned,
      'location_name': location_name,
      'location_lat': location_lat,
      'location_lng': location_lng,
      'start_time': start_time.toIso8601String(),
      'end_time': end_time?.toIso8601String(),
      'fee': fee,
      'total_click': total_click,
      'rsvp_url': rsvp_url,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'user_is_verified': user_is_verified,
    };
  }
}
