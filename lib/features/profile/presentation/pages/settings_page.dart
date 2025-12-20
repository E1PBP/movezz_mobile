import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart' hide AppButton;

import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
// import '../../../profile/presentation/pages/edit_profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthController>(
        builder: (context, auth, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserHeader(context, auth),

                const Divider(
                  height: 32,
                  thickness: 4,
                  color: AppColors.layoutBackground,
                ),

                _buildSectionTitle("Account"),
                // _buildSettingItem(
                //   context,
                //   icon: Icons.person_outline,
                //   title: "Edit Profile",
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => const EditProfilePage(),
                //       ),
                //     );
                //   },
                // ),

                const Divider(
                  height: 24,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                _buildSectionTitle("About"),
                _buildSettingItem(
                  context,
                  icon: Icons.info_outline,
                  title: "About Movezz",
                  onTap: () => _showAboutDialog(context),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppButton(
                    text: "LOGOUT",
                    color: Colors.red.shade50,
                    textColor: Colors.red,
                    elevation: 0,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    isLoading: auth.isLoading,
                    onTap: () => _handleLogout(context, auth),
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    "v${AppConfig.appVersion}",
                    style: secondaryTextStyle(size: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, AuthController auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: context.cardColor,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                (auth.currentUser?.username.isNotEmpty ?? false)
                    ? auth.currentUser!.username[0].toUpperCase()
                    : "U",
                style: boldTextStyle(size: 24, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.currentUser?.username ?? "Guest",
                  style: boldTextStyle(size: 18),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Active",
                    style:
                        secondaryTextStyle(size: 10, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: boldTextStyle(size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SettingItemWidget(
      title: title,
      titleTextStyle: primaryTextStyle(),
      leading: Icon(icon, color: AppColors.primaryBlack, size: 22),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    AuthController auth,
  ) async {
    await showConfirmDialogCustom(
      context,
      title: "Logout?",
      subTitle: "Are you sure you want to log out of your account?",
      positiveText: "Logout",
      negativeText: "Cancel",
      dialogType: DialogType.CONFIRMATION,
      primaryColor: Colors.red,
      onAccept: (context) async {
        final success = await auth.logout();
        if (success) {
          if (!context.mounted) return;
          context.showSnackBar("Logged out successfully");
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.splash,
            (route) => false,
          );
        } else {
          if (!context.mounted) return;
          context.showSnackBar(
            auth.error ?? "Failed to logout",
            isError: true,
          );
        }
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("About Movezz"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_soccer,
                size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text("${AppConfig.appName} Mobile",
                style: boldTextStyle(size: 18)),
            const SizedBox(height: 8),
            Text(
              "Version ${AppConfig.appVersion}",
              style: secondaryTextStyle(),
            ),
            const SizedBox(height: 16),
            Text(
              "Movezz connects sports enthusiasts to share moments, join events, and trade gear.",
              textAlign: TextAlign.center,
              style: primaryTextStyle(size: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
