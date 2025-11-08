import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';

class CourseVideoScreen extends StatefulWidget {
  final String videoId;
  final String videoUrl;
  final int durationSeconds;
  final String title;
  const CourseVideoScreen({
    super.key,
    required this.videoId,
    required this.videoUrl,
    required this.durationSeconds,
    required this.title,
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
    if (!_controller.value.isInitialized) return;
    final position = _controller.value.position.inSeconds;
    for (final q in _questions) {
      if (!_askedQuestionIds.contains(q.id) && position >= q.showAtSecond) {
        _askedQuestionIds.add(q.id);
        _pauseAndAsk(q);
        break;
      }
    }
  }

  Future<void> _pauseAndAsk(VideoQuestion q) async {
    _controller.pause();
    final selected = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _QuestionDialog(question: q),
    );
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selected != null) {
      final bool correct = selected == q.correctIndex;
      if (correct) _correctCount += 1;
      await DataService.saveVideoAnswer(
        videoId: widget.videoId,
        questionId: q.id,
        studentId: user.uid,
        selectedIndex: selected,
        isCorrect: correct,
      );
    }
    _controller.play();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: VideoPlayer(_controller),
            )
          else
            const AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: 8),
          Text(
            'Answered correctly: $_correctCount / ${_questions.length}',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
      floatingActionButton: _controller.value.isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
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
    return AlertDialog(
      title: const Text('Quick Question'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.question.question),
          const SizedBox(height: 12),
          for (int i = 0; i < widget.question.options.length; i++)
            RadioListTile<int>(
              value: i,
              groupValue: _selectedIndex,
              onChanged: (v) => setState(() => _selectedIndex = v),
              title: Text(widget.question.options[i]),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _selectedIndex == null
              ? null
              : () => Navigator.pop(context, _selectedIndex),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
