import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/models/profile_model.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_name_row.dart';
import '../widgets/profile_activity_card.dart';
import '../widgets/profile_tabs.dart';
import '../../../../core/widgets/app_button.dart';
import 'package:nb_utils/nb_utils.dart' hide AppButton;
import 'package:flutter/scheduler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final username = auth.currentUser?.username ?? '';
      if (username.isNotEmpty) {
        final profileController = context.read<ProfileController>();
        profileController.loadProfile(username);
        profileController.loadUserPosts(username);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final username = auth.currentUser?.username ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Consumer<ProfileController>(
          builder: (context, controller, _) {
            final profile = controller.profile;
            if (controller.isLoading && controller.profile == null) {
              // LOADING STATE
              return const Center(child: CircularProgressIndicator());
            }
            if (profile == null) {
              return const Center(child: Text('No profile data'));
            }

            if (controller.postsEntry == null && !controller.isLoadingPosts) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                controller.loadUserPosts(profile.username);
              });
            }

            if (controller.errorMessage != null && controller.profile == null) {
              // ERROR STATE
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.red,
                      ),
                      12.height,
                      Text(
                        controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: primaryTextStyle(),
                      ),
                      16.height,
                      AppButton(
                        text: "Retry",
                        onTap: () {
                          context.read<ProfileController>().loadProfile(
                            username,
                          );
                        },
                        width: 200,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ProfileHeader(
                      username: profile.username,
                      isVerified: profile.isVerified,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(child: ProfileAvatarStats(profile: profile)),
                  const SizedBox(height: 24),
                  ProfileActivityCard(
                    profile: profile,
                    mascotAsset: 'assets/icon/profile_activity.svg',
                  ),
                  const SizedBox(height: 24),
                  ProfileNameRow(profile: profile),
                  const SizedBox(height: 24),
                  ProfileTabs(username: profile.username),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
