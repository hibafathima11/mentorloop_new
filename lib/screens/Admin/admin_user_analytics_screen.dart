// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentorloop/utils/colors.dart';
import 'package:mentorloop/utils/responsive.dart';

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
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              studentId.substring(
                0,
                studentId.length > 8 ? 8 : studentId.length,
              ),
              style: TextStyle(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 16,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E3C),
                    borderRadius: BorderRadius.circular(8),
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
