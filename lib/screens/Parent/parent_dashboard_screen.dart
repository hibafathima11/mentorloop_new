import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mentorloop_new/utils/auth_service.dart';
import 'package:mentorloop_new/utils/cloudinary_service.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/screens/Common/login_screen.dart';
import 'package:mentorloop_new/screens/Parent/child_progress_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  Map<String, dynamic>? _studentData;
  String? _studentId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLinkedStudent();
  }

  Future<void> _loadLinkedStudent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final result = await getLinkedStudentForParent(user.uid, user.email ?? '');

    setState(() {
      _studentData = result['studentData'];
      _studentId = result['studentId'];
      _loading = false;
    });
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _ParentSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      appBar: AppBar(
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF8B5E3C)),
            onPressed: () => _openSettings(context),
          ),
          IconButton(
            onPressed: () async {
              await AuthService.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: Color(0xFF8B5E3C)),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _studentData == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[700],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No linked student found for your email.",
                      style: TextStyle(
                        color: Color(0xFF8B5E3C),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please contact your child's school to update guardian details.",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5E3C),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Linked Student",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    _studentData?['photoUrl'] != null &&
                                        (_studentData?['photoUrl'] as String)
                                            .isNotEmpty
                                    ? NetworkImage(_studentData!['photoUrl'])
                                    : null,
                                child:
                                    (_studentData?['photoUrl'] == null ||
                                        (_studentData?['photoUrl'] as String)
                                            .isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        color: Color(0xFF8B5E3C),
                                        size: 32,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _studentData?['name'] ?? '-',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _studentData?['email'] ?? '-',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _studentData?['phone'] ?? '-',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Student Details",
                              style: TextStyle(
                                color: Color(0xFF8B5E3C),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _infoRow("Name", _studentData?['name']),
                            _infoRow("Email", _studentData?['email']),
                            _infoRow("Phone", _studentData?['phone']),
                            _infoRow("Role", _studentData?['role']),
                            // Add more fields if needed
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildProgressCard(context),
                    _buildFeedbackCard(context),
                    // You can add more cards for analytics, attendance, feedback, etc.
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    if (_studentId == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: ListTile(
        tileColor: const Color(0xFFE3F2FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(
          Icons.trending_up,
          color: Color(0xFF8B5E3C),
          size: 36,
        ),
        title: const Text(
          'View Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
            fontSize: 18,
          ),
        ),
        subtitle: const Text(
          'View attendance and performance',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5E3C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('View'),
          onPressed: () {
            if (_studentId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChildProgressScreen(studentId: _studentId!),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Color(0xFF8B5E3C),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    final _feedbackController = TextEditingController();
    bool _isSubmitting = false;

    void _showFeedbackDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Submit Feedback'),
                content: TextField(
                  controller: _feedbackController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Your feedback about app, teaching, etc.',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            setState(() => _isSubmitting = true);
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null ||
                                _feedbackController.text.trim().isEmpty)
                              return;
                            await FirebaseFirestore.instance
                                .collection('parent_feedback')
                                .add({
                                  'parentId': user.uid,
                                  'parentEmail': user.email,
                                  'feedback': _feedbackController.text.trim(),
                                  'createdAt': DateTime.now(),
                                });
                            setState(() => _isSubmitting = false);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feedback submitted'),
                              ),
                            );
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 18),
      child: ListTile(
        tileColor: const Color(0xFFFFF3E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(Icons.feedback, color: Color(0xFF8B5E3C), size: 36),
        title: const Text(
          'Submit Feedback',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
            fontSize: 18,
          ),
        ),
        subtitle: const Text(
          'Share your feedback about app or teaching',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5E3C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Add'),
          onPressed: _showFeedbackDialog,
        ),
      ),
    );
  }
}

// Logic to fetch linked student for parent
Future<Map<String, dynamic>> getLinkedStudentForParent(
  String parentId,
  String parentEmail,
) async {
  String? studentId;

  // First, check parent_links collection (for auto-linked or admin-approved parents)
  final parentLinkDoc = await FirebaseFirestore.instance
      .collection('parent_links')
      .doc(parentId)
      .get();

  if (parentLinkDoc.exists) {
    final linkData = parentLinkDoc.data();
    studentId = linkData?['studentId'] as String?;
  } else {
    // If not found in parent_links, check guardians collection by email
    final guardianSnap = await FirebaseFirestore.instance
        .collection('guardians')
        .where('email', isEqualTo: parentEmail.toLowerCase().trim())
        .limit(1)
        .get();

    if (guardianSnap.docs.isNotEmpty) {
      final guardianData = guardianSnap.docs.first.data();
      studentId = guardianData['studentId'] as String?;

      // If found via guardian email, create the parent link for future use
      if (studentId != null && studentId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('parent_links')
            .doc(parentId)
            .set({
              'parentId': parentId,
              'studentId': studentId,
              'linkedAt': FieldValue.serverTimestamp(),
              'linkedVia': 'guardian_email',
            });
      }
    }
  }

  if (studentId == null || studentId.isEmpty) {
    return {'studentData': null, 'studentId': null};
  }

  // Fetch student data
  final studentSnap = await FirebaseFirestore.instance
      .collection('users')
      .doc(studentId)
      .get();

  if (!studentSnap.exists) {
    return {'studentData': null, 'studentId': null};
  }

  final studentData = studentSnap.data();
  return {'studentData': studentData, 'studentId': studentId};
}

class _ParentSettingsSheet extends StatefulWidget {
  const _ParentSettingsSheet();

  @override
  State<_ParentSettingsSheet> createState() => _ParentSettingsSheetState();
}

class _ParentSettingsSheetState extends State<_ParentSettingsSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _newPassword = TextEditingController();
  String? _photoUrl;
  bool _saving = false;

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
      if (data != null && mounted) {
        setState(() {
          _name.text = (data['name'] as String?) ?? '';
          _phone.text = (data['phone'] as String?) ?? '';
          _photoUrl = data['photoUrl'] as String?;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _saving = true);
    try {
      final url = await CloudinaryService.uploadFile(
        file: File(picked.path),
        resourceType: 'image',
      );
      setState(() => _photoUrl = url);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await AuthService.updateCurrentUserProfile(
        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        photoUrl: _photoUrl,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_newPassword.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await AuthService.changePassword(_newPassword.text.trim());
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: padding.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profile Settings",
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _photoUrl != null
                          ? NetworkImage(_photoUrl!)
                          : null,
                      child: _photoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF8B5E3C),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadAvatar,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B5E3C),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Profile'),
                ),
              ),
              const Divider(height: 48),
              const Text(
                "Change Password",
                style: TextStyle(
                  color: Color(0xFF8B5E3C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPassword,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _saving ? null : _changePassword,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5E3C),
                    side: const BorderSide(color: Color(0xFF8B5E3C)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Update Password'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
