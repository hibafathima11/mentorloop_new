import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:mentorloop_new/widgets/non_skippable_video_player.dart';

class CourseVideoScreen extends StatefulWidget {
  final String videoId;
  final String videoUrl;
  final int durationSeconds;
  final String title;
  final String teacherId;
  const CourseVideoScreen({
    super.key,
    required this.videoId,
    required this.videoUrl,
    required this.durationSeconds,
    required this.title,
    required this.teacherId,
  });

  @override
  State<CourseVideoScreen> createState() => _CourseVideoScreenState();
}

class _CourseVideoScreenState extends State<CourseVideoScreen> {
  late VideoPlayerController _controller;
  StreamSubscription<List<VideoQuestion>>? _questionsSub;
  List<VideoQuestion> _questions = [];
  final Set<String> _askedQuestionIds = {};
  int _correctCount = 0;
  bool _isSavingAssessment = false;
  bool _isQuestionDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.addListener(_tickListener);

    _questionsSub = DataService.watchVideoQuestions(
      widget.videoId,
    ).listen((qs) => setState(() => _questions = qs));
  }

  void _tickListener() {
    if (!_controller.value.isInitialized || _isQuestionDialogOpen) return;

    final position = _controller.value.position;
    final positionSeconds = position.inSeconds;

    // Check if we've reached a question timestamp
    for (final q in _questions) {
      if (!_askedQuestionIds.contains(q.id) &&
          positionSeconds >= q.showAtSecond &&
          positionSeconds < q.showAtSecond + 2) {
        // 2 second window to catch the question
        _askedQuestionIds.add(q.id);
        _pauseAndAsk(q);
        break;
      }
    }
  }

  Future<void> _pauseAndAsk(VideoQuestion q) async {
    if (_isQuestionDialogOpen) return;

    setState(() {
      _isQuestionDialogOpen = true;
    });

    _controller.pause();

    final selected = await showDialog<int>(
      context: context,
      barrierDismissible: false, // Cannot dismiss without answering
      builder: (_) => _QuestionDialog(question: q),
    );

    if (!mounted) return;

    setState(() {
      _isQuestionDialogOpen = false;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selected != null) {
      final bool correct = selected == q.correctIndex;
      if (correct) {
        setState(() {
          _correctCount += 1;
        });
      }

      await DataService.saveVideoAnswer(
        videoId: widget.videoId,
        questionId: q.id,
        studentId: user.uid,
        selectedIndex: selected,
        isCorrect: correct,
      );

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              correct
                  ? '✅ Correct!'
                  : '❌ Incorrect. The correct answer was: ${q.options[q.correctIndex]}',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: correct ? Colors.green : Colors.red,
          ),
        );
      }
    }

    // Resume video after question is answered
    if (mounted && _controller.value.isInitialized) {
      _controller.play();
    }
  }

  Future<void> _completeAssessment() async {
    if (_isSavingAssessment) return;
    setState(() => _isSavingAssessment = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await DataService.saveVideoAssessmentResult(
          videoId: widget.videoId,
          studentId: user.uid,
          totalQuestions: _questions.length,
          correctAnswers: _correctCount,
          totalDurationSeconds: widget.durationSeconds,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Assessment saved')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSavingAssessment = false);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_tickListener);
    _controller.dispose();
    _questionsSub?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Exit Video?'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide a reason for exiting this video:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                maxLines: 3,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter your reason here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reason to exit';
                  }
                  if (value.trim().length < 5) {
                    return 'Reason must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Your progress will be saved.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final reason = reasonController.text.trim();
                _saveExitReason(reason);
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    reasonController.dispose();
    return shouldExit ?? false;
  }

  Future<void> _saveExitReason(String reason) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await DataService.saveVideoExitReason(
          videoId: widget.videoId,
          studentId: user.uid,
          reason: reason,
          exitedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error saving exit reason: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.secondaryBackground,
        appBar: AppBar(
          backgroundColor: AppColors.secondaryBackground,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
          title: Text(
            widget.title,
            style: TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: _isSavingAssessment ? null : _completeAssessment,
              child: _isSavingAssessment
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Finish', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_controller.value.isInitialized)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: NonSkippableVideoPlayer(
                  controller: _controller,
                  onPlay: () {
                    setState(() {});
                  },
                  onPause: () {
                    setState(() {});
                  },
                ),
              )
            else
              const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 16),
            // Progress and stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (_questions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Questions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${_questions.length}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.blue[200],
                          ),
                          Column(
                            children: [
                              Text(
                                'Correct',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '$_correctCount',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.blue[200],
                          ),
                          Column(
                            children: [
                              Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _controller.value.isInitialized
                                    ? '${((_controller.value.position.inSeconds / _controller.value.duration.inSeconds) * 100).toStringAsFixed(0)}%'
                                    : '0%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (_controller.value.isInitialized)
                    Text(
                      '⚠️ Skipping is disabled. Please watch the video continuously.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionDialog extends StatefulWidget {
  final VideoQuestion question;
  const _QuestionDialog({required this.question});

  @override
  State<_QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<_QuestionDialog> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button from dismissing
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.quiz, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Video Question',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.question.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select your answer:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              for (int i = 0; i < widget.question.options.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedIndex == i
                          ? Colors.blue
                          : Colors.grey[300]!,
                      width: _selectedIndex == i ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedIndex == i ? Colors.blue[50] : Colors.white,
                  ),
                  child: RadioListTile<int>(
                    value: i,
                    groupValue: _selectedIndex,
                    onChanged: (v) => setState(() => _selectedIndex = v),
                    title: Text(
                      widget.question.options[i],
                      style: TextStyle(
                        fontWeight: _selectedIndex == i
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    activeColor: Colors.blue,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: _selectedIndex == null
                ? null
                : () => Navigator.pop(context, _selectedIndex),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Submit Answer'),
          ),
        ],
      ),
    );
  }
}
