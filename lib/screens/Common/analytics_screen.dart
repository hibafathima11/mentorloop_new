import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/analytics_service.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/responsive.dart';

class AnalyticsScreen extends StatefulWidget {
  final String courseId;
  final String? assignmentId;
  final String? studentId;
  const AnalyticsScreen({
    super.key,
    required this.courseId,
    this.assignmentId,
    this.studentId,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int? _totalAssignments;
  double? _avgScore;
  double? _studentAccuracy;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final total = await AnalyticsService.totalAssignmentsForCourse(
        widget.courseId,
      );
      double? avg;
      if (widget.assignmentId != null) {
        avg = await AnalyticsService.averageScoreForAssignment(
          widget.assignmentId!,
        );
      }
      double? acc;
      if (widget.studentId != null) {
        acc = await AnalyticsService.studentAssessmentAccuracy(
          widget.studentId!,
        );
      }
      setState(() {
        _totalAssignments = total;
        _avgScore = avg;
        _studentAccuracy = acc;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showTotalAssignmentsDetail() async {
    final assignments =
        await AnalyticsService.getAssignmentsForCourse(widget.courseId);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Total assignments for course',
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Total: ${assignments.length}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: assignments.length,
                itemBuilder: (context, index) {
                  final a = assignments[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF8B5E3C).withOpacity(0.1),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF8B5E3C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      a['title'] ?? 'Untitled',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAverageScoreDetail() async {
    final assignments =
        await AnalyticsService.getAssignmentsForCourse(widget.courseId);
    final List<Map<String, dynamic>> results = [];
    for (final a in assignments) {
      final avg = await AnalyticsService.averageScoreForAssignment(a['id']!);
      results.add({'title': a['title'], 'avg': avg});
    }
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Average score for assignment',
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'No assignments in this course.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final r = results[index];
                        return ListTile(
                          title: Text(
                            r['title'] as String? ?? 'Untitled',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(
                            (r['avg'] as double).toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFF8B5E3C),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStudentAssessmentDetail() async {
    final studentIds =
        await AnalyticsService.getCourseStudentIds(widget.courseId);
    final List<Map<String, dynamic>> results = [];
    for (final sid in studentIds) {
      final name = await AnalyticsService.getUserDisplayName(sid);
      final accuracy =
          await AnalyticsService.studentAssessmentAccuracy(sid);
      results.add({
        'studentId': sid,
        'name': name,
        'accuracy': accuracy,
      });
    }
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Student assessment summary',
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'No students enrolled in this course yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final r = results[index];
                        final acc = (r['accuracy'] as double) * 100;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF8B5E3C).withOpacity(0.1),
                            child: Text(
                              (r['name'] as String).isNotEmpty
                                  ? (r['name'] as String)[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Color(0xFF8B5E3C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            r['name'] as String? ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(
                            '${acc.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Color(0xFF8B5E3C),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Analytics',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: ResponsiveHelper.getResponsivePaddingAll(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _tile(
                    'Total assignments for course',
                    _totalAssignments?.toString() ?? '-',
                    onTap: _showTotalAssignmentsDetail,
                  ),
                  const SizedBox(height: 12),
                  _tile(
                    'Average score for assignment',
                    _avgScore == null ? '-' : _avgScore!.toStringAsFixed(1),
                    onTap: _showAverageScoreDetail,
                  ),
                  const SizedBox(height: 12),
                  _tile(
                    'Student assessment summary',
                    _studentAccuracy == null
                        ? '-'
                        : '${(_studentAccuracy! * 100).toStringAsFixed(1)}%',
                    onTap: _showStudentAssessmentDetail,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _tile(String label, String value, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF8B5E3C),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
