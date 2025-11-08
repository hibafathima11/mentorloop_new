import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherParentFeedbackScreen extends StatelessWidget {
  const TeacherParentFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Parent Feedback',
            style: TextStyle(color: Color(0xFF8B5E3C)),
          ),
        ),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Parent Feedback',
          style: TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<ParentFeedback>>(
        stream: DataService.watchParentFeedbackForTeacher(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final feedbacks = snapshot.data!;
          if (feedbacks.isEmpty) {
            return const Center(
              child: Text(
                'No feedback received yet.',
                style: TextStyle(color: Color(0xFF8B5E3C), fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            padding: ResponsiveHelper.getResponsivePaddingAll(context),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final feedback = feedbacks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.feedback, color: Color(0xFF8B5E3C)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Feedback from Parent',
                              style: TextStyle(
                                color: const Color(0xFF8B5E3C),
                                fontSize: ResponsiveHelper.getResponsiveFontSize(
                                  context,
                                  mobile: 16,
                                  tablet: 18,
                                  desktop: 20,
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feedback.message,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (feedback.createdAt != null)
                        Text(
                          'Date: ${feedback.createdAt.toString()}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
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
              );
            },
          );
        },
      ),
    );
  }
}

