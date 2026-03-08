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
                    'Mentorloop',
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
                _sidebarItem(
                  index: 10,
                  icon: Icons.feedback_outlined,
                  label: 'Complaints',
                  isActive: widget.selectedIndex == 10,
                ),
                _sidebarItem(
                  index: 11,
                  icon: Icons.rate_review_outlined,
                  label: 'Parent Feedback',
                  isActive: widget.selectedIndex == 11,
                ),
                _sidebarItem(
                  index: 12,
                  icon: Icons.chat_outlined,
                  label: 'Chat',
                  isActive: widget.selectedIndex == 12,
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
              // Close sidebar on mobile after selection
              final isMobile = MediaQuery.of(context).size.width < 768;
              if (isMobile) {
                setState(() => _sidebarExpanded = false);
              }
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (isMobile)
              IconButton(
                icon: Icon(_sidebarExpanded ? Icons.menu_open : Icons.menu),
                onPressed: () =>
                    setState(() => _sidebarExpanded = !_sidebarExpanded),
                color: const Color(0xFF8B5E3C),
              ),
            const SizedBox(width: 8),
            // Title
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Right Actions
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _showSearchDialog(context),
                  tooltip: 'Search',
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => _showNotificationsDialog(context),
                  tooltip: 'Notifications',
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  offset: const Offset(0, 50),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5E3C),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5E3C).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 20),
                          SizedBox(width: 10),
                          Text('Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!mounted) return;
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LandingPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Logout', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for students, teachers, or courses...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Searching for: $value')));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: Color(0xFF8B5E3C)),
            const SizedBox(width: 12),
            const Text('Notifications'),
          ],
        ),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _notificationItem(
                'New Student Signup',
                'A new student has registered and is pending approval.',
                '2 mins ago',
              ),
              const Divider(),
              _notificationItem(
                'Course Updated',
                'Computer Science course content has been updated by the teacher.',
                '1 hour ago',
              ),
              const Divider(),
              _notificationItem(
                'New Complaint',
                'A new parent complaint has been submitted.',
                '3 hours ago',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _notificationItem(String title, String subtitle, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }
}
