import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';

class ChatScreen extends StatefulWidget {
  final String peerName;
  const ChatScreen({super.key, required this.peerName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = <_ChatMessage>[
    _ChatMessage(
      text: 'Hi there! How can I help you today?',
      isMe: false,
      time: '09:41',
    ),
    _ChatMessage(
      text: 'I finished lesson 1. What should I do next?',
      isMe: true,
      time: '09:42',
    ),
    _ChatMessage(
      text: 'Great! Move to lesson 2 and try the quiz.',
      isMe: false,
      time: '09:43',
    ),
  ];

  void _send() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: txt, isMe: true, time: 'Now'));
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryBackground,
              child: Icon(
                Icons.person,
                color: AppColors.primaryButton,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.peerName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildBubble(_messages[i]),
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildBubble(_ChatMessage m) {
    final Color bubbleColor = m.isMe
        ? AppColors.white
        : AppColors.primaryBackground;
    final Alignment align = m.isMe
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.text, style: TextStyle(color: AppColors.darkGrey)),
            const SizedBox(height: 4),
            Text(m.time, style: TextStyle(color: AppColors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
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
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(color: AppColors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send, color: AppColors.textPrimary),
              onPressed: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  _ChatMessage({required this.text, required this.isMe, required this.time});
}
