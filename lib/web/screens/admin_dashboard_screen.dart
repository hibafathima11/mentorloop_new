import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop_new/web/screens/notificationscreen.dart';
import 'package:mentorloop_new/web/screens/settings_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePaddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Toolbar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search anything...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF8B5E3C)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _CircleIconButton(
                icon: Icons.notifications_none,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminNotificationsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _CircleIconButton(
                icon: Icons.settings_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Welcome Card
          Container(
            width: double.infinity,
            padding: ResponsiveHelper.getResponsivePaddingAll(context),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5E3C), Color(0xFF6B4423)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveCardRadius(context),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5E3C).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dashboard,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveSpacing(context),
                    ),
                    Expanded(
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
                            height: ResponsiveHelper.getResponsiveSpacing(
                              context,
                              mobile: 4,
                              tablet: 6,
                              desktop: 8,
                            ),
                          ),
                          Text(
                            "Manage users, approve students, and oversee the platform.",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 14,
                                tablet: 16,
                                desktop: 18,
                              ),
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
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 24,
              tablet: 32,
              desktop: 40,
            ),
          ),
          // Stats Grid (live counts)
          FutureBuilder<Map<String, dynamic>>(
            future: () async {
              final db = FirebaseFirestore.instance;
              final usersSnap = await db.collection('users').get();
              final coursesSnap = await db.collection('courses').get();
              final assignmentsSnap = await db.collection('assignments').get();
              final pendingSnap = await db
                  .collection('users')
                  .where('approved', isEqualTo: false)
                  .get();
              final studentsSnap = await db
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .get();
              final teachersSnap = await db
                  .collection('users')
                  .where('role', isEqualTo: 'teacher')
                  .get();
              final examsSnap = await db.collection('exams').get();

              return {
                'users': usersSnap.size,
                'students': studentsSnap.size,
                'teachers': teachersSnap.size,
                'courses': coursesSnap.size,
                'assignments': assignmentsSnap.size,
                'exams': examsSnap.size,
                'pending': pendingSnap.size,
              };
            }(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height:
                      ResponsiveHelper.getResponsiveButtonHeight(context) * 2,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              final data =
                  snap.data ??
                  {
                    'users': 0,
                    'students': 0,
                    'teachers': 0,
                    'courses': 0,
                    'assignments': 0,
                    'exams': 0,
                    'pending': 0,
                  };
              final stats = [
                {
                  'title': 'Total Users',
                  'value': data['users'].toString(),
                  'icon': Icons.people,
                  'subtitle':
                      '${data['students']} students, ${data['teachers']} teachers',
                  'color': const Color(0xFF8B5E3C),
                },
                {
                  'title': 'Active Courses',
                  'value': data['courses'].toString(),
                  'icon': Icons.school,
                  'subtitle': 'Currently available',
                  'color': const Color(0xFF6B9D5C),
                },
                {
                  'title': 'Assignments',
                  'value': data['assignments'].toString(),
                  'icon': Icons.assignment,
                  'subtitle': 'Total created',
                  'color': const Color(0xFF5B7DB9),
                },
                {
                  'title': 'Pending Approvals',
                  'value': data['pending'].toString(),
                  'icon': Icons.pending_actions,
                  'subtitle': 'Require attention',
                  'color': const Color(0xFFC75D3A),
                },
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.getResponsiveCrossAxisCount(
                    context,
                    mobile: 1,
                    tablet: 2,
                    desktop: 4,
                  ),
                  crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                    context,
                  ),
                  mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                    context,
                  ),
                  childAspectRatio: ResponsiveHelper.isMobile(context)
                      ? 1.6
                      : 1.3,
                ),
                itemCount: stats.length,
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  return _StatCard(
                    title: stat['title'] as String,
                    value: stat['value'] as String,
                    icon: stat['icon'] as IconData,
                    subtitle: stat['subtitle'] as String,
                    color: stat['color'] as Color,
                  );
                },
              );
            },
          ),
          SizedBox(
            height: ResponsiveHelper.getResponsiveSpacing(
              context,
              mobile: 24,
              tablet: 32,
              desktop: 40,
            ),
          ),
          // Recent Activity from Firestore
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 18,
                    tablet: 20,
                    desktop: 24,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy('createdAt', descending: true)
                .limit(10)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Error loading activity: ${snapshot.error}',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'No recent activity',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final activities = snapshot.data!.docs.take(5).toList();

              if (activities.isEmpty) {
                return Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'No recent activity',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Container(
                width: double.infinity,
                constraints: const BoxConstraints(
                  minHeight: 100,
                  maxHeight: 500,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveCardRadius(context),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey[200]),
                  itemBuilder: (context, index) {
                    final doc = activities[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data['name'] as String? ?? 'Unknown';
                    final role = data['role'] as String? ?? 'user';
                    final createdAt = data['createdAt'] as Timestamp?;
                    final approved = data['approved'] as bool? ?? false;

                    IconData icon;
                    String title;
                    String subtitle;

                    if (!approved && (role == 'student' || role == 'parent')) {
                      icon = Icons.pending;
                      title = 'Pending Approval';
                      subtitle = '$name ($role) - Awaiting approval';
                    } else {
                      icon = Icons.person_add;
                      title = 'New User Registered';
                      subtitle = '$name joined as $role';
                    }

                    String timeAgo = 'Just now';
                    if (createdAt != null) {
                      final now = DateTime.now();
                      final created = createdAt.toDate();
                      final diff = now.difference(created);
                      if (diff.inDays > 0) {
                        timeAgo =
                            '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
                      } else if (diff.inHours > 0) {
                        timeAgo =
                            '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
                      } else if (diff.inMinutes > 0) {
                        timeAgo =
                            '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
                      }
                    }

                    return Padding(
                      padding: ResponsiveHelper.getResponsivePaddingAll(
                        context,
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: ResponsiveHelper.getResponsiveIconSize(
                              context,
                            ),
                            height: ResponsiveHelper.getResponsiveIconSize(
                              context,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8B5E3C,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: const Color(0xFF8B5E3C),
                              size: ResponsiveHelper.getResponsiveIconSize(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveHelper.getResponsiveSpacing(
                              context,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                        ),
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(
                                  height: ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    mobile: 2,
                                    tablet: 3,
                                    desktop: 4,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          mobile: 11,
                                          tablet: 12,
                                          desktop: 13,
                                        ),
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 11,
                                tablet: 12,
                                desktop: 13,
                              ),
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getResponsiveCardRadius(context),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.all(ResponsiveHelper.isMobile(context) ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 13,
                      desktop: 14,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
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
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 10,
                  tablet: 11,
                  desktop: 12,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF8B5E3C)),
      ),
    );
  }
}
