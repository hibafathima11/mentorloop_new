import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/widgets/admin_layout.dart';
import 'package:mentorloop_new/web/screens/admin_dashboard_screen.dart';
import 'package:mentorloop_new/web/screens/users_management_screen.dart';
import 'package:mentorloop_new/web/screens/courses_management_screen.dart';
import 'package:mentorloop_new/screens/Admin/student_approval_screen.dart';
import 'package:mentorloop_new/screens/Admin/teacher_credentials_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_parent_verification_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_subjects_screen.dart';
import 'package:mentorloop_new/web/screens/assignments_management_screen.dart';
import 'package:mentorloop_new/web/screens/exams_management_screen.dart';
import 'package:mentorloop_new/web/screens/analytics_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_complaints_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_parent_feedback_screen.dart';
import 'package:mentorloop_new/screens/Admin/admin_teacher_chat_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'Users',
    'Student Approval',
    'Parent Verification',
    'Teacher Credentials',
    'Subjects',
    'Courses',
    'Assignments',
    'Exams',
    'User Analytics',
    'View Complaints',
    'Parent Feedback',
    'Chat with Teacher',
  ];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const WebAdminDashboard();
      case 1:
        return const UsersManagementScreen();
      case 2:
        return const StudentApprovalScreen();
      case 3:
        return const AdminParentVerificationScreen();
      case 4:
        return const TeacherCredentialsScreen();
      case 5:
        return const AdminSubjectsScreen();
      case 6:
        return const CoursesManagementScreen();
      case 7:
        return const AssignmentsManagementScreen();
      case 8:
        return const ExamsManagementScreen();
      case 9:
        return const AnalyticsScreen();
      case 10:
        return const AdminComplaintsScreen();
      case 11:
        return const AdminParentFeedbackScreen();
      case 12:
        return const AdminTeacherChatScreen();
      default:
        return Center(
          child: Text(
            '${_titles[_selectedIndex]} Screen Coming Soon',
            style: const TextStyle(fontSize: 24, color: Colors.grey),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: _titles[_selectedIndex],
      child: _buildContent(),
      onNavItemSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedIndex: _selectedIndex,
    );
  }
}
