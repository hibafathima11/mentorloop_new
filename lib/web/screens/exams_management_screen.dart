import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamsManagementScreen extends StatefulWidget {
  const ExamsManagementScreen({super.key});

  @override
  State<ExamsManagementScreen> createState() => _ExamsManagementScreenState();
}

class _ExamsManagementScreenState extends State<ExamsManagementScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getExamStatus(Exam exam) {
    final now = DateTime.now();
    final startDate = exam.startDate.toDate();
    final endDate = exam.endDate.toDate();
    
    if (now.isBefore(startDate)) {
      return 'Upcoming';
    } else if (now.isAfter(endDate)) {
      return 'Completed';
    } else {
      return 'Ongoing';
    }
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
                    hintText: 'Search exams...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedStatus,
                items: ['All', 'Ongoing', 'Upcoming', 'Completed']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Exams List
          StreamBuilder<List<Exam>>(
            stream: DataService.watchAllExams(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading exams: ${snapshot.error}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final allExams = snapshot.data ?? [];

              // Filter exams
              final filteredExams = allExams.where((exam) {
                final titleMatch = exam.title
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase());
                final status = _getExamStatus(exam);
                final statusMatch = _selectedStatus == 'All' ||
                    status == _selectedStatus;
                return titleMatch && statusMatch;
              }).toList();

              if (filteredExams.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          allExams.isEmpty
                              ? 'No exams are going on'
                              : 'No exams found matching your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredExams.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final exam = filteredExams[index];
                  final status = _getExamStatus(exam);
                  final startDate = exam.startDate.toDate();
                  final endDate = exam.endDate.toDate();
                  final startDateStr =
                      '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')} ${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')}';
                  final endDateStr =
                      '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')} ${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';

                  return FutureBuilder<Map<String, dynamic>>(
                    future: _loadExamDetails(exam),
                    builder: (context, detailsSnapshot) {
                      final courseName =
                          detailsSnapshot.data?['courseName'] ?? 'Loading...';
                      final teacherName =
                          detailsSnapshot.data?['teacherName'] ?? 'Loading...';
                      final attemptsCount =
                          detailsSnapshot.data?['attemptsCount'] ?? 0;
                      final studentsAttended =
                          detailsSnapshot.data?['studentsAttended'] ?? <String>[];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            '📝',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  exam.title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  exam.description.isEmpty
                                                      ? 'No description'
                                                      : exam.description,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: status == 'Ongoing'
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : status == 'Upcoming'
                                            ? Colors.blue.withValues(alpha: 0.1)
                                            : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: status == 'Ongoing'
                                          ? Colors.green
                                          : status == 'Upcoming'
                                              ? Colors.blue
                                              : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 24,
                              runSpacing: 16,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Course',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      courseName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Conducted By',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      teacherName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Duration',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${exam.durationMinutes} minutes',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Start Date & Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      startDateStr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'End Date & Time',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      endDateStr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Students Attended',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$attemptsCount student${attemptsCount != 1 ? 's' : ''}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (studentsAttended.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text(
                                'Attended Students:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: studentsAttended
                                    .map((studentName) => Chip(
                                          label: Text(
                                            studentName,
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                          backgroundColor: Colors.grey[100],
                                        ))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _loadExamDetails(Exam exam) async {
    final db = FirebaseFirestore.instance;
    String courseName = 'Unknown';
    String teacherName = 'Unknown';
    int attemptsCount = 0;
    List<String> studentsAttended = [];

    // Get course name
    if (exam.courseId.isNotEmpty) {
      try {
        final courseDoc =
            await db.collection('courses').doc(exam.courseId).get();
        courseName = courseDoc.data()?['title'] ?? 'Unknown';
      } catch (e) {
        // Ignore
      }
    }

    // Get teacher name
    if (exam.teacherId.isNotEmpty) {
      try {
        final teacherDoc =
            await db.collection('users').doc(exam.teacherId).get();
        teacherName = teacherDoc.data()?['name'] ?? 'Unknown';
      } catch (e) {
        // Ignore
      }
    }

    // Get exam attempts
    try {
      final attemptsSnapshot = await db
          .collection('exam_attempts')
          .where('examId', isEqualTo: exam.id)
          .get();
      attemptsCount = attemptsSnapshot.docs.length;

      // Get student names who attended
      for (var attemptDoc in attemptsSnapshot.docs) {
        final attemptData = attemptDoc.data();
        final studentId = attemptData['studentId'] as String?;
        if (studentId != null && studentId.isNotEmpty) {
          try {
            final studentDoc = await db.collection('users').doc(studentId).get();
            final studentName = studentDoc.data()?['name'] ?? 'Unknown';
            if (!studentsAttended.contains(studentName)) {
              studentsAttended.add(studentName);
            }
          } catch (e) {
            // Ignore
          }
        }
      }
    } catch (e) {
      // Ignore
    }

    return {
      'courseName': courseName,
      'teacherName': teacherName,
      'attemptsCount': attemptsCount,
      'studentsAttended': studentsAttended,
    };
  }
}
