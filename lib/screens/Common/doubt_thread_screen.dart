import 'package:flutter/material.dart';
import 'package:mentorloop/models/entities.dart';
import 'package:mentorloop/utils/data_service.dart';
import 'package:mentorloop/utils/responsive.dart';
import 'package:mentorloop/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoubtThreadScreen extends StatefulWidget {
  final DoubtThread thread;
  const DoubtThreadScreen({super.key, required this.thread});

  @override
  State<DoubtThreadScreen> createState() => _DoubtThreadScreenState();
}

class _DoubtThreadScreenState extends State<DoubtThreadScreen> {
  final TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _message.text.trim().isEmpty) return;
    await DataService.addDoubtMessage(
      DoubtMessage(
        id: '',
        threadId: widget.thread.id,
        senderId: user.uid,
        text: _message.text.trim(),
      ),
    );
    _message.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(
          widget.thread.title,
          style: const TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<DoubtMessage>>(
                stream: DataService.watchDoubtMessages(widget.thread.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!;
                  return ListView.separated(
                    padding: ResponsiveHelper.getResponsivePaddingAll(context),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final m = items[i];
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text('${m.senderId}: ${m.text}'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: ResponsiveHelper.getResponsivePaddingAll(context),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _message,
                      decoration: const InputDecoration(
                        hintText: 'Type message...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
