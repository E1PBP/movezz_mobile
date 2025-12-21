import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/profile_model.dart';

class ProfileActivityCard extends StatelessWidget {
  final ProfileEntry profile;
  final String mascotAsset;
  final String quote;

  const ProfileActivityCard({
    super.key,
    required this.profile,
    this.mascotAsset = 'assets/icon/profile_activity.svg', 
    this.quote = "\"Move your spirit, share your beat.\"",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), 
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
                  "Movezz Motivation",
                  style: TextStyle(
                    color: Color(0xFF365314), 
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quote,
                  style: const TextStyle(
                    color: Color(0xFF4D7C0F), 
                    fontSize: 14,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic, 
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
