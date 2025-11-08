import 'package:flutter/material.dart';
// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/auth_service.dart';

class AdminParentVerificationScreen extends StatelessWidget {
  const AdminParentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Verification')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('parent_verifications')
            .where('status', isEqualTo: 'pending')
           
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final dynamic qs = snapshot.data;
          final List docs = qs?.docs ?? const [];
          if (docs.isEmpty) {
            return const Center(child: Text('No pending parent verifications'));
          }
          return ListView.separated(
            padding: ResponsiveHelper.getResponsivePaddingAll(context),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final dynamic d = docs[i];
              final Map<String, dynamic> data =
                  (d.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
              final parentEmail = data['parentEmail'] as String? ?? '';
              final studentEmail = data['studentEmail'] as String? ?? '';
              final idUrl = data['idUrl'] as String? ?? '';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parent: $parentEmail'),
                      Text('Student email: $studentEmail'),
                      const SizedBox(height: 8),
                      if (idUrl.isNotEmpty)
                        InkWell(
                          onTap: () {},
                          child: Text(
                            'View ID',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await _approveParentRequest(d.id, data);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Parent approved'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Approve'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await _rejectParentRequest(d.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Request rejected'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Reject'),
                          ),
                        ],
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

  static Future<void> _approveParentRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    final db = FirebaseFirestore.instance;
    final parentId = data['parentId'] as String?;
    final studentEmail = data['studentEmail'] as String?;
    if (parentId == null || studentEmail == null) return;

    // Find student by email
    final studentSnap = await db
        .collection('users')
        .where('email', isEqualTo: studentEmail)
        .where('role', isEqualTo: 'student')
        .limit(1)
        .get();
    if (studentSnap.docs.isEmpty) {
      await db.collection('parent_verifications').doc(requestId).update({
        'status': 'rejected',
        'reason': 'student_not_found',
      });
      return;
    }
    final studentId = studentSnap.docs.first.id;

    // Link parent to student and approve parent
    await db.collection('parent_links').doc(parentId).set({
      'parentId': parentId,
      'studentId': studentId,
      'linkedAt': FieldValue.serverTimestamp(),
    });

    await db.collection('users').doc(parentId).update({'approved': true});

    await db.collection('parent_verifications').doc(requestId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> _rejectParentRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection('parent_verifications')
        .doc(requestId)
        .update({'status': 'rejected'});
  }
}
