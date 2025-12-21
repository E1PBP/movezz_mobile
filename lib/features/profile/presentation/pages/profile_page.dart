import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart' hide AppButton;
import 'package:flutter/scheduler.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_name_row.dart';
import '../widgets/profile_activity_card.dart';
import '../widgets/profile_tabs.dart';
import '../../../../core/widgets/app_button.dart';

class ProfilePage extends StatefulWidget {
  final String? username;
  final bool showBackButton;

  const ProfilePage({
    super.key, 
    this.username, 
    this.showBackButton = false
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final auth = context.read<AuthController>();
    final profileController = context.read<ProfileController>();

    String targetUsername = widget.username ?? '';

    if (targetUsername.isEmpty) {
      if (auth.currentUser == null) {
        await auth.restoreSession();
      }
      targetUsername = auth.currentUser?.username ?? '';
    }

    if (targetUsername.isNotEmpty) {
      profileController.loadProfile(targetUsername);
      profileController.loadUserPosts(targetUsername);
      profileController.loadUserBroadcasts(targetUsername);
    }
  }

  Future<void> _handleRefresh(String username) async {
    final controller = context.read<ProfileController>();
    await Future.wait([
      controller.loadProfile(username),
      controller.loadUserPosts(username),
      controller.loadUserBroadcasts(username),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final currentUsername = auth.currentUser?.username ?? ''; 
    final targetUsername = widget.username ?? currentUsername;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: widget.showBackButton 
          ? AppBar(
              title: const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFFFAFAFA),
              elevation: 0,
              centerTitle: true,
              leading: const BackButton(color: Colors.black),
              iconTheme: const IconThemeData(color: Colors.black),
            )
          : null,
      body: SafeArea(
        child: Consumer<ProfileController>(
          builder: (context, controller, _) {
            final profile = controller.profile;
            
            if (controller.isLoading && controller.profile == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (profile == null) {
              if (controller.errorMessage != null) {
                 return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 40, color: Colors.red),
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
                            context.read<ProfileController>().loadProfile(targetUsername);
                          },
                          width: 200,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const Center(child: Text('No profile data'));
            }

            if (controller.postsEntry == null && !controller.isLoadingPosts) {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                controller.loadUserPosts(profile.username);
              });
            }

            return RefreshIndicator(
              onRefresh: () => _handleRefresh(targetUsername),
              color: const Color(0xFFA3E635),
              child: SingleChildScrollView(

                physics: const AlwaysScrollableScrollPhysics(), 
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

                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}