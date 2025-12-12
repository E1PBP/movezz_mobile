import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final bool isVerified;

  const ProfileHeader({
    super.key,
    required this.username,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '@$username',
          style: const TextStyle(
            color: Color(0xFF737373),
            fontSize: 12,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w500,
            height: 1.33,
          ),
        ),
        const SizedBox(width: 4),
        if (isVerified)
          Container(
            width: 18.48,
            height: 16.16,
            decoration: const BoxDecoration(
              color: Color(0xFFA3E635),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 10,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
