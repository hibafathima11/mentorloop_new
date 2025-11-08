import 'package:flutter/material.dart';
import 'package:mentorloop/utils/colors.dart';
import 'package:mentorloop/utils/responsive.dart';
import 'package:mentorloop/utils/data_service.dart';
import 'package:mentorloop/models/entities.dart';

class AssignmentReviewScreen extends StatelessWidget {
  final String assignmentId;
  const AssignmentReviewScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Submissions',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<Submission>>(
          stream: DataService.watchAssignmentSubmissions(assignmentId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            if (items.isEmpty) {
              return const Center(child: Text('No submissions yet'));
            }
            return ListView.separated(
              padding: ResponsiveHelper.getResponsivePaddingAll(context),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final s = items[i];
                return Container(
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student: ${s.studentId}',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.attachmentUrl,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            if (s.score != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Score: ${s.score}',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),
                              if (s.feedback != null)
                                Text(
                                  'Feedback: ${s.feedback}',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final result = await showDialog<(double, String)?>(
                            context: context,
                            builder: (_) => const _GradeDialog(),
                          );
                          if (result != null) {
                            // simple update: create a graded copy (or update via separate collection if needed)
                            await DataService.submitAssignment(
                              Submission(
                                id: s.id,
                                assignmentId: s.assignmentId,
                                studentId: s.studentId,
                                attachmentUrl: s.attachmentUrl,
                                status: 'graded',
                                score: result.$1,
                                feedback: result.$2,
                              ),
                            );
                          }
                        },
                        child: const Text('Grade'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GradeDialog extends StatefulWidget {
  const _GradeDialog();
  @override
  State<_GradeDialog> createState() => _GradeDialogState();
}

class _GradeDialogState extends State<_GradeDialog> {
  final TextEditingController _score = TextEditingController();
  final TextEditingController _feedback = TextEditingController();

  @override
  void dispose() {
    _score.dispose();
    _feedback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Grade Submission'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _score,
            decoration: const InputDecoration(labelText: 'Score (0-100)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _feedback,
            decoration: const InputDecoration(labelText: 'Feedback'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final score = double.tryParse(_score.text.trim()) ?? 0;
            Navigator.pop<(double, String)>(context, (
              score,
              _feedback.text.trim(),
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
