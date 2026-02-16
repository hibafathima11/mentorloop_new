import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/screens/Admin/student_approval_screen.dart';
import 'package:mentorloop_new/screens/Admin/teacher_credentials_screen.dart';
import 'package:mentorloop_new/utils/auth_service.dart';
import 'package:mentorloop_new/screens/Common/login_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_subjects_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_parent_verification_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_user_analytics_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_teacher_chat_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_complaints_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_parent_feedback_screen.dart';

import 'package:mentorloop_new/web/screens/notificationscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mentorloop_new/utils/cloudinary_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  void _openProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _AdminSettingsSheet(),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: AdminSearchDelegate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF8B5E3C)),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Color(0xFF8B5E3C),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const Scaffold(body: AdminNotificationsScreen()),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF8B5E3C)),
            onPressed: () => _openProfile(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8B5E3C)),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                width: double.infinity,
                padding: ResponsiveHelper.getResponsivePaddingAll(context),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E3C),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveCardRadius(context),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, Admin!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 24,
                          tablet: 28,
                          desktop: 32,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveMargin(
                        context,
                        mobile: 10,
                        tablet: 15,
                        desktop: 20,
                      ),
                    ),
                    Text(
                      "Manage users, approve students, and oversee the platform.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 30,
                  tablet: 40,
                  desktop: 50,
                ),
              ),
              // Quick Actions
              Text(
                "Admin Actions",
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 24,
                    desktop: 28,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 20,
                  tablet: 25,
                  desktop: 30,
                ),
              ),
              // Action Cards Grid (unified across breakpoints)
              ResponsiveHelper.responsiveBuilder(
                context: context,
                mobile: _buildActionsGrid(context, 2),
                tablet: _buildActionsGrid(context, 3),
                desktop: _buildActionsGrid(context, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildActionCard removed; unified grid now renders cards inline
}

class AdminSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Search for students or teachers'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;

        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    user['photoUrl'] != null &&
                        (user['photoUrl'] as String).isNotEmpty
                    ? NetworkImage(user['photoUrl'])
                    : null,
                child:
                    (user['photoUrl'] == null ||
                        (user['photoUrl'] as String).isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user['name'] ?? 'No Name'),
              subtitle: Text(user['role'] ?? 'No Role'),
              onTap: () {
                // Handle user tap (e.g. show details)
                close(context, null);
              },
            );
          },
        );
      },
    );
  }
}

class _AdminSettingsSheet extends StatefulWidget {
  const _AdminSettingsSheet();

  @override
  State<_AdminSettingsSheet> createState() => _AdminSettingsSheetState();
}

class _AdminSettingsSheetState extends State<_AdminSettingsSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
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
            children: [
              Text(
                "Admin Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickAndUploadAvatar,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : null,
                  child: _photoUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    foregroundColor: Colors.white,
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildActionsGrid(BuildContext context, int crossAxisCount) {
  final actions = <Map<String, dynamic>>[
    {
      'icon': Icons.people_alt,
      'title': 'Student Approval',
      'subtitle': 'Approve pending student registrations',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentApprovalScreen(),
          ),
        );
      },
    },
    {
      'icon': Icons.verified_user,
      'title': 'Parent Verification',
      'subtitle': 'Approve parent ID and match student',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminParentVerificationScreen(),
          ),
        );
      },
    },
    {
      'icon': Icons.school,
      'title': 'Teacher Credentials',
      'subtitle': 'Issue credentials to new teachers',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TeacherCredentialsScreen(),
          ),
        );
      },
    },
    {
      'icon': Icons.subject,
      'title': 'Subjects Management',
      'subtitle': 'Manage subjects and courses',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminSubjectsScreen()),
        );
      },
    },
    {
      'icon': Icons.manage_accounts,
      'title': 'User Analytics',
      'subtitle': 'Active students and engagement',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminUserAnalyticsScreen(),
          ),
        );
      },
    },
    {
      'icon': Icons.report_problem,
      'title': 'View Complaints',
      'subtitle': 'Review and respond to complaints',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminComplaintsScreen(),
          ),
        );
      },
    },
    {
      'icon': Icons.feedback,
      'title': 'Parent Feedback',
      'subtitle': 'View parent feedback and reviews',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminParentFeedbackScreen(),
          ),
        );
      },
    },
    {
      'icon': Icons.chat_bubble_outline,
      'title': 'Chat',
      'subtitle': 'Talk to teachers',
      'onTap': () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminTeacherChatScreen(),
          ),
        );
      },
    },
  ];

  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      // Compute columns based on available width, keeping min tile width ~180
      int computedCols = (width / 180).floor().clamp(2, crossAxisCount);
      final cols = computedCols > 0 ? computedCols : 2;

      // Compute a fixed tile height to avoid vertical overflow regardless of content density
      double mainAxisExtent;
      if (width < 500) {
        mainAxisExtent = 180;
      } else if (width < 900) {
        mainAxisExtent = 200;
      } else {
        mainAxisExtent = 220;
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: mainAxisExtent,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final a = actions[index];
          return GestureDetector(
            onTap: a['onTap'] as VoidCallback,
            child: Container(
              padding: ResponsiveHelper.getResponsivePaddingAll(context),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveCardRadius(context),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    a['icon'] as IconData,
                    size: ResponsiveHelper.getResponsiveIconSize(
                      context,
                      mobile: 40,
                      tablet: 48,
                      desktop: 56,
                    ),
                    color: const Color(0xFF8B5E3C),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 10,
                      tablet: 12,
                      desktop: 14,
                    ),
                  ),
                  Text(
                    a['title'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF8B5E3C),
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 6,
                      tablet: 8,
                      desktop: 10,
                    ),
                  ),
                  Text(
                    a['subtitle'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.2,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 11,
                        tablet: 13,
                        desktop: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
