import 'package:flutter/material.dart';
// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop_new/utils/colors.dart';

class AdminParentFeedbackScreen extends StatelessWidget {
  const AdminParentFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('parent_feedback')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final dynamic qs = snapshot.data;
          final List feedbacks = qs?.docs ?? const [];
          if (feedbacks.isEmpty) {
            return const Center(
              child: Text(
                'No feedback submitted.',
                style: TextStyle(color: Color(0xFF8B5E3C), fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final dynamic doc = feedbacks[index];
              final Map<String, dynamic> data =
                  (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
              final reactions = data['reactions'] ?? {};
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.feedback, color: Color(0xFF8B5E3C)),
                  title: Text(
                    data['feedback'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFF8B5E3C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parent Email: ${data['parentEmail'] ?? '-'}'),
                      Text(
                        'Date: ${data['createdAt'] != null ? data['createdAt'].toString() : '-'}',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _emojiReactionButton(doc.id, reactions, '👍'),
                          _emojiReactionButton(doc.id, reactions, '❤️'),
                          _emojiReactionButton(doc.id, reactions, '😂'),
                          _emojiReactionButton(doc.id, reactions, '😮'),
                          _emojiReactionButton(doc.id, reactions, '🙏'),
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

  Widget _emojiReactionButton(String docId, Map reactions, String emoji) {
    final count = reactions[emoji] ?? 0;
    return GestureDetector(
      onTap: () async {
        final ref = FirebaseFirestore.instance
            .collection('parent_feedback')
            .doc(docId);
        await ref.update({'reactions.$emoji': FieldValue.increment(1)});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Chip(
          label: Text('$emoji $count'),
          backgroundColor: Colors.grey[100],
        ),
      ),
    );
  }
}
