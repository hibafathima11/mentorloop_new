import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/screens/admin_dashboard_screen.dart';
import 'package:mentorloop_new/web/screens/users_management_screen.dart';
import 'package:mentorloop_new/web/screens/courses_management_screen.dart';
import 'package:mentorloop_new/web/screens/assignments_management_screen.dart';
import 'package:mentorloop_new/web/screens/exams_management_screen.dart';
import 'package:mentorloop_new/web/screens/analytics_screen.dart';
import 'package:mentorloop_new/web/screens/settings_screen.dart';

class AdminDashboardContainer extends StatefulWidget {
  const AdminDashboardContainer({super.key});

  @override
  State<AdminDashboardContainer> createState() =>
      _AdminDashboardContainerState();
}

class _AdminDashboardContainerState extends State<AdminDashboardContainer> {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;

  final List<AdminMenuItem> _menuItems = [
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
      icon: Icons.school,
      label: 'Courses',
      screen: const CoursesManagementScreen(),
    ),
    AdminMenuItem(
      icon: Icons.assignment,
      label: 'Assignments',
      screen: const AssignmentsManagementScreen(),
    ),
    AdminMenuItem(
      icon: Icons.quiz,
      label: 'Exams',
      screen: const ExamsManagementScreen(),
    ),
    AdminMenuItem(
      icon: Icons.assessment,
      label: 'Analytics',
      screen: const AnalyticsScreen(),
    ),
    AdminMenuItem(
      icon: Icons.settings,
      label: 'Settings',
      screen: const SettingsScreen(),
    ),
  ];

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

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
            _buildSidebar(screenSize.width)
          else if (_sidebarExpanded)
            SizedBox(
              width: screenSize.width * 0.7,
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
                  child: _menuItems[_selectedIndex].screen,
                ),
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
        border: Border(
          right: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: _buildSidebarContent(),
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
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _sidebarItem(
                icon: item.icon,
                label: item.label,
                isActive: _selectedIndex == index,
                onTap: () {
                  setState(() => _selectedIndex = index);
                  // Close sidebar on mobile after selection
                  if (MediaQuery.of(context).size.width < 768) {
                    setState(() => _sidebarExpanded = false);
                  }
                },
              );
            },
          ),
        ),
        // Logout
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: isActive ? const Color(0xFF8B5E3C).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
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
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
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
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with menu toggle on mobile
            Row(
              children: [
                if (isMobile)
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      setState(() => _sidebarExpanded = !_sidebarExpanded);
                    },
                  ),
                Text(
                  _menuItems[_selectedIndex].label,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
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
