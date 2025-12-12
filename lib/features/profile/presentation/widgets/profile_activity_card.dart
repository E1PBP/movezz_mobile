import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/profile_model.dart';

class ProfileActivityCard extends StatelessWidget {
  final ProfileEntry profile;
  final String mascotAsset;
  final String? duration;

  const ProfileActivityCard({
    super.key,
    required this.profile,
    this.mascotAsset = 'assets/icon/profile_activity.svg', 
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final String activity = profile.currentSport ?? 'No Activities';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FEE7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: SvgPicture.asset(
              mascotAsset,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today’s Activities",
                  style: TextStyle(
                    color: Color(0xFF365314),
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _activityIcon(activity),
                      size: 18,
                      color: const Color(0xFF365314),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity,
                      style: const TextStyle(
                        color: Color(0xFF365314),
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(width: 24),
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Color(0xFF365314),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      duration ?? '0h 0m',
                      style: const TextStyle(
                        color: Color(0xFF365314),
                        fontSize: 14,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _activityIcon(String activity) {
    final lower = activity.toLowerCase();
    if (lower.contains('run') || lower.contains('lari')) {
      return Icons.directions_run;
    } else if (lower.contains('gym') ||
        lower.contains('weight') ||
        lower.contains('angkat')) {
      return Icons.fitness_center;
    } else if (lower.contains('bike') || lower.contains('sepeda')) {
      return Icons.directions_bike;
    }
    return Icons.person_off;
  }
}
