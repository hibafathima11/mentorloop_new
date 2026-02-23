// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/responsive.dart';

class AdminUserAnalyticsScreen extends StatefulWidget {
  const AdminUserAnalyticsScreen({super.key});

  @override
  State<AdminUserAnalyticsScreen> createState() =>
      _AdminUserAnalyticsScreenState();
}

class _AdminUserAnalyticsScreenState extends State<AdminUserAnalyticsScreen> {
  // Last 7 days window for engagement
  late final DateTime _since = DateTime.now().subtract(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'User Analytics',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Students (last 7 days)',
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
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
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('video_answers')
                    .where('answeredAt', isGreaterThan: _since)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final dynamic qs = snapshot.data;
                  final List docs = qs?.docs ?? const [];
                  if (docs.isEmpty) {
                    return const Text(
                      'No activity recorded in the selected period.',
                    );
                  }

                  // Aggregate counts per studentId
                  final Map<String, int> counts = {};
                  for (final d in docs) {
                    final m = d.data();
                    final sid = (m['studentId'] as String?) ?? 'unknown';
                    counts[sid] = (counts[sid] ?? 0) + 1;
                  }

                  // Sort by count desc and take top 20
                  final entries = counts.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  final top = entries.take(20).toList();
                  final maxCount = top.first.value.clamp(1, 1 << 30);

                  // Summary cards
                  final totalActive = counts.length;
                  final totalEvents = docs.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryRow(
                        context,
                        totalActive: totalActive,
                        totalEvents: totalEvents,
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveMargin(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),
                      // Simple horizontal bar chart
                      Container(
                        width: double.infinity,
                        padding: ResponsiveHelper.getResponsivePaddingAll(
                          context,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveCardRadius(context),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Active Students',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      mobile: 16,
                                      tablet: 18,
                                      desktop: 20,
                                    ),
                              ),
                            ),
                            SizedBox(
                              height: ResponsiveHelper.getResponsiveMargin(
                                context,
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                            ),
                            ...top.map(
                              (e) => _barRow(context, e.key, e.value, maxCount),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Detailed Active Students',
                        style: TextStyle(
                          color: const Color(0xFF8B5E3C),
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: top.length,
                        itemBuilder: (context, index) {
                          final studentId = top[index].key;
                          final count = top[index].value;
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(studentId)
                                .get(),
                            builder: (context, userSnap) {
                              if (!userSnap.hasData) return const SizedBox();
                              final userData =
                                  userSnap.data!.data()
                                      as Map<String, dynamic>? ??
                                  {};
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  onTap: () => _showStudentDetails(
                                    studentId,
                                    userData,
                                    count,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(
                                      0xFF8B5E3C,
                                    ).withOpacity(0.1),
                                    backgroundImage:
                                        userData['photoUrl'] != null
                                        ? NetworkImage(userData['photoUrl'])
                                        : null,
                                    child: userData['photoUrl'] == null
                                        ? Text(
                                            (userData['name'] ?? 'U')[0]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFF8B5E3C),
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    userData['name'] ?? studentId,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    userData['email'] ?? 'No email',
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF8B5E3C,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$count Activities',
                                      style: const TextStyle(
                                        color: Color(0xFF8B5E3C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required int totalActive,
    required int totalEvents,
  }) {
    final cardRadius = ResponsiveHelper.getResponsiveCardRadius(context);
    final pad = ResponsiveHelper.getResponsivePaddingAll(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: pad,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Students',
                  style: TextStyle(fontWeight: FontWeight.w700),
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
                  '$totalActive',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: ResponsiveHelper.getResponsiveMargin(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        Expanded(
          child: Container(
            padding: pad,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Plays/Answers',
                  style: TextStyle(fontWeight: FontWeight.w700),
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
                  '$totalEvents',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _barRow(
    BuildContext context,
    String studentId,
    int count,
    int maxCount,
  ) {
    final double barMaxWidth =
        MediaQuery.of(context).size.width - 120; // rough layout
    final double fraction = count / (maxCount == 0 ? 1 : maxCount);
    final double barWidth = (barMaxWidth * fraction).clamp(40, barMaxWidth);

    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveHelper.getResponsiveMargin(
          context,
          mobile: 10,
          tablet: 12,
          desktop: 14,
        ),
      ),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(studentId)
            .get(),
        builder: (context, userSnap) {
          String displayName = studentId.substring(
            0,
            studentId.length > 8 ? 8 : studentId.length,
          );
          String? photoUrl;
          if (userSnap.hasData && userSnap.data!.exists) {
            final userData = userSnap.data!.data() as Map<String, dynamic>;
            displayName = userData['name'] ?? displayName;
            photoUrl = userData['photoUrl'] as String?;
          }

          return Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF8B5E3C).withOpacity(0.1),
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl == null
                    ? Text(
                        displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8B5E3C),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: Text(
                  displayName,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    Container(
                      height: 12,
                      width: barWidth,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF8B5E3C),
                            const Color(0xFF8B5E3C).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStudentDetails(
    String studentId,
    Map<String, dynamic> userData,
    int activityCount,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF8B5E3C).withOpacity(0.1),
                          backgroundImage: userData['photoUrl'] != null
                              ? NetworkImage(userData['photoUrl'] as String)
                              : null,
                          child: userData['photoUrl'] == null
                              ? Text(
                                  (userData['name'] ?? 'S').toString()[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(0xFF8B5E3C),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? 'Unknown Name',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userData['email'] ?? '',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5E3C).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$activityCount activities (last 7 days)',
                                  style: const TextStyle(
                                    color: Color(0xFF8B5E3C),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _detailTile(
                      Icons.phone,
                      'Phone',
                      userData['phone']?.toString() ?? 'N/A',
                    ),
                    _detailTile(
                      Icons.calendar_today,
                      'Registered',
                      userData['createdAt'] != null
                          ? (userData['createdAt'] as Timestamp).toDate().toString().split(' ')[0]
                          : 'N/A',
                    ),
                    const Divider(height: 40),
                    const Text(
                      'Guardian Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E3C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('guardians')
                          .where('studentId', isEqualTo: studentId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No guardian details found');
                        }
                        final guardian = snapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                        return Column(
                          children: [
                            _detailTile(
                              Icons.person,
                              'Name',
                              guardian['name']?.toString() ?? 'N/A',
                            ),
                            _detailTile(
                              Icons.family_restroom,
                              'Relation',
                              guardian['relation']?.toString() ?? 'N/A',
                            ),
                            _detailTile(
                              Icons.phone,
                              'Phone',
                              guardian['phone']?.toString() ?? 'N/A',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Applied Courses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E3C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('courses')
                          .where('studentIds', arrayContains: studentId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No courses applied yet');
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: snapshot.data!.docs.map((doc) {
                            final course = doc.data() as Map<String, dynamic>;
                            return Chip(
                              label: Text(course['title'] ?? 'Course'),
                              backgroundColor: const Color(0xFF8B5E3C).withOpacity(0.1),
                              labelStyle: const TextStyle(color: Color(0xFF8B5E3C)),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5E3C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close Details',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
