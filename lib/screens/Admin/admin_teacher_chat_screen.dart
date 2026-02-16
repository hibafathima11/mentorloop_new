import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Timestamp;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';

class AdminTeacherChatScreen extends StatefulWidget {
  const AdminTeacherChatScreen({super.key});

  @override
  State<AdminTeacherChatScreen> createState() => _AdminTeacherChatScreenState();
}

class _AdminTeacherChatScreenState extends State<AdminTeacherChatScreen> {
  final String? _currentAdminId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (_currentAdminId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat with Teachers')),
        body: const Center(child: Text('Please log in as admin')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      appBar: AppBar(
        title: const Text(
          'Chat with Teachers',
          style: TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: DataService.streamTeachers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final teachers = snapshot.data ?? [];

          if (teachers.isEmpty) {
            return const Center(child: Text('No teachers found'));
          }

          return ListView.builder(
            padding: ResponsiveHelper.getResponsivePaddingAll(context),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                margin: EdgeInsets.only(
                  bottom: ResponsiveHelper.getResponsiveMargin(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getResponsiveCardRadius(context),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: ResponsiveHelper.getResponsiveIconSize(context) / 2,
                    backgroundColor: const Color(0xFF8B5E3C),
                    child: Text(
                      teacher.name.isNotEmpty
                          ? teacher.name[0].toUpperCase()
                          : 'T',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    teacher.name,
                    style: TextStyle(
                      color: const Color(0xFF8B5E3C),
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 16,
                        tablet: 18,
                        desktop: 20,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    teacher.email,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xFF8B5E3C),
                    size: ResponsiveHelper.getResponsiveIconSize(context),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminChatRoomScreen(
                          teacherId: teacher.uid,
                          teacherName: teacher.name,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminChatRoomScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const AdminChatRoomScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
  });

  @override
  State<AdminChatRoomScreen> createState() => _AdminChatRoomScreenState();
}

class _AdminChatRoomScreenState extends State<AdminChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _threadId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeThread();
  }

  Future<void> _initializeThread() async {
    final adminId = FirebaseAuth.instance.currentUser?.uid;
    if (adminId == null) return;

    try {
      final threadId = await DataService.createOrGetOneToOneThread(
        userA: adminId,
        userB: widget.teacherId,
        title: 'Admin - ${widget.teacherName}',
      );

      if (mounted) {
        setState(() {
          _threadId = threadId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error initializing chat: $e')));
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _threadId == null) return;

    final adminId = FirebaseAuth.instance.currentUser?.uid;
    if (adminId == null) return;

    try {
      await DataService.sendChatMessage(
        threadId: _threadId!,
        senderId: adminId,
        text: text,
      );

      _messageController.clear();

      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.teacherName.isNotEmpty
                    ? widget.teacherName[0].toUpperCase()
                    : 'T',
                style: const TextStyle(
                  color: Color(0xFF8B5E3C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.teacherName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: _threadId != null
                        ? DataService.watchThreadMessages(_threadId!)
                        : Stream.value([]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final messages = snapshot.data ?? [];

                      if (messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start the conversation!',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Sort messages by timestamp
                      final sortedMessages = List<ChatMessage>.from(messages);
                      sortedMessages.sort((a, b) {
                        if (a.createdAt == null && b.createdAt == null)
                          return 0;
                        if (a.createdAt == null) return 1;
                        if (b.createdAt == null) return -1;

                        try {
                          final aTime =
                              (a.createdAt as Timestamp).millisecondsSinceEpoch;
                          final bTime =
                              (b.createdAt as Timestamp).millisecondsSinceEpoch;
                          return aTime.compareTo(bTime);
                        } catch (e) {
                          return 0;
                        }
                      });

                      // Auto-scroll to bottom when new messages arrive
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_scrollController.hasClients) {
                          _scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent,
                          );
                        }
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: ResponsiveHelper.getResponsivePaddingAll(
                          context,
                        ),
                        itemCount: sortedMessages.length,
                        itemBuilder: (context, index) {
                          final msg = sortedMessages[index];
                          final isMe = msg.senderId == adminId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                vertical: ResponsiveHelper.getResponsiveMargin(
                                  context,
                                  mobile: 4,
                                  tablet: 6,
                                  desktop: 8,
                                ),
                              ),
                              padding:
                                  ResponsiveHelper.getResponsivePaddingSymmetric(
                                    context,
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    ResponsiveHelper.screenWidth(context) *
                                    0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF8B5E3C)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(
                                  ResponsiveHelper.getResponsiveCardRadius(
                                    context,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : const Color(0xFF8B5E3C),
                                      fontSize:
                                          ResponsiveHelper.getResponsiveFontSize(
                                            context,
                                            mobile: 14,
                                            tablet: 16,
                                            desktop: 18,
                                          ),
                                    ),
                                  ),
                                  if (msg.createdAt != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        _formatTimestamp(msg.createdAt),
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.grey[600],
                                          fontSize: 10,
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
                ),
                Container(
                  padding: ResponsiveHelper.getResponsivePaddingSymmetric(
                    context,
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ResponsiveHelper.getResponsiveCardRadius(
                                  context,
                                ),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                ResponsiveHelper.getResponsivePaddingSymmetric(
                                  context,
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                          ),
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SizedBox(
                        width: ResponsiveHelper.getResponsiveMargin(
                          context,
                          mobile: 8,
                          tablet: 12,
                          desktop: 16,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: const Color(0xFF8B5E3C),
                          size: ResponsiveHelper.getResponsiveIconSize(context),
                        ),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      final DateTime dateTime = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        // Today - show time only
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
