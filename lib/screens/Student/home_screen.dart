// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:mentorloop_new/screens/Student/account_screen.dart';
import 'package:mentorloop_new/screens/Student/assignment_submit_screen.dart';
import 'package:mentorloop_new/screens/Student/course_screen.dart';
import 'package:mentorloop_new/screens/Student/my_courses_screen.dart';
import 'package:mentorloop_new/screens/Student/messages_screen.dart';
import 'package:mentorloop_new/screens/Student/exam_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/utils/auth_service.dart';
import 'package:mentorloop_new/utils/data_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  String _displayName = '';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final profile = await AuthService.getUserProfile(user.uid);
      setState(() {
        _displayName = (profile?['name'] as String?)?.trim().isNotEmpty == true
            ? profile!['name'] as String
            : (user.email ?? 'Student');
        _photoUrl = profile?['photoUrl'] as String?;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProgressCard(),
                  const SizedBox(height: 16),
                  _buildLearningBanner(),
                  const SizedBox(height: 16),
                  _buildMeetupCard(),
                  const SizedBox(height: 16),
                  _buildAssignmentsCard(),
                  const SizedBox(height: 16),
                  _buildExamsCard(),
                  const SizedBox(height: 24),
                  _buildComplaintsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF8B5E3C), // Brown background
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${_displayName.isEmpty ? 'Student' : _displayName.split(' ').first}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Let's start learning",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountScreen(),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                      ? NetworkImage(_photoUrl!)
                      : null,
                  child: (_photoUrl == null || _photoUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DataService.watchStudentAssessmentsToday(uid),
      builder: (context, snapshot) {
        final totalSeconds = (snapshot.data ?? const [])
            .map((e) => (e['totalDurationSeconds'] as int?) ?? 0)
            .fold<int>(0, (a, b) => a + b);
        const goalSeconds = 60 * 60;
        final progress = (totalSeconds / goalSeconds).clamp(0.0, 1.0);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8FF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Learned today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF424242),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyCoursesScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'My courses',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(totalSeconds / 60).round()}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const Text(
                    'min',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const Text(
                    ' / 60min',
                    style: TextStyle(fontSize: 16, color: Color(0xFF757575)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF9800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLearningBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                const Text(
                  'What do you want to learn today?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800), // Orange
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, size: 50, color: Color(0xFFFF9800)),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetupCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                const Text(
                  'Meetup',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B1FA2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'On-line exchange of learning experiences',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7B1FA2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups, size: 35, color: Color(0xFF7B1FA2)),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentsCard() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    // Replace this with your logic to get the student's course IDs
    // For example, you might have a DataService.watchStudentCourses(user.uid)
    return StreamBuilder<List<Course>>(
      stream: DataService.watchStudentCourses(user.uid),
      builder: (context, courseSnap) {
        if (!courseSnap.hasData) return const SizedBox.shrink();
        final courses = courseSnap.data!;
        if (courses.isEmpty) return const SizedBox.shrink();

        // Collect all assignments from all courses
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Assignments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5E3C),
                  fontSize: 18,
                ),
              ),
            ),
            ...courses.map(
              (course) => StreamBuilder<List<Assignment>>(
                stream: DataService.watchCourseAssignments(course.id),
                builder: (context, assignSnap) {
                  if (!assignSnap.hasData) return const SizedBox.shrink();
                  final assignments = assignSnap.data!;
                  if (assignments.isEmpty) return const SizedBox.shrink();
                  return Column(
                    children: assignments
                        .map(
                          (assignment) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(assignment.title),
                              subtitle: Text(assignment.description),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9800),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Submit'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AssignmentSubmitScreen(
                                            assignmentId: assignment.id,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExamsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        tileColor: const Color(0xFFE8F5E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(
          Icons.quiz,
          color: Color(0xFF8B5E3C),
          size: 36,
        ),
        title: const Text(
          'Exams',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
            fontSize: 18,
          ),
        ),
        subtitle: const Text(
          'View and attend exams',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5E3C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('View'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExamListScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildComplaintsCard() {
    final _complaintController = TextEditingController();
    bool _isSubmitting = false;

    void _showComplaintDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Submit a Complaint'),
                content: TextField(
                  controller: _complaintController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe your complaint...',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            setState(() => _isSubmitting = true);
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null ||
                                _complaintController.text.trim().isEmpty)
                              return;
                            await FirebaseFirestore.instance
                                .collection('complaints')
                                .add({
                                  'studentId': user.uid,
                                  'studentEmail': user.email,
                                  'complaint': _complaintController.text.trim(),
                                  'createdAt': FieldValue.serverTimestamp(),
                                });
                            setState(() => _isSubmitting = false);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Complaint submitted'),
                              ),
                            );
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit'),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        tileColor: const Color(0xFFFFF3E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(
          Icons.report_problem,
          color: Color(0xFFD32F2F),
          size: 36,
        ),
        title: const Text(
          'Submit a Complaint',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
            fontSize: 18,
          ),
        ),
        subtitle: const Text(
          'Send your complaint directly to admin',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Add'),
          onPressed: () => _showComplaintDialog(context),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF8B5E3C), // Brown background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.book, 'Course', 1),
              _buildCenterSearchButton(),
              _buildNavItem(Icons.message, 'Message', 3),
              _buildNavItem(Icons.person, 'Account', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (label == 'Account') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountScreen()),
          );
          return;
        }
        if (label == 'Course') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CourseScreen()),
          );
          return;
        }
        if (label == 'Message') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessagesScreen()),
          );
          return;
        }
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterSearchButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CourseScreen(autofocusSearch: true),
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFD7CCC8), // Lighter brown
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.search, color: Color(0xFF8B5E3C), size: 28),
      ),
    );
  }
}
