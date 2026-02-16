import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/screens/Teacher/teacher_chat_room_screen.dart';

class TeacherChatListScreen extends StatefulWidget {
  const TeacherChatListScreen({super.key});

  @override
  State<TeacherChatListScreen> createState() => _TeacherChatListScreenState();
}

class _TeacherChatListScreenState extends State<TeacherChatListScreen> {
  late Future<List<Map<String, dynamic>>> _studentsFuture;
  late Future<Map<String, dynamic>?> _adminFuture;

  @override
  void initState() {
    super.initState();
    final teacherId = FirebaseAuth.instance.currentUser?.uid;
    if (teacherId != null) {
      _studentsFuture = _fetchStudentsForTeacher(teacherId);
      _adminFuture = _fetchAdmin();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchStudentsForTeacher(
    String teacherId,
  ) async {
    final coursesSnap = await FirebaseFirestore.instance
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .get();

    final studentIds = <String>{};
    for (var course in coursesSnap.docs) {
      final ids = List<String>.from(course['studentIds'] ?? []);
      studentIds.addAll(ids);
    }

    if (studentIds.isEmpty) return [];

    final idList = studentIds.toList();
    final List<Map<String, dynamic>> allStudents = [];

    // Firestore whereIn limit is 10. Chunk the ids.
    for (var i = 0; i < idList.length; i += 10) {
      final chunk = idList.sublist(
        i,
        i + 10 > idList.length ? idList.length : i + 10,
      );
      final studentsSnap = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      allStudents.addAll(
        studentsSnap.docs.map((d) => {...d.data(), 'uid': d.id}),
      );
    }

    return allStudents;
  }

  Future<Map<String, dynamic>?> _fetchAdmin() async {
    final adminSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();

    if (adminSnap.docs.isEmpty) return null;
    return {...adminSnap.docs.first.data(), 'uid': adminSnap.docs.first.id};
  }

  @override
  Widget build(BuildContext context) {
    final teacherId = FirebaseAuth.instance.currentUser?.uid;

    if (teacherId == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(
            color: Color(0xFF8B5E3C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _studentsFuture,
        builder: (context, studentSnap) {
          if (studentSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (studentSnap.hasError) {
            return Center(
              child: Text('Failed to load students: ${studentSnap.error}'),
            );
          }

          return FutureBuilder<Map<String, dynamic>?>(
            future: _adminFuture,
            builder: (context, adminSnap) {
              if (adminSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (adminSnap.hasError) {
                return const Center(child: Text('Failed to load admin'));
              }

              final students = studentSnap.data ?? [];
              final admin = adminSnap.data;

              final chatList = [
                if (admin != null)
                  {
                    'uid': admin['uid'],
                    'name': admin['name'] ?? 'Admin',
                    'email': admin['email'] ?? '',
                    'photoUrl': admin['photoUrl'] ?? '',
                    'role': 'admin',
                  },
                ...students,
              ];

              if (chatList.isEmpty) {
                return const Center(child: Text('No students or admin found'));
              }

              return ListView.builder(
                padding: ResponsiveHelper.getResponsivePaddingAll(context),
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  final user = chatList[index];

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
                        radius:
                            ResponsiveHelper.getResponsiveIconSize(context) / 2,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            user['photoUrl'] != null &&
                                (user['photoUrl'] as String).isNotEmpty
                            ? NetworkImage(user['photoUrl'])
                            : null,
                        child:
                            (user['photoUrl'] == null ||
                                (user['photoUrl'] as String).isEmpty)
                            ? Icon(
                                user['role'] == 'admin'
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                color: const Color(0xFF8B5E3C),
                                size: ResponsiveHelper.getResponsiveIconSize(
                                  context,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        user['name'] ?? user['email'] ?? '',
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
                        user['email'] ?? '',
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
                            builder: (_) => TeacherChatRoomScreen(
                              otherUserId: user['uid'],
                              otherUserName:
                                  user['name'] ?? user['email'] ?? '',
                              otherUserPhoto: user['photoUrl'] ?? '',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

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
  final _messageController = TextEditingController();
  final teacherId = FirebaseAuth.instance.currentUser?.uid ?? 'teacher';

  String get chatThreadId => teacherId.compareTo(widget.otherUserId) < 0
      ? '${teacherId}_${widget.otherUserId}'
      : '${widget.otherUserId}_$teacherId';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('chatThreads')
        .doc(chatThreadId)
        .collection('messages')
        .add({
          'senderId': teacherId,
          'receiverId': widget.otherUserId,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
        });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B5E3C),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: widget.otherUserPhoto.isNotEmpty
                  ? NetworkImage(widget.otherUserPhoto)
                  : null,
              child: widget.otherUserPhoto.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF8B5E3C))
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              widget.otherUserName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chatThreads')
                  .doc(chatThreadId)
                  .collection('messages')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final dynamic qs = snapshot.data;
                final List messages = qs?.docs ?? const [];
                // Sort messages by timestamp in client-side
                messages.sort((a, b) {
                  final aMap = a.data() as Map<String, dynamic>;
                  final bMap = b.data() as Map<String, dynamic>;

                  final aTs = aMap['timestamp'];
                  final bTs = bMap['timestamp'];

                  // Handle missing timestamps safely
                  if (aTs == null && bTs == null) return 0;
                  if (aTs == null) return 1;
                  if (bTs == null) return -1;

                  final aTime = (aTs as Timestamp).millisecondsSinceEpoch;
                  final bTime = (bTs as Timestamp).millisecondsSinceEpoch;

                  return aTime.compareTo(bTime);
                });

                return ListView.builder(
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final dynamic msgDoc = messages[index];
                    final Map<String, dynamic> msg =
                        (msgDoc.data() as Map<String, dynamic>?) ??
                        <String, dynamic>{};
                    final isMe = msg['senderId'] == teacherId;
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
                        padding: ResponsiveHelper.getResponsivePaddingSymmetric(
                          context,
                          horizontal: 16,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth:
                              ResponsiveHelper.screenWidth(context) * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF8B5E3C) : Colors.white,
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveCardRadius(context),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : const Color(0xFF8B5E3C),
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
                          ResponsiveHelper.getResponsiveCardRadius(context),
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
}
