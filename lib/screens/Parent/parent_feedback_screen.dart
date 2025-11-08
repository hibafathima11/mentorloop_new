import 'package:flutter/material.dart';
import 'package:mentorloop/utils/colors.dart';
import 'package:mentorloop/utils/responsive.dart';
import 'package:mentorloop/utils/data_service.dart';
import 'package:mentorloop/models/entities.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParentFeedbackScreen extends StatefulWidget {
  final String studentId;
  final String teacherId;
  const ParentFeedbackScreen({
    super.key,
    required this.studentId,
    required this.teacherId,
  });

  @override
  State<ParentFeedbackScreen> createState() => _ParentFeedbackScreenState();
}

class _ParentFeedbackScreenState extends State<ParentFeedbackScreen> {
  final TextEditingController _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_message.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');
      await DataService.sendParentFeedback(
        ParentFeedback(
          id: '',
          parentId: user.uid,
          studentId: widget.studentId,
          teacherId: widget.teacherId,
          message: _message.text.trim(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Feedback sent')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Send Feedback',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Column(
            children: [
              TextField(
                controller: _message,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Write your feedback...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getResponsiveButtonHeight(context),
                child: ElevatedButton(
                  onPressed: _sending ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    foregroundColor: Colors.white,
                  ),
                  child: _sending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
