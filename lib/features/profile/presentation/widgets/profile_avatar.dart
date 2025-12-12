import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/models/profile_model.dart';

class ProfileAvatarStats extends StatelessWidget {
  final ProfileEntry profile;

  const ProfileAvatarStats({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              width: 2,
              color: const Color(0xFFA3E635), 
            ),
          ),
          child: ClipOval(
            child: _buildAvatarContent(),
          ),
        ),

        const SizedBox(width: 32),

        Row(
          children: [
            _StatColumn(
              value: profile.postCount.toString(),
              label: 'posts',
            ),
            const SizedBox(width: 24),
            _StatColumn(
              value: profile.followersCount.toString(),
              label: 'followers',
            ),
            const SizedBox(width: 24),
            _StatColumn(
              value: profile.followingCount.toString(),
              label: 'following',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarContent() {
    final initial = (profile.displayName?.trim().isNotEmpty ?? false)
        ? profile.displayName!.trim()[0].toUpperCase()
        : profile.username.isNotEmpty
            ? profile.username[0].toUpperCase()
            : 'U';

    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return Image.network(
        profile.avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return SvgPicture.asset(
            'assets/icon/profile_avatar.svg',
            fit: BoxFit.cover,
          );
        },
      );
    }

    return SvgPicture.asset(
      'assets/icon/profile_avatar.svg', 
      fit: BoxFit.contain,
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF404040),
              fontSize: 16,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF404040),
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w500,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}
