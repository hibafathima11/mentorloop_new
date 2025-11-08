import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class ExamTakeScreen extends StatefulWidget {
  final String examId;
  const ExamTakeScreen({super.key, required this.examId});

  @override
  State<ExamTakeScreen> createState() => _ExamTakeScreenState();
}

class _ExamTakeScreenState extends State<ExamTakeScreen> {
  Exam? _exam;
  List<ExamQuestion> _questions = [];
  Map<String, int> _answers = {};
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  Future<void> _loadExam() async {
    final exam = await DataService.getExam(widget.examId);
    if (exam == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam not found')),
        );
        Navigator.pop(context);
      }
      return;
    }

    setState(() {
      _exam = exam;
    });

    DataService.watchExamQuestions(widget.examId).listen((questions) {
      if (mounted) {
        setState(() {
          _questions = questions;
          _loading = false;
        });
      }
    });
  }

  Future<void> _submitExam() async {
    if (_answers.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');

      // Calculate score
      int score = 0;
      int totalPoints = 0;
      for (final question in _questions) {
        totalPoints += question.points;
        final selectedIndex = _answers[question.id];
        if (selectedIndex != null && selectedIndex == question.correctIndex) {
          score += question.points;
        }
      }

      final attempt = ExamAttempt(
        id: '',
        examId: widget.examId,
        studentId: user.uid,
        answers: _answers,
        score: score,
        totalPoints: totalPoints,
        startedAt: firestore.Timestamp.now(),
        submittedAt: firestore.Timestamp.now(),
      );

      await DataService.createExamAttempt(attempt);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exam submitted! Score: $score/$totalPoints')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_exam == null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exam')),
        body: const Center(child: Text('No questions available')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(_exam!.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: ResponsiveHelper.getResponsivePaddingAll(context),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1} (${question.points} points)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(question.question),
                          const SizedBox(height: 16),
                          ...question.options.asMap().entries.map((entry) {
                            final optionIndex = entry.key;
                            final option = entry.value;
                            return RadioListTile<int>(
                              title: Text(option),
                              value: optionIndex,
                              groupValue: _answers[question.id],
                              onChanged: (value) {
                                setState(() {
                                  _answers[question.id] = value!;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitExam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Submit Exam',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

