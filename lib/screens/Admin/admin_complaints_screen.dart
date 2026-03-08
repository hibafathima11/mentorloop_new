import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mentorloop_new/utils/colors.dart';

class AdminComplaintsScreen extends StatelessWidget {
  const AdminComplaintsScreen({super.key});

  static String _formatDate(dynamic createdAt) {
    if (createdAt == null) return '-';
    if (createdAt is Timestamp) {
      return DateFormat('dd/MM/yyyy h:mma').format(createdAt.toDate());
    }
    return createdAt.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: kIsWeb
          ? null
          : AppBar(
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final complaints = snapshot.data!.docs;
          if (complaints.isEmpty) {
            return const Center(
              child: Text(
                'No complaints submitted.',
                style: TextStyle(color: Color(0xFF8B5E3C), fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final doc = complaints[index];
              final data =
                  (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
              final createdAt = data['createdAt'];
              final hasReply =
                  data['reply'] != null &&
                  (data['reply'] as String?).toString().trim().isNotEmpty;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  onTap: () => _openComplaintDetail(context, doc.id, data),
                  leading: Icon(
                    hasReply ? Icons.check_circle : Icons.report_problem,
                    color: hasReply ? Colors.green : const Color(0xFFD32F2F),
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
                      const SizedBox(height: 4),
                      Text(
                        'Student Email: ${data['studentEmail'] ?? '-'}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Date: ${_formatDate(createdAt)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (hasReply) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Replied',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF8B5E3C),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openComplaintDetail(
    BuildContext context,
    String complaintId,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ComplaintDetailSheet(
        complaintId: complaintId,
        data: data,
        onReplySent: () => Navigator.pop(context),
      ),
    );
  }
}

class _ComplaintDetailSheet extends StatefulWidget {
  const _ComplaintDetailSheet({
    required this.complaintId,
    required this.data,
    required this.onReplySent,
  });

  final String complaintId;
  final Map<String, dynamic> data;
  final VoidCallback onReplySent;

  @override
  State<_ComplaintDetailSheet> createState() => _ComplaintDetailSheetState();
}

class _ComplaintDetailSheetState extends State<_ComplaintDetailSheet> {
  final _replyController = TextEditingController(text: null);
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.data['reply'] as String?;
    if (existing != null && existing.trim().isNotEmpty) {
      _replyController.text = existing;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  static String _formatDate(dynamic createdAt) {
    if (createdAt == null) return '-';
    if (createdAt is Timestamp) {
      return DateFormat('dd/MM/yyyy h:mma').format(createdAt.toDate());
    }
    return createdAt.toString();
  }

  Future<void> _sendReply() async {
    final reply = _replyController.text.trim();
    if (reply.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.complaintId)
          .update({'reply': reply, 'repliedAt': FieldValue.serverTimestamp()});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reply sent')));
        widget.onReplySent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send reply: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final hasReply =
        data['reply'] != null &&
        (data['reply'] as String?).toString().trim().isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Complaint Details',
              style: TextStyle(
                color: const Color(0xFF8B5E3C),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Complaint'),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data['complaint'] ?? '-',
                      style: const TextStyle(fontSize: 15, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _label('Student Email'),
                  Text(
                    data['studentEmail'] ?? '-',
                    style: TextStyle(color: Colors.grey[800], fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  _label('Date'),
                  Text(
                    _formatDate(data['createdAt']),
                    style: TextStyle(color: Colors.grey[800], fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    'Admin Reply',
                    style: TextStyle(
                      color: const Color(0xFF8B5E3C),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (hasReply) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5E3C).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (data['reply'] as String?) ?? '',
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Replied at: ${_formatDate(data['repliedAt'])}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                  ],
                  TextField(
                    controller: _replyController,
                    maxLines: 4,
                    enabled: !_isSending,
                    decoration: InputDecoration(
                      hintText: hasReply
                          ? 'Add another reply or edit...'
                          : 'Type your reply here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF8B5E3C),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendReply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E3C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              hasReply ? 'Update Reply' : 'Send Reply',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
