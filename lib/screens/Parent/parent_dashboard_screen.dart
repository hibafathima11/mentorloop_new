import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop/screens/Parent/child_progress_screen.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  Map<String, dynamic>? _studentData;
  String? _studentId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLinkedStudent();
  }

  Future<void> _loadLinkedStudent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final studentData = await getLinkedStudentForParent(user.email ?? '');
    // Get studentId from parent's user data
    final guardianSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();
    
    String? studentId;
    if (guardianSnap.docs.isNotEmpty) {
      final guardianData = guardianSnap.docs.first.data();
      studentId = guardianData['studentId'] as String?;
    }
    
    setState(() {
      _studentData = studentData;
      _studentId = studentId;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      appBar: AppBar(
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _studentData == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange[700],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No linked student found for your email.",
                      style: TextStyle(
                        color: Color(0xFF8B5E3C),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Please contact your child's school to update guardian details.",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5E3C),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Linked Student",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    _studentData?['photoUrl'] != null &&
                                        (_studentData?['photoUrl'] as String)
                                            .isNotEmpty
                                    ? NetworkImage(_studentData!['photoUrl'])
                                    : null,
                                child:
                                    (_studentData?['photoUrl'] == null ||
                                        (_studentData?['photoUrl'] as String)
                                            .isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        color: Color(0xFF8B5E3C),
                                        size: 32,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _studentData?['name'] ?? '-',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _studentData?['email'] ?? '-',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _studentData?['phone'] ?? '-',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Student Details",
                              style: TextStyle(
                                color: Color(0xFF8B5E3C),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _infoRow("Name", _studentData?['name']),
                            _infoRow("Email", _studentData?['email']),
                            _infoRow("Phone", _studentData?['phone']),
                            _infoRow("Role", _studentData?['role']),
                            // Add more fields if needed
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildProgressCard(context),
                    _buildFeedbackCard(context),
                    // You can add more cards for analytics, attendance, feedback, etc.
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    if (_studentId == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: ListTile(
        tileColor: const Color(0xFFE3F2FD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(Icons.trending_up, color: Color(0xFF8B5E3C), size: 36),
        title: const Text(
          'View Progress',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
            fontSize: 18,
          ),
        ),
        subtitle: const Text(
          'View attendance and performance',
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
            if (_studentId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChildProgressScreen(studentId: _studentId!),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              color: Color(0xFF8B5E3C),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context) {
    final _feedbackController = TextEditingController();
    bool _isSubmitting = false;

    void _showFeedbackDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Submit Feedback'),
                content: TextField(
                  controller: _feedbackController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Your feedback about app, teaching, etc.',
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
                                _feedbackController.text.trim().isEmpty)
                              return;
                            await FirebaseFirestore.instance
                                .collection('parent_feedback')
                                .add({
                                  'parentId': user.uid,
                                  'parentEmail': user.email,
                                  'feedback': _feedbackController.text.trim(),
                                  'createdAt': DateTime.now(),
                                });
                            setState(() => _isSubmitting = false);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feedback submitted'),
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
      margin: const EdgeInsets.only(top: 18),
      child: ListTile(
        tileColor: const Color(0xFFFFF3E0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: const Icon(Icons.feedback, color: Color(0xFF8B5E3C), size: 36),
        title: const Text(
          'Submit Feedback',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
            fontSize: 18,
          ),
        ),
        subtitle: const Text(
          'Share your feedback about app or teaching',
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
          child: const Text('Add'),
          onPressed: _showFeedbackDialog,
        ),
      ),
    );
  }
}

// Logic to fetch linked student for parent
Future<Map<String, dynamic>?> getLinkedStudentForParent(
  String parentEmail,
) async {
  final guardianSnap = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: parentEmail)
      .get();

  if (guardianSnap.docs.isEmpty) return null;

  final guardianData = guardianSnap.docs.first.data();
  final studentId = guardianData['studentId'];

  final studentSnap = await FirebaseFirestore.instance
      .collection('users')
      .doc(studentId)
      .get();

  if (!studentSnap.exists) return null;

  final studentData = studentSnap.data();
  return studentData;
}
