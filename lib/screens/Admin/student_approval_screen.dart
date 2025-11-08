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

                      return Container(
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Student approved successfully',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: Colors.red,
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
                                      side: const BorderSide(color: Colors.red),
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
}
