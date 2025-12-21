import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/profile_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import 'create_post.dart';
import '../pages/edit_profile_page.dart';

class ProfileNameRow extends StatelessWidget {
  final ProfileEntry profile;

  const ProfileNameRow({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final loggedInUsername = authController.currentUser?.username ?? '';
    final isSelf = loggedInUsername == profile.username;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Nama + Link
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.displayName?.isNotEmpty == true
                    ? profile.displayName!
                    : profile.username,
                style: const TextStyle(
                  color: Color(0xFF171717),
                  fontSize: 16,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (profile.link != null && profile.link!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link, size: 16, color: Color(0xFFA3A3A3)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        profile.link!,
                        style: const TextStyle(
                          color: Color(0xFFA3A3A3),
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        isSelf
            ? _buildSelfButton(context)
            : _buildFollowButton(context, profile.isFollowing),
      ],
    );
  }

  // Tombol untuk Diri Sendiri
  Widget _buildSelfButton(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // EDIT PROFILE
        SizedBox(
          width: 80,
          height: 40,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFA3E635), width: 1.5),
              foregroundColor: const Color(0xFFA3E635),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfilePage(profile: profile),
                ),
              );

              if (updated == true) {
                context.read<ProfileController>().loadProfile(profile.username);
              }
            },
            child: const Text(
              "Edit",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // CREATE POST
        SizedBox(
          width: 100,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA3E635),
              foregroundColor: const Color(0xFF365314),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0), // Reset theme constraints
            ),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black54,
                builder: (_) => CreatePostDialog(username: profile.username),
              );
            },
            child: const Text(
              "Create Post",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // Tombol Follow / Following untuk Orang Lain
  Widget _buildFollowButton(BuildContext context, bool isFollowing) {
    return SizedBox(
      width: 100,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing
              ? Colors.transparent
              : const Color(0xFFA3E635),
          foregroundColor: isFollowing
              ? const Color(0xFFA3E635)
              : const Color(0xFF365314),
          elevation: 0,
          side: isFollowing
              ? const BorderSide(color: Color(0xFFA3E635), width: 1.5)
              : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0), // Reset theme constraints (infinite width)
        ),
        onPressed: () {
          context.read<ProfileController>().toggleFollowUser();
        },
        child: Text(
          isFollowing ? "Following" : "Follow",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}