import 'package:flutter/material.dart';
import 'package:mentorloop/screens/Common/chat_threads_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatThreadsScreen(role: 'student');
  }
}
