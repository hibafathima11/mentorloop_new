import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/web/screens/landing_page.dart';
import 'package:mentorloop_new/web/screens/admin_login_screen.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final Function(int)? onNavItemSelected;
  final int selectedIndex;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
    this.onNavItemSelected,
    this.selectedIndex = 0,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _sidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Sidebar
          if (!isMobile)
            _buildSidebar(250)
          else if (_sidebarExpanded)
            _buildSidebar(screenSize.width * 0.7),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(context, isMobile),
                // Content
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(double width) {
    return Container(
      width: _sidebarExpanded ? width : 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Column(
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
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _sidebarItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isActive: widget.selectedIndex == 0,
                ),
                _sidebarItem(
                  index: 1,
                  icon: Icons.group_outlined,
                  label: 'Users',
                  isActive: widget.selectedIndex == 1,
                ),
                _sidebarItem(
                  index: 2,
                  icon: Icons.how_to_reg_outlined,
                  label: 'Student Approval',
                  isActive: widget.selectedIndex == 2,
                ),
                _sidebarItem(
                  index: 3,
                  icon: Icons.verified_outlined,
                  label: 'Parent Verification',
                  isActive: widget.selectedIndex == 3,
                ),
                _sidebarItem(
                  index: 4,
                  icon: Icons.badge_outlined,
                  label: 'Teacher Credentials',
                  isActive: widget.selectedIndex == 4,
                ),
                _sidebarItem(
                  index: 5,
                  icon: Icons.book_outlined,
                  label: 'Subjects',
                  isActive: widget.selectedIndex == 5,
                ),
                _sidebarItem(
                  index: 6,
                  icon: Icons.school_outlined,
                  label: 'Courses',
                  isActive: widget.selectedIndex == 6,
                ),
                _sidebarItem(
                  index: 7,
                  icon: Icons.assignment_outlined,
                  label: 'Assignments',
                  isActive: widget.selectedIndex == 7,
                ),
                _sidebarItem(
                  index: 8,
                  icon: Icons.description_outlined,
                  label: 'Exams',
                  isActive: widget.selectedIndex == 8,
                ),
                _sidebarItem(
                  index: 9,
                  icon: Icons.analytics_outlined,
                  label: 'User Analytics',
                  isActive: widget.selectedIndex == 9,
                ),
              ],
            ),
          ),
          // Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: _sidebarItem(
              icon: Icons.logout,
              label: 'Logout',
              isLogout: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem({
    int? index,
    required IconData icon,
    required String label,
    bool isActive = false,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: isActive
            ? const Color(0xFF8B5E3C).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () async {
            if (isLogout) {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              if (kIsWeb) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LandingPage()),
                  (route) => false,
                );
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  (route) => false,
                );
              }
              return;
            }
            if (index != null && widget.onNavItemSelected != null) {
              widget.onNavItemSelected!(index);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
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
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF8B5E3C)
                          : isLogout
                          ? Colors.red
                          : Colors.grey[700],
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isMobile) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
