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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
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
                  ),
                  const SizedBox(height: 12),
                  _tile(
                    'Average score for assignment',
                    _avgScore == null ? '-' : _avgScore!.toStringAsFixed(1),
                  ),
                  const SizedBox(height: 12),
                  _tile(
                    'Student assessment accuracy',
                    _studentAccuracy == null
                        ? '-'
                        : '${(_studentAccuracy! * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _tile(String label, String value) {
    return Container(
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
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(value, style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
