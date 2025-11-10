import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class ChatThreadsScreen extends StatelessWidget {
  final String role; // 'admin' or 'teacher'
  const ChatThreadsScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(color: Color(0xFF8B5E3C))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: uid == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<List<ChatThread>>(
              stream: DataService.watchMyThreads(uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final threads = snapshot.data!;
                if (threads.isEmpty) {
                  return Center(
                    child: Text(
                      'No conversations yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }
                // Sort threads by lastMessageAt in client-side
                threads.sort((a, b) {
                  if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
                  if (a.lastMessageAt == null) return 1;
                  if (b.lastMessageAt == null) return -1;
                  return (b.lastMessageAt as firestore.Timestamp).millisecondsSinceEpoch
                      .compareTo((a.lastMessageAt as firestore.Timestamp).millisecondsSinceEpoch);
                });
                return ListView.separated(
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
                  itemCount: threads.length,
                  separatorBuilder: (_, __) => SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 8,
                      tablet: 12,
                      desktop: 16,
                    ),
                  ),
                  itemBuilder: (context, i) {
                    final t = threads[i];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveHelper.getResponsiveCardRadius(context),
                        ),
                      ),
                      tileColor: Colors.white,
                      title: Text(
                        t.title.isNotEmpty ? t.title : 'Conversation',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 16,
                            tablet: 18,
                            desktop: 20,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        'Tap to open',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 14,
                            tablet: 16,
                            desktop: 18,
                          ),
                        ),
                      ),
                      trailing: _UnreadBadge(threadId: t.id),
                      onTap: () async {
                        final me = FirebaseAuth.instance.currentUser?.uid;
                        if (me != null) {
                          await DataService.markThreadRead(
                            threadId: t.id,
                            uid: me,
                          );
                        }
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatThreadScreen(thread: t),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: role == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
                // Admin can start chat with a teacher
                final selected = await showModalBottomSheet<UserProfile>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return SafeArea(
                      child: Padding(
                        padding: ResponsiveHelper.getResponsivePaddingAll(
                          context,
                        ),
                        child: SizedBox(
                          height: 420,
                          child: StreamBuilder<List<UserProfile>>(
                            stream: DataService.streamTeachers(),
                            builder: (context, snapshot) {
                              final teachers =
                                  snapshot.data ?? const <UserProfile>[];
                              return ListView.separated(
                                itemCount: teachers.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, i) {
                                  final t = teachers[i];
                                  return ListTile(
                                    title: Text(
                                      t.name.isNotEmpty ? t.name : t.email,
                                    ),
                                    subtitle: Text(t.uid),
                                    onTap: () => Navigator.pop(context, t),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
                if (selected != null) {
                  final me = FirebaseAuth.instance.currentUser?.uid;
                  if (me == null) return;
                  final threadId = await DataService.createOrGetOneToOneThread(
                    userA: me,
                    userB: selected.uid,
                    title: selected.name.isNotEmpty
                        ? selected.name
                        : selected.email,
                  );
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatThreadScreen(
                          thread: ChatThread(
                            id: threadId,
                            memberIds: [me, selected.uid],
                            title: selected.name.isNotEmpty
                                ? selected.name
                                : selected.email,
                            lastMessageAt: null,
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class ChatThreadScreen extends StatefulWidget {
  final ChatThread thread;
  const ChatThreadScreen({super.key, required this.thread});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (me == null) return;
    await DataService.sendChatMessage(
      threadId: widget.thread.id,
      senderId: me,
      text: text,
    );
    _message.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: widget.thread.title.isNotEmpty
            ? Text(
                widget.thread.title,
                style: const TextStyle(color: Color(0xFF8B5E3C)),
              )
            : Builder(
                builder: (context) {
                  final me = FirebaseAuth.instance.currentUser?.uid;
                  String? otherId;
                  if (me != null) {
                    for (final id in widget.thread.memberIds) {
                      if (id != me) {
                        otherId = id;
                        break;
                      }
                    }
                  }
                  if (otherId == null) {
                    return const Text('Chat', style: TextStyle(color: Color(0xFF8B5E3C)));
                  }
                  return StreamBuilder<firestore.DocumentSnapshot<Map<String, dynamic>>>(
                    stream: firestore.FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherId)
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Text('Chat', style: TextStyle(color: Color(0xFF8B5E3C)));
                      }
                      final data = snap.data?.data() ?? <String, dynamic>{};
                      final name = (data['name'] as String?)?.trim() ?? '';
                      final email = (data['email'] as String?)?.trim() ?? '';
                      final title = name.isNotEmpty ? name : (email.isNotEmpty ? email : 'Chat');
                      return Text(title, style: const TextStyle(color: Color(0xFF8B5E3C)));
                    },
                  );
                },
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: DataService.watchThreadMessages(widget.thread.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final msgs = snapshot.data!;
                // Sort messages by createdAt in client-side
                msgs.sort((a, b) {
                  if (a.createdAt == null && b.createdAt == null) return 0;
                  if (a.createdAt == null) return 1;
                  if (b.createdAt == null) return -1;
                  return (a.createdAt as firestore.Timestamp).millisecondsSinceEpoch
                      .compareTo((b.createdAt as firestore.Timestamp).millisecondsSinceEpoch);
                });
                final me = FirebaseAuth.instance.currentUser?.uid;
                return ListView.builder(
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    final mine = m.senderId == me;
                    return Align(
                      alignment: mine
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
                        padding: ResponsiveHelper.getResponsivePaddingSymmetric(
                          context,
                          horizontal: 12,
                          vertical: 8,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: ResponsiveHelper.screenWidth(context) * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: mine ? const Color(0xFF8B5E3C) : Colors.white,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveCardRadius(context),
                          ),
                          boxShadow: mine
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            color: mine ? Colors.white : AppColors.textPrimary,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 14,
                              tablet: 16,
                              desktop: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: ResponsiveHelper.getResponsivePaddingSymmetric(
                context,
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _message,
                      decoration: const InputDecoration(hintText: 'Message'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final String threadId;
  const _UnreadBadge({required this.threadId});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    return StreamBuilder<int>(
      stream: DataService.watchUnreadCountForThread(
        threadId: threadId,
        uid: uid,
      ),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        if (count <= 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE53935),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
      },
    );
  }
}
