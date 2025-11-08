import 'package:flutter/material.dart';
import 'package:mentorloop/utils/colors.dart';
import 'package:mentorloop/screens/Student/courses_list_screen.dart';
import 'package:mentorloop/utils/data_service.dart';
import 'package:mentorloop/models/entities.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 0,
        title: Text(
          'My courses',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const LearnedTodayCard(),
            const SizedBox(height: 16),
            // My enrolled courses
            StreamBuilder<List<Course>>(
              stream: FirebaseAuth.instance.currentUser == null
                  ? Stream.empty()
                  : DataService.watchStudentCourses(
                      FirebaseAuth.instance.currentUser!.uid,
                    ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final courses = snapshot.data!;
                if (courses.isEmpty) {
                  return const Center(child: Text('No enrolled courses yet'));
                }
                // Responsive columns
                final screenWidth = MediaQuery.of(context).size.width;
                int crossAxisCount;
                if (screenWidth >= 1200) {
                  crossAxisCount = 4;
                } else if (screenWidth >= 800) {
                  crossAxisCount = 3;
                } else {
                  crossAxisCount = 2;
                }
                const double spacing = 16;
                const double horizontalPadding = 32; // parent ListView padding
                final double available = screenWidth - horizontalPadding;
                final double tileWidth =
                    (available - (crossAxisCount - 1) * spacing) /
                    crossAxisCount;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: courses.map((c) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOut,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 12),
                          child: child,
                        ),
                      ),
                      child: _CourseTile(
                        tileWidth: tileWidth,
                        color: const Color(0xFFBBDEFB),
                        title: c.title,
                        completed: '-',
                        progress: 0.0,
                        barColor: const Color(0xFF1565C0),
                        playColor: const Color(0xFF2962FF),
                        onPlay: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseVideosListScreen(course: c),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LearnedTodayCard extends StatelessWidget {
  const LearnedTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DataService.watchStudentAssessmentsToday(uid),
      builder: (context, snapshot) {
        final totalSeconds = (snapshot.data ?? const [])
            .map((e) => (e['totalDurationSeconds'] as int?) ?? 0)
            .fold<int>(0, (a, b) => a + b);
        final goal = 60 * 60; // 60 minutes
        final progress = (totalSeconds / goal).clamp(0.0, 1.0);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF9C6D4C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Learned today',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(totalSeconds / 60).round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'min / 60min',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF7043),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CourseTile extends StatelessWidget {
  final double tileWidth;
  final Color color;
  final String title;
  final String completed;
  final double progress;
  final Color barColor;
  final Color playColor;
  final VoidCallback onPlay;

  const _CourseTile({
    required this.tileWidth,
    required this.color,
    required this.title,
    required this.completed,
    required this.progress,
    required this.barColor,
    required this.playColor,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tileWidth,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completed',
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                completed,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Color(0xFF263238),
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(Icons.play_arrow_rounded, color: playColor),
                  onPressed: onPlay,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
