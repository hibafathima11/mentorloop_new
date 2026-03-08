import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/models/entities.dart';

class ExamReviewScreen extends StatelessWidget {
  final String examId;
  final String examTitle;

  const ExamReviewScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(
          '$examTitle Attempts',
          style: const TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF8B5E3C)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ExamAttempt>>(
          stream: DataService.watchExamAttempts(examId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final attempts = snapshot.data ?? [];
            if (attempts.isEmpty) {
              return const Center(child: Text('No attempts yet.'));
            }
            return ListView.builder(
              padding: ResponsiveHelper.getResponsivePaddingAll(context),
              itemCount: attempts.length,
              itemBuilder: (context, i) {
                final attempt = attempts[i];
                return _AttemptCard(attempt: attempt, examId: examId);
              },
            );
          },
        ),
      ),
    );
  }
}

class _AttemptCard extends StatefulWidget {
  final ExamAttempt attempt;
  final String examId;

  const _AttemptCard({required this.attempt, required this.examId});

  @override
  State<_AttemptCard> createState() => _AttemptCardState();
}

class _AttemptCardState extends State<_AttemptCard> {
  String? _studentName;

  @override
  void initState() {
    super.initState();
    _loadStudentName();
  }

  Future<void> _loadStudentName() async {
    final user = await DataService.getUser(widget.attempt.studentId);
    if (mounted) {
      setState(() {
        _studentName = user?.name ?? 'Unknown Student';
      });
    }
  }

  void _showAnswersDetails(BuildContext context, List<ExamQuestion> questions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_studentName\'s Details',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B5E3C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: questions.length,
                      itemBuilder: (context, i) {
                        final q = questions[i];
                        final selectedIndex = widget.attempt.answers[q.id];
                        final isCorrect = selectedIndex == q.correctIndex;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedIndex == null
                                  ? Colors.grey
                                  : (isCorrect ? Colors.green : Colors.red),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q: ${q.question}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Student Answer: ${selectedIndex != null ? q.options.elementAtOrNull(selectedIndex) ?? 'Index Error' : 'Skipped'}',
                              ),
                              Text(
                                'Correct Answer: ${q.options.elementAtOrNull(q.correctIndex) ?? 'Unknown'}',
                                style: const TextStyle(color: Colors.green),
                              ),
                              if (selectedIndex != null)
                                Text(
                                  isCorrect
                                      ? 'Correct (+${q.points})'
                                      : 'Incorrect (0)',
                                  style: TextStyle(
                                    color: isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          _studentName ?? 'Loading...',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Score: ${widget.attempt.score} / ${widget.attempt.totalPoints}',
          style: const TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          // Fetch questions to match with answers
          try {
            final questionsStream = DataService.watchExamQuestions(
              widget.examId,
            );
            final questionsSnapshot = await questionsStream.first;
            if (!context.mounted) return;
            _showAnswersDetails(context, questionsSnapshot);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading questions: $e')),
            );
          }
        },
      ),
    );
  }
}
