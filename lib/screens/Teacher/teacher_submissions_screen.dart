import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/screens/Teacher/assignment_review_screen.dart';
import 'package:mentorloop_new/screens/Teacher/exam_review_screen.dart';

class TeacherSubmissionsTabsScreen extends StatelessWidget {
  const TeacherSubmissionsTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.secondaryBackground,
        appBar: AppBar(
          title: const Text(
            'Submissions & Logs',
            style: TextStyle(
              color: Color(0xFF8B5E3C),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF8B5E3C),
            indicatorColor: Color(0xFF8B5E3C),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Assignments'),
              Tab(text: 'Exams'),
              Tab(text: 'Video Skips'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_AssignmentsListTab(), _ExamsListTab(), _VideoLogsTab()],
        ),
      ),
    );
  }
}

class _AssignmentsListTab extends StatelessWidget {
  const _AssignmentsListTab();

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (teacherId.isEmpty) return const Center(child: Text('No user'));

    return StreamBuilder<List<Assignment>>(
      stream: DataService.watchTeacherAssignments(teacherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No assignments found.'));
        }
        return ListView.builder(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final a = items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveCardRadius(context),
                ),
              ),
              child: ListTile(
                title: Text(
                  a.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Due: ${a.dueAt.toDate().toString().split('.')[0]}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AssignmentReviewScreen(assignmentId: a.id),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _ExamsListTab extends StatelessWidget {
  const _ExamsListTab();

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (teacherId.isEmpty) return const Center(child: Text('No user'));

    return StreamBuilder<List<Exam>>(
      stream: DataService.watchTeacherExams(teacherId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No exams found.'));
        }
        return ListView.builder(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final e = items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveCardRadius(context),
                ),
              ),
              child: ListTile(
                title: Text(
                  e.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Duration: ${e.durationMinutes} mins'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ExamReviewScreen(examId: e.id, examTitle: e.title),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _VideoLogsTab extends StatefulWidget {
  const _VideoLogsTab();

  @override
  State<_VideoLogsTab> createState() => _VideoLogsTabState();
}

class _VideoLogsTabState extends State<_VideoLogsTab> {
  Map<String, String> _studentNames = {};

  Future<String> _getStudentName(String studentId) async {
    if (_studentNames.containsKey(studentId)) {
      return _studentNames[studentId]!;
    }
    final userMap = await DataService.getUser(studentId);
    final name = userMap?.name ?? 'Student';
    _studentNames[studentId] = name;
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DataService.watchAllVideoExitLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return const Center(child: Text('No video skips recorded.'));
        }
        return ListView.builder(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          itemCount: logs.length,
          itemBuilder: (context, i) {
            final log = logs[i];
            final reason = log['reason'] ?? 'Unknown';
            final studentId = log['studentId'] ?? '';
            final videoId = log['videoId'] ?? '';
            // Timestamp to date
            final exitedAt = log['exitedAt'];
            final dateStr = exitedAt != null
                ? (exitedAt as dynamic).toDate().toString().split('.')[0]
                : 'Unknown Data';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getResponsiveCardRadius(context),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: _getStudentName(studentId),
                      builder: (context, nameSnap) {
                        return Text(
                          'Student: ${nameSnap.data ?? 'Loading...'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Video ID: $videoId',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reason: $reason',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time: $dateStr',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
