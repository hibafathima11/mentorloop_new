import 'package:flutter/material.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherChatRoomScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String otherUserPhoto;

  const TeacherChatRoomScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserPhoto,
  });

  @override
  State<TeacherChatRoomScreen> createState() => _TeacherChatRoomScreenState();
}

class _TeacherChatRoomScreenState extends State<TeacherChatRoomScreen> {
  final TextEditingController _message = TextEditingController();
  String? _threadId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeThread();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _initializeThread() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final threadId = await DataService.createOrGetOneToOneThread(
        userA: user.uid,
        userB: widget.otherUserId,
        title: 'Chat with ${widget.otherUserName}',
      );
      setState(() {
        _threadId = threadId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing chat: $e')),
        );
      }
    }
  }

  Future<void> _send() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _message.text.trim().isEmpty || _threadId == null) return;

    try {
      await DataService.sendChatMessage(
        threadId: _threadId!,
        senderId: user.uid,
        text: _message.text.trim(),
      );
      _message.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_threadId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(child: Text('Failed to initialize chat')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(
          widget.otherUserName,
          style: const TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: DataService.watchThreadMessages(_threadId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading messages: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  final items = snapshot.data ?? const <ChatMessage>[];
                  return ListView.separated(
                    padding: ResponsiveHelper.getResponsivePaddingAll(context),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final m = items[i];
                      final isMe = m.senderId == FirebaseAuth.instance.currentUser?.uid;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? const Color(0xFF8B5E3C) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            m.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
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
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: Color(0xFF8B5E3C)),
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