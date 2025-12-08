import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/widgets/admin_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return AdminLayout(
      title: 'Dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid (live counts)
          FutureBuilder<Map<String, int>>(
            future: () async {
              final db = FirebaseFirestore.instance;
              final usersSnap = await db.collection('users').get();
              final coursesSnap = await db.collection('courses').get();
              final assignmentsSnap = await db.collection('assignments').get();
              final pendingSnap = await db
                  .collection('users')
                  .where('approved', isEqualTo: false)
                  .get();

              return {
                'users': usersSnap.size,
                'courses': coursesSnap.size,
                'assignments': assignmentsSnap.size,
                'pending': pendingSnap.size,
              };
            }(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final data = snap.data ?? {'users': 0, 'courses': 0, 'assignments': 0, 'pending': 0};
              final stats = [
                {'title': 'Total Users', 'value': data['users'].toString(), 'icon': Icons.people},
                {'title': 'Active Courses', 'value': data['courses'].toString(), 'icon': Icons.school},
                {'title': 'Total Assignments', 'value': data['assignments'].toString(), 'icon': Icons.assignment},
                {'title': 'Pending Approvals', 'value': data['pending'].toString(), 'icon': Icons.pending_actions},
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: stats.length,
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  return _StatCard(
                    title: stat['title'] as String,
                    value: stat['value'] as String,
                    icon: stat['icon'] as IconData,
                    index: index,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
          // Charts Section
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isMobile ? 1.2 : 1.5,
            ),
            itemCount: 2,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      index == 0 ? 'User Growth' : 'Course Activity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            index == 0 ? 'Chart Placeholder' : 'Chart Placeholder',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Recent Activity
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final activities = [
                  {
                    'title': 'New user registered',
                    'subtitle': 'John Doe joined as student',
                    'time': '2 hours ago',
                    'icon': Icons.person_add,
                  },
                  {
                    'title': 'Course created',
                    'subtitle': 'Advanced Flutter by Sarah',
                    'time': '4 hours ago',
                    'icon': Icons.school,
                  },
                  {
                    'title': 'Assignment submitted',
                    'subtitle': 'Mike submitted assignment #5',
                    'time': '6 hours ago',
                    'icon': Icons.assignment_turned_in,
                  },
                  {
                    'title': 'User approved',
                    'subtitle': 'Emma verified as teacher',
                    'time': '8 hours ago',
                    'icon': Icons.verified,
                  },
                  {
                    'title': 'System update',
                    'subtitle': 'Platform maintenance completed',
                    'time': '1 day ago',
                    'icon': Icons.update,
                  },
                ];

                final activity = activities[index];

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5E3C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          activity['icon'] as IconData,
                          color: const Color(0xFF8B5E3C),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        activity['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
  final int index;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF8B5E3C),
      const Color(0xFF6B9D5C),
      const Color(0xFF5B7DB9),
      const Color(0xFFC75D3A),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors[index],
            colors[index].withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors[index].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                icon,
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
