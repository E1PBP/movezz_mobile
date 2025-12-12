class FormatUtils {
  static String formatMessageDateTimeChat(dynamic createdAt) {
    DateTime? dt;
    if (createdAt is DateTime) {
      dt = createdAt.toLocal();
    } else if (createdAt is String) {
      dt = DateTime.tryParse(createdAt)?.toLocal();
    } else if (createdAt is int) {
      try {
        dt = DateTime.fromMillisecondsSinceEpoch(createdAt).toLocal();
      } catch (_) {
        dt = null;
      }
    }

    if (dt == null) return createdAt?.toString() ?? '';

    String two(int n) => n.toString().padLeft(2, '0');
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '$hour:${two(dt.minute)} $ampm • ${dt.day} ${months[dt.month - 1]}';
  }
}
