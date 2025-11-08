import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorloop_new/screens/Common/doubt_thread_screen.dart';

class DoubtsScreen extends StatefulWidget {
  final String courseId;
  const DoubtsScreen({super.key, required this.courseId});

  @override
  State<DoubtsScreen> createState() => _DoubtsScreenState();
}

class _DoubtsScreenState extends State<DoubtsScreen> {
  final TextEditingController _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _createThread() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final t = DoubtThread(
      id: '',
      courseId: widget.courseId,
      createdBy: user.uid,
      title: _title.text.trim(),
    );
    await DataService.createDoubtThread(t);
    _title.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('Doubts', style: TextStyle(color: Color(0xFF8B5E3C))),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: ResponsiveHelper.getResponsivePaddingAll(context),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _title,
                      decoration: const InputDecoration(
                        hintText: 'Start a new thread...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _createThread,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Post'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<DoubtThread>>(
                stream: DataService.watchCourseDoubts(widget.courseId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final threads = snapshot.data!;
                  if (threads.isEmpty)
                    return const Center(child: Text('No threads yet'));
                  return ListView.separated(
                    padding: ResponsiveHelper.getResponsivePaddingAll(context),
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final t = threads[i];
                      return ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(t.title),
                        subtitle: Text('by ${t.createdBy}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoubtThreadScreen(thread: t),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
