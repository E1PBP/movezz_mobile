import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nb_utils/nb_utils.dart' hide AppButton;

import '../../../../core/widgets/app_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/presentation/pages/edit_profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Consumer<AuthController>(
              builder: (context, auth, _) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser?.username ?? "User",
                            style: boldTextStyle(size: 18),
                          ),
                          Text("Logged in", style: secondaryTextStyle()),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Profile"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
            ),

            Consumer<AuthController>(
              builder: (context, auth, _) {
                return AppButton(
                  text: "LOGOUT",
                  color: Colors.redAccent,
                  isLoading: auth.isLoading,
                  onTap: () async {
                    final success = await auth.logout();

                    if (success) {
                      if (!context.mounted) return;
                      context.showSnackBar("Logged out successfully");
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login,
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
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
