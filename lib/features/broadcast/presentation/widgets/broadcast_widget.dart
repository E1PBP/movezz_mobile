import 'package:flutter/material.dart';
import 'dart:html' as html; 
import 'package:provider/provider.dart';
import '../../data/models/broadcast_model.dart';
import '../controllers/broadcast_controller.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.image_url != null && event.image_url!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: Image.network(
                event.image_url!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: event.author_avatar_url != null && event.author_avatar_url!.isNotEmpty
                          ? NetworkImage(event.author_avatar_url!)
                          : null,
                      child: event.author_avatar_url == null || event.author_avatar_url!.isEmpty
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.author_display_name ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (event.user_is_verified == true)
                            const Icon(Icons.verified,
                                size: 14, color: Colors.blue),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // description 
                if (event.description != null) ...[
                  Text(
                    event.description!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // date time
                _buildInfoRow(
                  Icons.calendar_today,
                  'Start: ${_formatDateTime(event.start_time)}',
                ),
                if (event.end_time != null)
                  _buildInfoRow(
                    Icons.calendar_today,
                    'End: ${_formatDateTime(event.end_time!)}',
                  ),

                const SizedBox(height: 8),

                // location
                if (event.location_name != null)
                  _buildLocationRow(event),

                const SizedBox(height: 12),

                // fee
                if (event.fee != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green, width: 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.fee == 0 ? 'Fee: FREE' : 'Fee: Rp ${_formatCurrency(event.fee!)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // rsvp button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: event.rsvp_url != null
                        ? () async {
                            final controller = context.read<BroadcastController>();
                            await controller.clickEvent(event.id);
                            _openUrl(event.rsvp_url!);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Join Event'),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Posted ${_formatDate(event.created_at)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: _isUrl(text)
                ? InkWell(
                    onTap: () => _openUrl(text),
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(text),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    return '${_monthName(localDate.month)} ${localDate.day}, ${localDate.year}';
  }

  String _formatDateTime(DateTime date) {
    final localDate = date.toLocal();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    return '${_monthName(localDate.month)} ${localDate.day}, ${localDate.year} $hour:$minute';
  }

  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  String _formatCurrency(int amount) {
    // Simple currency formatting without intl
    final str = amount.toString();
    final buffer = StringBuffer();
    var counter = 0;
    for (var i = str.length - 1; i >= 0; i--) {
      if (counter > 0 && counter % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
      counter++;
    }
    return buffer.toString().split('').reversed.join();
  }

  bool _isUrl(String s) => s.startsWith('http://') || s.startsWith('https://');

  void _openUrl(String url) {
    try {
      html.window.open(url, '_blank');
    } catch (_) {
      // no-op if not supported
    }
  }

  Widget _buildLocationRow(EventModel event) {
    final hasCoordinates = event.location_lat != null && event.location_lng != null;
    
    if (hasCoordinates) {
      final mapsUrl = 'https://www.google.com/maps?q=${event.location_lat},${event.location_lng}';
      return Row(
        children: [
          Icon(Icons.location_on, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: () => _openUrl(mapsUrl),
              child: Text(
                event.location_name!,
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return _buildInfoRow(Icons.location_on, event.location_name!);
    }
  }
}
