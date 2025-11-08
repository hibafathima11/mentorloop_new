import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mentorloop/screens/Teacher/teacherchatlist.dart';
import 'package:mentorloop/utils/responsive.dart';
import 'package:mentorloop/utils/colors.dart';
import 'package:mentorloop/utils/auth_service.dart';
import 'package:mentorloop/utils/cloudinary_service.dart';
import 'package:mentorloop/screens/Teacher/upload_content_screen.dart';
import 'package:mentorloop/screens/Teacher/add_video_questions_screen.dart';
import 'package:mentorloop/screens/Teacher/assignment_create_screen.dart';
import 'package:mentorloop/screens/Teacher/assignment_review_screen.dart';
import 'package:mentorloop/screens/Common/doubts_screen.dart';
import 'package:mentorloop/screens/Common/analytics_screen.dart';
import 'package:mentorloop/screens/Common/login_screen.dart';
import 'package:mentorloop/screens/Teacher/teacher_parent_feedback_screen.dart';
import 'package:mentorloop/screens/Teacher/exam_create_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const _TeacherSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _DashAction(
        icon: Icons.upload,
        title: 'Upload Materials',
        subtitle: 'Share study materials and videos',
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const UploadContentScreen()),
        ),
      ),
      _DashAction(
        icon: Icons.assignment,
        title: 'Create Assignments',
        subtitle: 'Create and manage assignments',
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const AssignmentCreateScreen()),
        ),
      ),
      _DashAction(
        icon: Icons.assignment_turned_in,
        title: 'Review Submissions',
        subtitle: 'Grade student submissions',
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) =>
                const AssignmentReviewScreen(assignmentId: 'ASSIGNMENT_ID'),
          ),
        ),
      ),
      _DashAction(
        icon: Icons.people,
        title: 'View Doubts',
        subtitle: 'Check and reply to doubts',
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const DoubtsScreen(courseId: 'COURSE_ID'),
          ),
        ),
      ),
      _DashAction(
        icon: Icons.quiz,
        title: 'Add Questions',
        subtitle: 'Add questions to videos',
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const AddVideoQuestionsScreen()),
        ),
      ),
      _DashAction(
        icon: Icons.analytics,
        title: 'Analytics',
        subtitle: 'View performance analytics',
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const AnalyticsScreen(courseId: 'COURSE_ID'),
          ),
        ),
      ),
      _DashAction(
        icon: Icons.chat_bubble_outline,
        title: 'Chat',
        subtitle: 'Message admin & students',
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => const TeacherChatListScreen()),
        ),
      ),
      _DashAction(
        icon: Icons.feedback,
        title: 'Parent Feedback',
        subtitle: 'View feedback from parents',
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const TeacherParentFeedbackScreen(),
          ),
        ),
      ),
      _DashAction(
        icon: Icons.quiz,
        title: 'Conduct Exams',
        subtitle: 'Create and manage exams',
        onTap: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => const ExamCreateScreen(),
          ),
        ),
      ),
    ];

    int crossAxisCount;
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      crossAxisCount = 4;
    } else if (width >= 800) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    double mainAxisExtent;
    if (width < 500) {
      mainAxisExtent = 180;
    } else if (width < 900) {
      mainAxisExtent = 200;
    } else {
      mainAxisExtent = 220;
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Teacher Dashboard',
          style: TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF8B5E3C)),
            onPressed: () => _openSettings(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF8B5E3C)),
            onPressed: () async {
              await AuthService.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      "Welcome, Teacher!",
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
                      "Manage your classes, assignments, and student progress.",
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
                  mobile: 24,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
              Text(
                "Quick Actions",
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
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: mainAxisExtent,
                  ),
                  itemCount: actions.length,
                  itemBuilder: (ctx, i) => _ActionCard(action: actions[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext) onTap;
  _DashAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _ActionCard extends StatelessWidget {
  final _DashAction action;
  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => action.onTap(context),
      child: Container(
        padding: ResponsiveHelper.getResponsivePaddingAll(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
          children: [
            Icon(
              action.icon,
              color: const Color(0xFF8B5E3C),
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 32,
                tablet: 40,
                desktop: 48,
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 8,
                tablet: 12,
                desktop: 16,
              ),
            ),
            Flexible(
              child: Text(
                action.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 16,
                    desktop: 18,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 4,
                tablet: 6,
                desktop: 8,
              ),
            ),
            Flexible(
              child: Text(
                action.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 10,
                    tablet: 12,
                    desktop: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherSettingsSheet extends StatefulWidget {
  const _TeacherSettingsSheet();

  @override
  State<_TeacherSettingsSheet> createState() => _TeacherSettingsSheetState();
}

class _TeacherSettingsSheetState extends State<_TeacherSettingsSheet> {
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

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _newPassword.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await AuthService.updateCurrentUserProfile(
        name: _name.text.trim().isEmpty ? null : _name.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        photoUrl: _photoUrl,
      );
      await _loadProfile(); // <-- Add this line
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
              // Header
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
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 20,
                  tablet: 25,
                  desktop: 30,
                ),
              ),
              // Profile Photo Section
              Container(
                width: double.infinity,
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
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _photoUrl == null
                              ? null
                              : NetworkImage(_photoUrl!),
                          child: _photoUrl == null
                              ? Icon(
                                  Icons.person,
                                  color: const Color(0xFF8B5E3C),
                                  size: ResponsiveHelper.getResponsiveIconSize(
                                    context,
                                    mobile: 40,
                                    tablet: 50,
                                    desktop: 60,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getResponsiveMargin(
                            context,
                            mobile: 16,
                            tablet: 20,
                            desktop: 24,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Photo',
                                style: TextStyle(
                                  color: const Color(0xFF8B5E3C),
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        mobile: 16,
                                        tablet: 18,
                                        desktop: 20,
                                      ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveHelper.getResponsiveMargin(
                                  context,
                                  mobile: 8,
                                  tablet: 10,
                                  desktop: 12,
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height:
                                    ResponsiveHelper.getResponsiveButtonHeight(
                                      context,
                                    ) *
                                    0.7,
                                child: ElevatedButton.icon(
                                  onPressed: _saving
                                      ? null
                                      : _pickAndUploadAvatar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B5E3C),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        ResponsiveHelper.getResponsiveCardRadius(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.camera_alt, size: 18),
                                  label: const Text('Change Photo'),
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
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 20,
                  tablet: 25,
                  desktop: 30,
                ),
              ),
              // Personal Information Section
              Text(
                'Personal Information',
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 18,
                    tablet: 20,
                    desktop: 22,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              // Name field
              Container(
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
                child: TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "Enter your full name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        ResponsiveHelper.getResponsivePaddingSymmetric(
                          context,
                          horizontal: 20,
                          vertical: 16,
                        ),
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 16,
                  tablet: 20,
                  desktop: 24,
                ),
              ),
              // Phone field
              Container(
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
                child: TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone",
                    hintText: "Enter your phone number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        ResponsiveHelper.getResponsivePaddingSymmetric(
                          context,
                          horizontal: 20,
                          vertical: 16,
                        ),
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 24,
                  tablet: 30,
                  desktop: 36,
                ),
              ),
              // Save Profile Button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getResponsiveButtonHeight(context),
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Save Profile",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
              // Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color.fromARGB(
                        255,
                        188,
                        118,
                        93,
                      ).withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: ResponsiveHelper.getResponsivePaddingSymmetric(
                      context,
                      horizontal: 20,
                      vertical: 0,
                    ),
                    child: Text(
                      "Change Password",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 188, 118, 93),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color.fromARGB(
                        255,
                        188,
                        118,
                        93,
                      ).withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 24,
                  tablet: 30,
                  desktop: 36,
                ),
              ),
              // New Password field
              Container(
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
                child: TextFormField(
                  controller: _newPassword,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    hintText: "Enter new password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        ResponsiveHelper.getResponsivePaddingSymmetric(
                          context,
                          horizontal: 20,
                          vertical: 16,
                        ),
                  ),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 24,
                  tablet: 30,
                  desktop: 36,
                ),
              ),
              // Change Password Button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getResponsiveButtonHeight(context),
                child: OutlinedButton(
                  onPressed: _saving ? null : _changePassword,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF8B5E3C),
                    side: const BorderSide(color: Color(0xFF8B5E3C), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: const Color(0xFF8B5E3C),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 16,
                              tablet: 18,
                              desktop: 20,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
            ],
          ),
        ),
      ),
    );
  }
}
