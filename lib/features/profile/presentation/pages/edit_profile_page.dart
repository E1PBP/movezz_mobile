import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movezz_mobile/core/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/profile_model.dart';
import '../controllers/profile_controller.dart';
import './profile_page.dart';
import '../../../../core/routing/app_router.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _displayNameController;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _usernameController = TextEditingController();
    _displayNameController = TextEditingController();

    final profile = context.read<ProfileController>().profile;

    if (profile != null) {
      _usernameController.text = profile.username;
      _displayNameController.text = profile.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  // ================= AVATAR =================
  Widget _buildAvatar(ProfileEntry? profile) {
    return CircleAvatar(
      radius: 56,
      backgroundColor: AppColors.primary.withOpacity(0.1),
      child: ClipOval(
        child: SizedBox(
          width: 112,
          height: 112,
          child: _pickedImage != null
              ? (kIsWeb && _webImageBytes != null
                    ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                    : Image.file(File(_pickedImage!.path), fit: BoxFit.cover))
              : (profile?.avatarUrl != null &&
                    (profile!.avatarUrl ?? '').isNotEmpty)
              ? Image.network(profile.avatarUrl!, fit: BoxFit.cover)
              : SvgPicture.asset(
                  'assets/icon/logo-navbar.svg',
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImage = image;
          _webImageBytes = bytes;
        });
      } else {
        setState(() {
          _pickedImage = image;
        });
      }
    }
  }

  // ================= SAVE =================
  Future<void> _saveProfile() async {
    final controller = context.read<ProfileController>();
    final profile = controller.profile;

    if (profile == null || profile.username.isEmpty) {
      if (mounted) {
        context.showSnackBar(
          'Profile data not found. Please reload.',
          isError: true,
        );
      }
      return;
    }

    final displayName = _displayNameController.text.trim();
    if (displayName.isEmpty) {
      if (mounted) {
        context.showSnackBar('Display name cannot be empty', isError: true);
      }
      return;
    }

    final success = await controller.updateProfile(
      username: profile.username,
      displayName: displayName,
      imageFile: _pickedImage,
    );

    if (!mounted) return;

    if (success) {
      context.showSnackBar('Profile updated successfully');
      Navigator.pop(context);
    } else {
      context.showSnackBar(
        controller.errorMessage ?? 'Failed to update profile',
        isError: true,
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>().profile;

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Profile data not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            _buildAvatar(profile),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Image'),
            ),

            const SizedBox(height: 32),

            // Username (readonly)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Username',
                style: boldTextStyle(color: AppColors.primary),
              ),
            ),
            TextField(
              controller: _usernameController,
              readOnly: true,
              enabled: false,
              decoration: const InputDecoration(
                prefixText: '@',
                disabledBorder: UnderlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Display name
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Display Name',
                style: boldTextStyle(color: AppColors.primary),
              ),
            ),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(hintText: 'Enter display name'),
            ),

            const SizedBox(height: 40),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveProfile,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
