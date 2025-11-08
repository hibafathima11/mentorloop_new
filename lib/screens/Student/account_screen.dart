import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/utils/auth_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mentorloop_new/utils/cloudinary_service.dart';
import 'package:mentorloop_new/screens/Common/login_screen.dart';
import 'package:mentorloop_new/screens/Common/privacy_policy_screen.dart';
import 'package:mentorloop_new/screens/Common/terms_of_service_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _name = '';
  String _email = '';
  String _phone = '';
  String? _photoUrl;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final data = await AuthService.getUserProfile(user.uid);
      setState(() {
        _email = user.email ?? '';
        _name = (data?['name'] as String?) ?? '';
        _phone = (data?['phone'] as String?) ?? '';
        _photoUrl = data?['photoUrl'] as String?;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final url = await CloudinaryService.uploadFile(
        file: File(picked.path),
        resourceType: 'image',
      );
      setState(() => _photoUrl = url);
      await _saveProfile(); // <-- Add this line to save and reload profile
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _uploading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _uploading = true);
    try {
      await AuthService.updateCurrentUserProfile(
        name: _name.trim().isEmpty ? null : _name.trim(),
        phone: _phone.trim().isEmpty ? null : _phone.trim(),
        photoUrl: _photoUrl,
      );
      await _loadProfile(); // reload latest info~
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.white,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primaryBackground,
                            backgroundImage: _photoUrl == null
                                ? null
                                : NetworkImage(_photoUrl!),
                            child: _photoUrl == null
                                ? Icon(
                                    Icons.person,
                                    size: 40,
                                    color: AppColors.primaryButton,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            height: 22,
                            width: 22,
                            decoration: BoxDecoration(
                              color: AppColors.primaryButton,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: AppColors.white,
                                width: 2,
                              ),
                            ),
                            child: _uploading
                                ? const Padding(
                                    padding: EdgeInsets.all(3),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : InkWell(
                                    onTap: _pickAndUploadAvatar,
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _infoItem('Name', _name.isEmpty ? '-' : _name),
                  _infoItem('Email', _email.isEmpty ? '-' : _email),
                  _infoItem('Phone', _phone.isEmpty ? '-' : _phone),
                  const SizedBox(height: 12),
                  Divider(color: AppColors.borderColor),
                  const SizedBox(height: 12),
                  _settingsItem(
                    context,
                    label: 'Change Password',
                    onTap: _showChangePasswordDialog,
                  ),
                  _settingsItem(
                    context,
                    label: 'Privacy Policy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                    showChevron: true,
                  ),
                  _settingsItem(
                    context,
                    label: 'Terms of Service',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen(),
                        ),
                      );
                    },
                    showChevron: true,
                  ),
                  _settingsItem(
                    context,
                    label: 'Add Guardian/Parent Details',
                    onTap: _showGuardianDialog,
                    showChevron: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await AuthService.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryButton,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _settingsItem(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    bool showChevron = false,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (showChevron)
              Icon(Icons.chevron_right, color: AppColors.textSecondary)
            else
              Icon(
                Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.darkGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(value, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showNote(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool isLoading = false;
    bool showCurrent = false;
    bool showNew = false;
    bool showConfirm = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Change Password',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Current Password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: currentController,
                        obscureText: !showCurrent,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          hintText: 'Enter current password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showCurrent
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() => showCurrent = !showCurrent);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // New Password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: newController,
                        obscureText: !showNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Enter new password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showNew ? Icons.visibility : Icons.visibility_off,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() => showNew = !showNew);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: confirmController,
                        obscureText: !showConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          hintText: 'Confirm new password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showConfirm
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() => showConfirm = !showConfirm);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final currentPass = currentController.text.trim();
                          final newPass = newController.text.trim();
                          final confirmPass = confirmController.text.trim();

                          if (currentPass.isEmpty) {
                            _showNote('Please enter current password');
                            return;
                          }
                          if (newPass.length < 6) {
                            _showNote(
                              'New password must be at least 6 characters',
                            );
                            return;
                          }
                          if (newPass != confirmPass) {
                            _showNote('New passwords do not match');
                            return;
                          }

                          setState(() => isLoading = true);

                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              // Re-authenticate with current password
                              final credential = EmailAuthProvider.credential(
                                email: user.email!,
                                password: currentPass,
                              );
                              await user.reauthenticateWithCredential(
                                credential,
                              );
                              // Update password
                              await user.updatePassword(newPass);
                            }
                            if (context.mounted) Navigator.pop(context);
                            _showNote('Password updated successfully');
                          } catch (e) {
                            setState(() => isLoading = false);
                            _showNote(
                              'Failed to update password: ${e.toString()}',
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showGuardianDialog() async {
    final relationController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Guardian/Parent Details'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: relationController,
                      decoration: const InputDecoration(labelText: 'Relation'),
                    ),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;
                          final guardianData = {
                            'studentId': user.uid,
                            'relation': relationController.text.trim(),
                            'name': nameController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'email': emailController.text.trim(),
                            'createdAt': DateTime.now(),
                          };
                          await FirebaseFirestore.instance
                              .collection('users')
                              .add(guardianData);
                          setState(() => isLoading = false);
                          if (context.mounted) Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Guardian details saved'),
                            ),
                          );
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
