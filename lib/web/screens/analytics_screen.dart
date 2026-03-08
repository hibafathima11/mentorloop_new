import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {
    'totalUsers': 0,
    'activeUsers': 0,
    'totalCourses': 0,
    'completionRate': 0.0,
    'userGrowth': '0%',
    'enrollmentGrowth': '0%',
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final db = FirebaseFirestore.instance;

      // Total Users
      final usersSnap = await db.collection('users').get();
      final totalUsers = usersSnap.size;

      // Active Users (those who have any activity in video_answers)
      final activeUsersSnap = await db.collection('video_answers').get();
      final activeUserIds = activeUsersSnap.docs
          .map((d) => d.data()['studentId'])
          .toSet();
      final activeUsers = activeUserIds.length;

      // Total Courses
      final coursesSnap = await db.collection('courses').get();
      final totalCourses = coursesSnap.size;

      // Completion Rate (Average from video_assessments)
      final assessmentsSnap = await db.collection('video_assessments').get();
      double avgCompletion = 0;
      if (assessmentsSnap.docs.isNotEmpty) {
        double totalAcc = 0;
        for (var doc in assessmentsSnap.docs) {
          final data = doc.data();
          final correct = (data['correctAnswers'] as num?)?.toDouble() ?? 0;
          final total = (data['totalQuestions'] as num?)?.toDouble() ?? 1;
          totalAcc += (correct / total);
        }
        avgCompletion = (totalAcc / assessmentsSnap.docs.length) * 100;
      }

      // Growth (mocked for now based on recent users in last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentUsersSnap = await db
          .collection('users')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo),
          )
          .get();
      final recentUserCount = recentUsersSnap.size;
      final growth = totalUsers > recentUserCount
          ? ((recentUserCount / (totalUsers - recentUserCount)) * 100)
                .toStringAsFixed(1)
          : '100';

      if (mounted) {
        setState(() {
          _stats = {
            'totalUsers': totalUsers,
            'activeUsers': activeUsers,
            'totalCourses': totalCourses,
            'completionRate': avgCompletion.toStringAsFixed(1),
            'userGrowth': '+$growth%',
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePaddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(
                metric: {
                  'title': 'Total Signups',
                  'value': _stats['totalUsers'].toString(),
                  'change': _stats['userGrowth'],
                  'isPositive': true,
                  'icon': Icons.person_add,
                  'color': const Color(0xFF8B5E3C),
                },
              ),
              _MetricCard(
                metric: {
                  'title': 'Active Users',
                  'value': _stats['activeUsers'].toString(),
                  'change':
                      '+${(_stats['activeUsers'] / (_stats['totalUsers'] != 0 ? _stats['totalUsers'] : 1) * 100).toStringAsFixed(1)}%',
                  'isPositive': true,
                  'icon': Icons.people,
                  'color': const Color(0xFF6B9D5C),
                },
              ),
              _MetricCard(
                metric: {
                  'title': 'Total Courses',
                  'value': _stats['totalCourses'].toString(),
                  'change': '+0%', // Can be enhanced later
                  'isPositive': true,
                  'icon': Icons.school,
                  'color': const Color(0xFF5B7DB9),
                },
              ),
              _MetricCard(
                metric: {
                  'title': 'Average Completion',
                  'value': '${_stats['completionRate']}%',
                  'change': '+2.1%', // Mocked change
                  'isPositive': true,
                  'icon': Icons.trending_up,
                  'color': const Color(0xFFC75D3A),
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Charts Section
          Text(
            'Performance Trends',
            style: TextStyle(
              fontSize: 20,
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
              childAspectRatio: isMobile ? 0.8 : 1.2,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final chartTitles = [
                'User Growth (Monthly)',
                'Course Popularity',
                'Engagement Rate',
                'Device Usage',
              ];
              return _ChartCard(
                title: chartTitles[index],
                type: index % 2 == 0 ? 'line' : 'pie',
              );
            },
          ),
          const SizedBox(height: 32),

          // User Retention
          Text(
            'User Retention Rate',
            style: TextStyle(
              fontSize: 20,
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Retention by Cohort',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    DropdownButton<String>(
                      value: 'Last 90 days',
                      items: ['Last 30 days', 'Last 60 days', 'Last 90 days']
                          .map(
                            (period) => DropdownMenuItem(
                              value: period,
                              child: Text(period),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {},
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...[
                  {'month': 'January', 'rate': 85},
                  {'month': 'February', 'rate': 78},
                  {'month': 'March', 'rate': 72},
                  {'month': 'April', 'rate': 68},
                ].map((data) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['month'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${data['rate']}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B5E3C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (data['rate'] as int) / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF8B5E3C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Top Performing Courses
          Text(
            'Top Performing Courses',
            style: TextStyle(
              fontSize: 20,
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
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final courses = [
                  {
                    'name': 'Flutter Development Basics',
                    'enrollments': 145,
                    'rating': 4.8,
                    'completion': 89,
                  },
                  {
                    'name': 'Data Science Fundamentals',
                    'enrollments': 132,
                    'rating': 4.7,
                    'completion': 82,
                  },
                  {
                    'name': 'Web Technologies Advanced',
                    'enrollments': 118,
                    'rating': 4.6,
                    'completion': 78,
                  },
                  {
                    'name': 'Mobile App Development',
                    'enrollments': 105,
                    'rating': 4.5,
                    'completion': 75,
                  },
                  {
                    'name': 'UI/UX Design Principles',
                    'enrollments': 92,
                    'rating': 4.4,
                    'completion': 71,
                  },
                ];

                final course = courses[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${course['name']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${course['rating']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.school,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${course['enrollments']} enrollments',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${course['completion']}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B5E3C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: (course['completion'] as int) / 100,
                                minHeight: 4,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8B5E3C),
                                ),
                              ),
                            ),
                          ),
                        ],
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

class _MetricCard extends StatelessWidget {
  final Map<String, dynamic> metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric['title'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (metric['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  metric['icon'] as IconData,
                  color: metric['color'] as Color,
                  size: 20,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metric['value'] as String,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    metric['isPositive']
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 16,
                    color: metric['isPositive'] ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    metric['change'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: metric['isPositive'] ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'vs last month',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String type;

  const _ChartCard({required this.title, required this.type});

  @override
  Widget build(BuildContext context) {
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
            title,
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
                  '${type.toUpperCase()} Chart Placeholder',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
