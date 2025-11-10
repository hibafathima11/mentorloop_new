import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/screens/Student/exam_take_screen.dart';

class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exams')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Exams',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<Course>>(
        stream: DataService.watchStudentCourses(user.uid),
        builder: (context, courseSnapshot) {
          if (courseSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (courseSnapshot.hasError) {
            return Center(
              child: Text(
                'Error loading courses: ${courseSnapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          final courses = courseSnapshot.data ?? const <Course>[];
          if (courses.isEmpty) {
            return const Center(child: Text('No courses enrolled'));
          }

          // Collect all exams from all courses
          return ListView.builder(
            padding: ResponsiveHelper.getResponsivePaddingAll(context),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return StreamBuilder<List<Exam>>(
                stream: DataService.watchCourseExams(course.id),
                builder: (context, examSnapshot) {
                  if (!examSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final exams = examSnapshot.data!;
                  if (exams.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 18,
                            tablet: 20,
                            desktop: 22,
                          ),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B5E3C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...exams.map((exam) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(exam.title),
                            subtitle: Text(exam.description),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExamTakeScreen(
                                      examId: exam.id,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Attend'),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

