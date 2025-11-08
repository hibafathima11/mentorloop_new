import 'package:flutter/material.dart';
// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop_new/utils/colors.dart';

class AdminComplaintsScreen extends StatelessWidget {
  const AdminComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Student Complaints',
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
            .collection('complaints')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final dynamic qs = snapshot.data;
          final List complaints = qs?.docs ?? const [];
          if (complaints.isEmpty) {
            return const Center(
              child: Text(
                'No complaints submitted.',
                style: TextStyle(color: Color(0xFF8B5E3C), fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final dynamic doc = complaints[index];
              final Map<String, dynamic> data =
                  (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.report_problem,
                    color: Color(0xFFD32F2F),
                  ),
                  title: Text(
                    data['complaint'] ?? '',
                    style: const TextStyle(
                      color: Color(0xFF8B5E3C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Student Email: ${data['studentEmail'] ?? '-'}'),
                      Text(
                        'Date: ${data['createdAt'] != null ? data['createdAt'].toString() : '-'}',
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
