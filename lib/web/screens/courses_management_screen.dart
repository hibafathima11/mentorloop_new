import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';

class CoursesManagementScreen extends StatefulWidget {
  const CoursesManagementScreen({super.key});

  @override
  State<CoursesManagementScreen> createState() =>
      _CoursesManagementScreenState();
}

class _CoursesManagementScreenState extends State<CoursesManagementScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All';
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await DataService.watchAllCourses().first;
      if (mounted) {
        setState(() {
          _courses = courses
              .map(
                (course) => {
                  'id': course.id,
                  'name': course.title,
                  'teacher': 'Loading...', // Will be loaded separately
                  'students': course.studentIds.length,
                  'status': 'Active',
                  'createdDate':
                      course.createdAt?.toString() ?? DateTime.now().toString(),
                  'progress': 0,
                  'icon': '🎯',
                },
              )
              .toList();
          _isLoading = false;
        });
        // Load teacher names
        _loadTeacherNames();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTeacherNames() async {
    final db = FirebaseFirestore.instance;
    for (var course in _courses) {
      try {
        final courseDoc = await db
            .collection('courses')
            .doc(course['id'])
            .get();
        final teacherId = courseDoc.data()?['teacherId'];
        if (teacherId != null) {
          final teacherDoc = await db.collection('users').doc(teacherId).get();
          final teacherName = teacherDoc.data()?['name'] ?? 'Unknown';
          setState(() {
            course['teacher'] = teacherName;
          });
        }
      } catch (e) {
        // Ignore errors
      }
    }
  }

  List<Map<String, dynamic>> get _filteredCourses {
    return _courses.where((course) {
      final nameMatch = course['name'].toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      final statusMatch =
          _selectedStatus == 'All' || course['status'] == _selectedStatus;
      return nameMatch && statusMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePaddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search and filters
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 300,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedStatus,
                items: ['All', 'Active', 'Draft', 'Archived']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              // Removed create button - admin view only
            ],
          ),
          const SizedBox(height: 24),

          // Courses Grid
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredCourses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No courses found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile
                    ? 1
                    : (screenSize.width > 1200 ? 3 : 2),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: _filteredCourses.length,
              itemBuilder: (context, index) {
                final course = _filteredCourses[index];
                return _CourseCard(
                  course: course,
                  onEdit: () => _showEditTeacherDialog(course),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showEditTeacherDialog(Map<String, dynamic> courseData) async {
    final db = FirebaseFirestore.instance;
    final courseDoc = await db
        .collection('courses')
        .doc(courseData['id'])
        .get();
    if (!courseDoc.exists) return;

    final course = Course.fromMap(courseDoc.id, courseDoc.data()!);
    String? selectedTeacherId = course.teacherId;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Teacher - ${course.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a new teacher for this course:'),
              const SizedBox(height: 16),
              StreamBuilder<List<UserProfile>>(
                stream: DataService.streamTeachers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const CircularProgressIndicator();
                  final teachers = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    value: selectedTeacherId,
                    items: teachers.map((t) {
                      return DropdownMenuItem(
                        value: t.uid,
                        child: Text(t.name.isNotEmpty ? t.name : t.email),
                      );
                    }).toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedTeacherId = v),
                    decoration: const InputDecoration(
                      labelText: 'Teacher',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final updatedCourse = Course(
                    id: course.id,
                    title: course.title,
                    description: course.description,
                    teacherId: selectedTeacherId ?? '',
                    studentIds: course.studentIds,
                  );
                  await DataService.updateCourse(course.id, updatedCourse);
                  await _loadCourses(); // Refresh list
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5E3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onEdit;

  const _CourseCard({required this.course, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    course['icon'],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: course['status'] == 'Active'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  course['status'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: course['status'] == 'Active'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            course['name'],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'by ${course['teacher']}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${course['students']} students',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              Text(
                '${course['progress']}% done',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: course['progress'] / 100,
              minHeight: 4,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF8B5E3C),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Edit Button
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Teacher'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B5E3C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
