import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/screens/admin_dashboard_screen.dart';
import 'package:mentorloop_new/web/screens/users_management_screen.dart';
import 'package:mentorloop_new/web/screens/courses_management_screen.dart';
import 'package:mentorloop_new/web/screens/assignments_management_screen.dart';
import 'package:mentorloop_new/web/screens/exams_management_screen.dart';
import 'package:mentorloop_new/web/screens/analytics_screen.dart';
import 'package:mentorloop_new/web/screens/settings_screen.dart';
import 'package:mentorloop_new/screens/Admin/student_approval_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_parent_verification_screen.dart';
import 'package:mentorloop_new/screens/Admin/teacher_credentials_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_subjects_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_user_analytics_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_complaints_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_parent_feedback_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_teacher_chat_screen.dart';
import 'package:mentorloop_new/utils/auth_service.dart';
import 'package:mentorloop_new/web/screens/landing_page.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardContainer extends StatefulWidget {
  const AdminDashboardContainer({super.key});

  @override
  State<AdminDashboardContainer> createState() =>
      _AdminDashboardContainerState();
}

class _AdminDashboardContainerState extends State<AdminDashboardContainer> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;
  bool _hasCourses = false;
  bool _hasAssignments = false;
  bool _isLoading = true;

  List<AdminMenuItem> get _menuItems {
    final items = <AdminMenuItem>[
      AdminMenuItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        screen: const AdminDashboardScreen(),
      ),
      AdminMenuItem(
        icon: Icons.people,
        label: 'Users',
        screen: const UsersManagementScreen(),
      ),
      AdminMenuItem(
        icon: Icons.people_alt,
        label: 'Student Approval',
        screen: const StudentApprovalScreen(),
      ),
      AdminMenuItem(
        icon: Icons.verified_user,
        label: 'Parent Verification',
        screen: const AdminParentVerificationScreen(),
      ),
      AdminMenuItem(
        icon: Icons.school,
        label: 'Teacher Credentials',
        screen: const TeacherCredentialsScreen(),
      ),
      AdminMenuItem(
        icon: Icons.book,
        label: 'Subjects',
        screen: const AdminSubjectsScreen(),
      ),
    ];

    // Only add Courses if data exists in database
    if (_hasCourses) {
      items.add(
        AdminMenuItem(
          icon: Icons.school,
          label: 'Courses',
          screen: const CoursesManagementScreen(),
        ),
      );
    }

    // Only add Assignments if data exists in database
    if (_hasAssignments) {
      items.add(
        AdminMenuItem(
          icon: Icons.assignment,
          label: 'Assignments',
          screen: const AssignmentsManagementScreen(),
        ),
      );
    }

    items.addAll([
      AdminMenuItem(
        icon: Icons.quiz,
        label: 'Exams',
        screen: const ExamsManagementScreen(),
      ),
      AdminMenuItem(
        icon: Icons.manage_accounts,
        label: 'User Analytics',
        screen: const AdminUserAnalyticsScreen(),
      ),
      AdminMenuItem(
        icon: Icons.assessment,
        label: 'Analytics',
        screen: const AnalyticsScreen(),
      ),
      AdminMenuItem(
        icon: Icons.report_problem,
        label: 'Complaints',
        screen: const AdminComplaintsScreen(),
      ),
      AdminMenuItem(
        icon: Icons.feedback,
        label: 'Parent Feedback',
        screen: const AdminParentFeedbackScreen(),
      ),
      AdminMenuItem(
        icon: Icons.chat_bubble_outline,
        label: 'Chat',
        screen: const AdminTeacherChatScreen(),
      ),
      AdminMenuItem(
        icon: Icons.settings,
        label: 'Settings',
        screen: const SettingsScreen(),
      ),
    ]);
    return items;
  }

  @override
  void initState() {
    super.initState();
    _checkDatabaseData();
  }

  Future<void> _checkDatabaseData() async {
    try {
      final db = FirebaseFirestore.instance;

      // Check if courses exist
      final coursesSnapshot = await db.collection('courses').limit(1).get();
      final hasCourses = coursesSnapshot.docs.isNotEmpty;

      // Check if assignments exist
      final assignmentsSnapshot = await db
          .collection('assignments')
          .limit(1)
          .get();
      final hasAssignments = assignmentsSnapshot.docs.isNotEmpty;

      if (mounted) {
        setState(() {
          _hasCourses = hasCourses;
          _hasAssignments = hasAssignments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasCourses = false;
          _hasAssignments = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveCardRadius(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Sidebar
              if (!isMobile)
                _buildSidebar(constraints.maxWidth)
              else if (_sidebarExpanded)
                SizedBox(
                  width: constraints.maxWidth * 0.7,
                  child: _buildSidebarContent(),
                ),
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    // Top Bar
                    _buildTopBar(context, isMobile),
                    // Content
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFFF5F7FA),
                        child: _menuItems[_selectedIndex].screen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(double width) {
    final sidebarWidth = _sidebarExpanded
        ? (ResponsiveHelper.isDesktop(context) ? 280.0 : 240.0)
        : 80.0;
    return RepaintBoundary(
      child: SizedBox(
        width: sidebarWidth,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: _buildSidebarContent(),
        ),
      ),
    );
  }

  Widget _buildSidebarContent() {
    return Column(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E3C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'ML',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              if (_sidebarExpanded) ...[
                const SizedBox(width: 12),
                const Text(
                  'MentorLoop',
                  style: TextStyle(
                    color: Color(0xFF8B5E3C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Nav Items
        Expanded(
          child: RepaintBoundary(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              physics: const ClampingScrollPhysics(),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;
                return RepaintBoundary(
                  child: _sidebarItem(
                    icon: item.icon,
                    label: item.label,
                    isActive: isSelected,
                    onTap: () {
                      if (!mounted) return;
                      // Delay state update to ensure layout is complete
                      Future.microtask(() {
                        if (mounted) {
                          setState(() {
                            _selectedIndex = index;
                            // Close sidebar on mobile after selection
                            if (MediaQuery.of(context).size.width < 768) {
                              _sidebarExpanded = false;
                            }
                          });
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
        // Logout
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          ),
          child: _sidebarItem(
            icon: Icons.logout,
            label: 'Logout',
            isLogout: true,
            onTap: _logout,
          ),
        ),
      ],
    );
  }

  Widget _sidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isLogout = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              // Ensure visual update before handling tap
              WidgetsBinding.instance.ensureVisualUpdate();
              onTap();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              constraints: BoxConstraints(
                minHeight: 48,
                minWidth: constraints.maxWidth > 0
                    ? constraints.maxWidth
                    : double.infinity,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF8B5E3C).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    icon,
                    color: isActive
                        ? const Color(0xFF8B5E3C)
                        : isLogout
                        ? Colors.red
                        : Colors.grey[600],
                    size: 24,
                  ),
                  if (_sidebarExpanded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF8B5E3C)
                              : isLogout
                              ? Colors.red
                              : Colors.grey[700],
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool isMobile) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with menu toggle on mobile
            Expanded(
              child: Row(
                children: [
                  if (isMobile)
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        setState(() => _sidebarExpanded = !_sidebarExpanded);
                      },
                    ),
                  Flexible(
                    child: Text(
                      _menuItems[_selectedIndex].label,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 20,
                          desktop: 24,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Right Actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {},
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E3C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminMenuItem {
  final IconData icon;
  final String label;
  final Widget screen;

  AdminMenuItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
