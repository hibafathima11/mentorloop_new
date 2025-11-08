import 'package:flutter/material.dart';
// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/utils/responsive.dart';

class AdminTeacherChatScreen extends StatelessWidget {
  const AdminTeacherChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final dynamic qs = snapshot.data;
          final List allUsers = qs?.docs ?? const [];
          final teachers = allUsers
              .where((doc) => (doc.data() as Map<String, dynamic>)['role'] == 'teacher')
              .toList();
          return ListView.builder(
            padding: ResponsiveHelper.getResponsivePaddingAll(context),
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index].data() as Map<String, dynamic>;
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
                    backgroundColor: Colors.white,
                    backgroundImage:
                        teacher['photoUrl'] != null &&
                            (teacher['photoUrl'] as String).isNotEmpty
                        ? NetworkImage(teacher['photoUrl'])
                        : null,
                    child:
                        (teacher['photoUrl'] == null ||
                            (teacher['photoUrl'] as String).isEmpty)
                        ? Icon(
                            Icons.person,
                            color: const Color(0xFF8B5E3C),
                            size: ResponsiveHelper.getResponsiveIconSize(context),
                          )
                        : null,
                  ),
                  title: Text(
                    teacher['name'] ?? teacher['email'] ?? 'Teacher',
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
                    teacher['email'] ?? '',
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
                          teacherId: (teachers[index] as dynamic).id,
                          teacherName:
                              teacher['name'] ?? teacher['email'] ?? 'Teacher',
                          teacherPhoto: teacher['photoUrl'] ?? '',
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
  final String teacherPhoto;
  const AdminChatRoomScreen({
    super.key,
    required this.teacherId,
    required this.teacherName,
    required this.teacherPhoto,
  });

  @override
  State<AdminChatRoomScreen> createState() => _AdminChatRoomScreenState();
}

class _AdminChatRoomScreenState extends State<AdminChatRoomScreen> {
  final _messageController = TextEditingController();
  final adminId = FirebaseAuth.instance.currentUser?.uid ?? 'admin';

  String get chatThreadId => adminId.compareTo(widget.teacherId) < 0
      ? '${adminId}_${widget.teacherId}'
      : '${widget.teacherId}_$adminId';

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
          'senderId': adminId,
          'receiverId': widget.teacherId,
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
              backgroundImage: widget.teacherPhoto.isNotEmpty
                  ? NetworkImage(widget.teacherPhoto)
                  : null,
              child: widget.teacherPhoto.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF8B5E3C))
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              widget.teacherName,
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
                final dynamic qs2 = snapshot.data;
                final List messages = qs2?.docs ?? const [];
                // Sort messages by timestamp in client-side
                messages.sort((a, b) {
                  final aData = (a.data() as Map<String, dynamic>?)?['timestamp'];
                  final bData = (b.data() as Map<String, dynamic>?)?['timestamp'];
                  if (aData == null && bData == null) return 0;
                  if (aData == null) return 1;
                  if (bData == null) return -1;
                  return (aData as firestore.Timestamp).millisecondsSinceEpoch
                      .compareTo((bData as firestore.Timestamp).millisecondsSinceEpoch);
                });
                return ListView.builder(
                  padding: ResponsiveHelper.getResponsivePaddingAll(context),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final dynamic msgDoc = messages[index];
                    final Map<String, dynamic> msg =
                        (msgDoc.data() as Map<String, dynamic>?) ??
                        <String, dynamic>{};
                    final isMe = msg['senderId'] == adminId;
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
                          maxWidth: ResponsiveHelper.screenWidth(context) * 0.75,
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
                      contentPadding: ResponsiveHelper.getResponsivePaddingSymmetric(
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
