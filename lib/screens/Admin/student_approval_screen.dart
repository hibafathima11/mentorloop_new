import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/auth_service.dart';
// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentApprovalScreen extends StatefulWidget {
  const StudentApprovalScreen({super.key});

  @override
  State<StudentApprovalScreen> createState() => _StudentApprovalScreenState();
}

class _StudentApprovalScreenState extends State<StudentApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Student Approval',
          style: TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B5E3C)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: ResponsiveHelper.getResponsivePaddingAll(context),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E3C),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveCardRadius(context),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pending Student Approvals",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 20,
                          tablet: 24,
                          desktop: 28,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveMargin(
                        context,
                        mobile: 10,
                        tablet: 15,
                        desktop: 20,
                      ),
                    ),
                    Text(
                      "Review and approve student registrations",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 30,
                  tablet: 40,
                  desktop: 50,
                ),
              ),
              // Pending Students List
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'student')
                    .where('approved', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B5E3C),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final dynamic qs = snapshot.data;
                  final List students = qs?.docs ?? [];

                  if (students.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getResponsiveMargin(
                              context,
                              mobile: 20,
                              tablet: 25,
                              desktop: 30,
                            ),
                          ),
                          Text(
                            'No pending approvals',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: students.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final uid = doc.id;
                      final email = data['email'] ?? '';
                      final phone = data['phone'] ?? '';
                      final createdAt = data['createdAt'];

                      return GestureDetector(
                        onTap: () => _showStudentDetails(uid, data),
                        child: Container(
                          margin: EdgeInsets.only(
                            bottom: ResponsiveHelper.getResponsiveMargin(
                              context,
                              mobile: 15,
                              tablet: 20,
                              desktop: 25,
                            ),
                          ),
                          padding: ResponsiveHelper.getResponsivePaddingAll(
                            context,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveCardRadius(context),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF8B5E3C),
                                    child: Text(
                                      email.isNotEmpty
                                          ? email[0].toUpperCase()
                                          : 'S',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ResponsiveHelper.getResponsiveMargin(
                                      context,
                                      mobile: 15,
                                      tablet: 20,
                                      desktop: 25,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          email,
                                          style: TextStyle(
                                            color: const Color(0xFF8B5E3C),
                                            fontSize:
                                                ResponsiveHelper.getResponsiveFontSize(
                                                  context,
                                                  mobile: 16,
                                                  tablet: 18,
                                                  desktop: 20,
                                                ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              ResponsiveHelper.getResponsiveMargin(
                                                context,
                                                mobile: 5,
                                                tablet: 8,
                                                desktop: 10,
                                              ),
                                        ),
                                        Text(
                                          'Phone: $phone',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize:
                                                ResponsiveHelper.getResponsiveFontSize(
                                                  context,
                                                  mobile: 14,
                                                  tablet: 16,
                                                  desktop: 18,
                                                ),
                                          ),
                                        ),
                                        if (createdAt != null)
                                          Text(
                                            'Registered: ${createdAt.toDate().toString().split(' ')[0]}',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize:
                                                  ResponsiveHelper.getResponsiveFontSize(
                                                    context,
                                                    mobile: 12,
                                                    tablet: 14,
                                                    desktop: 16,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ResponsiveHelper.getResponsiveMargin(
                                  context,
                                  mobile: 20,
                                  tablet: 25,
                                  desktop: 30,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await AuthService.approveStudent(uid);
                                          if (!context.mounted) return;

                                          // Show success message
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Student approved successfully!\n✅ Email notification sent.',
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: Duration(seconds: 4),
                                            ),
                                          );
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $e'),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(
                                                seconds: 4,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveHelper.getResponsiveCardRadius(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Approve',
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveHelper.getResponsiveFontSize(
                                                context,
                                                mobile: 14,
                                                tablet: 16,
                                                desktop: 18,
                                              ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ResponsiveHelper.getResponsiveMargin(
                                      context,
                                      mobile: 15,
                                      tablet: 20,
                                      desktop: 25,
                                    ),
                                  ),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        // Handle rejection
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Reject Student'),
                                            content: const Text(
                                              'Are you sure you want to reject this student?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // Delete user document
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(uid)
                                                      .delete();
                                                  Navigator.pop(context);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Student rejected',
                                                      ),
                                                      backgroundColor:
                                                          Colors.orange,
                                                    ),
                                                  );
                                                },
                                                child: const Text('Reject'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            ResponsiveHelper.getResponsiveCardRadius(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Reject',
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveHelper.getResponsiveFontSize(
                                                context,
                                                mobile: 14,
                                                tablet: 16,
                                                desktop: 18,
                                              ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentDetails(String studentId, Map<String, dynamic> userData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF8B5E3C),
                          child: Text(
                            userData['email']?[0]?.toUpperCase() ?? 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? 'Unknown Name',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userData['email'] ?? '',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _detailTile(
                      Icons.phone,
                      'Phone',
                      userData['phone'] ?? 'N/A',
                    ),
                    _detailTile(
                      Icons.calendar_today,
                      'Registered',
                      userData['createdAt'] != null
                          ? (userData['createdAt'] as Timestamp)
                                .toDate()
                                .toString()
                                .split(' ')[0]
                          : 'N/A',
                    ),
                    const Divider(height: 40),
                    const Text(
                      'Guardian Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E3C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('guardians')
                          .where('studentId', isEqualTo: studentId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No guardian details found');
                        }
                        final guardian =
                            snapshot.data!.docs.first.data()
                                as Map<String, dynamic>;
                        return Column(
                          children: [
                            _detailTile(
                              Icons.person,
                              'Name',
                              guardian['name'] ?? 'N/A',
                            ),
                            _detailTile(
                              Icons.family_restroom,
                              'Relation',
                              guardian['relation'] ?? 'N/A',
                            ),
                            _detailTile(
                              Icons.phone,
                              'Phone',
                              guardian['phone'] ?? 'N/A',
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Applied Courses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5E3C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('courses')
                          .where('studentIds', arrayContains: studentId)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('No courses applied yet');
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: snapshot.data!.docs.map((doc) {
                            final course = doc.data() as Map<String, dynamic>;
                            return Chip(
                              label: Text(course['title'] ?? 'Course'),
                              backgroundColor: const Color(
                                0xFF8B5E3C,
                              ).withValues(alpha: 0.1),
                              labelStyle: const TextStyle(
                                color: Color(0xFF8B5E3C),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5E3C),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close Details',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
