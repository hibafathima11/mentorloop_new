
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop_new/utils/analytics_service.dart';
import 'package:mentorloop_new/utils/responsive.dart';


class AnalyticsScreen extends StatefulWidget {
  final String courseId;

  const AnalyticsScreen({super.key, required this.courseId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _loading = true;
  int _totalAssignments = 0;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    try {
      final total =
          await AnalyticsService.totalAssignmentsForCourse(widget.courseId);

      if (mounted) {
        setState(() {
          _totalAssignments = total;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: ResponsiveHelper.getResponsivePaddingAll(context),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ================= OVERVIEW =================
                  Row(
                    children: [
                      _StatCard(
                        title: 'Assignments',
                        value: _totalAssignments.toString(),
                        icon: Icons.assignment,
                      ),
                      const SizedBox(width: 16),
                      _StatCard(
                        title: 'Avg Score',
                        value: '—',
                        icon: Icons.analytics,
                      ),
                    ],
                  ),

                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 24,
                      tablet: 28,
                      desktop: 32,
                    ),
                  ),

                  /// ================= STUDENT ACCURACY =================
                  Text(
                    'Student Accuracy',
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

                  Expanded(child: _StudentAccuracyList()),
                ],
              ),
      ),
    );
  }
}

/// =======================================================
/// STAT CARD
/// =======================================================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: const Color(0xFF8B5E3C),
              size: ResponsiveHelper.getResponsiveIconSize(context),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: const Color(0xFF8B5E3C),
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 22,
                  tablet: 26,
                  desktop: 30,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// STUDENT ACCURACY LIST
/// =======================================================
class _StudentAccuracyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No students found'));
        }

        final students = snapshot.data!.docs;

        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            final studentId = student.id;
            final name = student['name'] ?? 'Student';

            return FutureBuilder<double>(
              future:
                  AnalyticsService.studentAssessmentAccuracy(studentId),
              builder: (context, accSnap) {
                final accuracy =
                    ((accSnap.data ?? 0) * 100).toStringAsFixed(1);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF8B5E3C),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('Accuracy: $accuracy%'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
