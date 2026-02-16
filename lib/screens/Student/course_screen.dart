import 'package:flutter/material.dart';
import 'package:mentorloop_new/screens/Student/commentscreen.dart';
import 'package:mentorloop_new/screens/Student/pdf_view_screen.dart';
import 'package:mentorloop_new/screens/Student/video_player_screen.dart';
import 'package:mentorloop_new/screens/Student/course_video_screen.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/screens/Student/my_courses_screen.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseScreen extends StatefulWidget {
  final bool autofocusSearch;
  const CourseScreen({super.key, this.autofocusSearch = false});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.autofocusSearch) {
      // delay to ensure page builds before requesting focus
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocus.requestFocus();
      });
    }
  }

  bool _matchesQuery(Course c) {
    if (_query.trim().isEmpty) return true;
    final q = _query.toLowerCase();
    return c.title.toLowerCase().contains(q) ||
        c.description.toLowerCase().contains(q);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBackground,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Course',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryBackground,
              child: Icon(
                Icons.person,
                color: AppColors.primaryButton,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            _searchBar(context),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Choice your course',
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyCoursesScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'My courses',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _filters(),
            const SizedBox(height: 16),
            StreamBuilder<List<Course>>(
              stream: DataService.watchAllCourses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Error loading courses: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                final items = (snapshot.data ?? const <Course>[])
                    .where(_matchesQuery)
                    .toList();
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'No courses found',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: items
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _courseCard(
                            context,
                            title: c.title,
                            description: c.description,
                            courseId: c.id,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF9C6D4C),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              autofocus: widget.autofocusSearch,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Find Course',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                border: InputBorder.none,
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return Row(
      children: [
        _chip('All', selected: true),
        const SizedBox(width: 12),
        _chip('Popular'),
        const SizedBox(width: 12),
        _chip('New'),
      ],
    );
  }

  Widget _chip(String label, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF9C6D4C) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.darkGrey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _courseCard(
    BuildContext context, {
    required String title,
    required String description,
    required String courseId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.darkGrey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(color: AppColors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Show course materials
          StreamBuilder<List<StudyMaterial>>(
            stream: DataService.watchCourseMaterials(courseId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final materials = snapshot.data!;
              if (materials.isEmpty) {
                return const Text('No materials uploaded for this course');
              }
              return Column(
                children: materials.map((m) {
                  return ListTile(
                    title: Text(m.title),
                    subtitle: Text(m.type.toUpperCase()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (m.type == 'video') {
                              // Assign student to course if not already assigned
                              if (user != null) {
                                await DataService.assignStudentToCourse(
                                  courseId,
                                  user.uid,
                                );
                              }
                              // Try to find CourseVideo by URL to get videoId for questions
                              try {
                                final courseVideos =
                                    await DataService.watchCourseVideos(
                                      courseId,
                                    ).first;
                                CourseVideo? matchingVideo;
                                try {
                                  matchingVideo = courseVideos.firstWhere(
                                    (v) => v.url == m.url,
                                  );
                                } catch (e) {
                                  // No matching video found by URL
                                  if (courseVideos.isNotEmpty) {
                                    // Use first video as fallback
                                    matchingVideo = courseVideos.first;
                                  }
                                }

                                if (matchingVideo != null) {
                                  // Use CourseVideoScreen with questions support
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CourseVideoScreen(
                                        videoId: matchingVideo!.id,
                                        videoUrl: matchingVideo.url,
                                        durationSeconds:
                                            matchingVideo.durationSeconds,
                                        title: matchingVideo.title,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Fallback to simple video player if no CourseVideo found
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VideoPlayerScreen(url: m.url),
                                    ),
                                  );
                                }
                              } catch (e) {
                                // Fallback to simple video player on error
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VideoPlayerScreen(url: m.url),
                                  ),
                                );
                              }
                            } else if (m.type == 'pdf') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewScreen(url: m.url),
                                ),
                              );
                            } else if (m.type == 'link') {
                              launchUrl(Uri.parse(m.url));
                            }
                          },
                          child: const Text('View'),
                        ),
                        if (m.type == 'pdf')
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () {
                              // Download PDF logic
                              // You can use url_launcher or a download package
                              launchUrl(Uri.parse(m.url));
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            // Open comment screen for this material
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CommentScreen(materialId: m.id),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
