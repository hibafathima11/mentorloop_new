import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentsManagementScreen extends StatefulWidget {
  const AssignmentsManagementScreen({super.key});

  @override
  State<AssignmentsManagementScreen> createState() =>
      _AssignmentsManagementScreenState();
}

class _AssignmentsManagementScreenState
    extends State<AssignmentsManagementScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'All';

  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    try {
      final db = FirebaseFirestore.instance;
      final assignmentsSnapshot = await db.collection('assignments').get();
      
      final assignments = <Map<String, dynamic>>[];
      for (var doc in assignmentsSnapshot.docs) {
        final data = doc.data();
        // Get course name and student count
        String courseName = 'Unknown';
        int totalStudents = 0;
        if (data['courseId'] != null) {
          try {
            final courseDoc = await db.collection('courses').doc(data['courseId']).get();
            final courseData = courseDoc.data();
            courseName = courseData?['title'] ?? 'Unknown';
            final studentIds = courseData?['studentIds'] as List?;
            totalStudents = studentIds?.length ?? 0;
          } catch (e) {
            // Ignore
          }
        }
        // Get teacher name
        String teacherName = 'Unknown';
        if (data['teacherId'] != null) {
          try {
            final teacherDoc = await db.collection('users').doc(data['teacherId']).get();
            teacherName = teacherDoc.data()?['name'] ?? 'Unknown';
          } catch (e) {
            // Ignore
          }
        }
        
        // Get submission count
        int submissionCount = 0;
        try {
          final submissionsSnapshot = await db
              .collection('submissions')
              .where('assignmentId', isEqualTo: doc.id)
              .get();
          submissionCount = submissionsSnapshot.docs.length;
        } catch (e) {
          // Ignore
        }
        
        // Format due date
        String dueDateStr = 'Not set';
        if (data['dueDate'] != null) {
          if (data['dueDate'] is Timestamp) {
            final date = (data['dueDate'] as Timestamp).toDate();
            dueDateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          } else {
            dueDateStr = data['dueDate'].toString();
          }
        }
        
        assignments.add({
          'id': doc.id,
          'title': data['title'] ?? 'Untitled',
          'course': courseName,
          'teacher': teacherName,
          'dueDate': dueDateStr,
          'submissions': submissionCount,
          'total': totalStudents,
          'status': 'Active',
          'icon': '📋',
        });
      }
      
      if (mounted) {
        setState(() {
          _assignments = assignments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredAssignments {
    return _assignments.where((assignment) {
      final titleMatch = assignment['title']
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final statusMatch = _selectedStatus == 'All' ||
          assignment['status'] == _selectedStatus;
      return titleMatch && statusMatch;
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
                    hintText: 'Search assignments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedStatus,
                items: ['All', 'Active', 'Pending', 'Closed']
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
              // Removed create button - admin view only
            ],
          ),
          const SizedBox(height: 24),

          // Assignments List
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_filteredAssignments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No assignments found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredAssignments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final assignment = _filteredAssignments[index];
                final submissions = assignment['submissions'] as int;
                final total = assignment['total'] as int;
                final submissionPercentage = total > 0
                    ? ((submissions / total) * 100).toStringAsFixed(0)
                    : '0';

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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      assignment['icon'],
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            assignment['title'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            assignment['course'],
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
                              color: assignment['status'] == 'Active'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              assignment['status'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: assignment['status'] == 'Active'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Submissions',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$submissions/$total ($submissionPercentage%)',
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
                                'Due Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                assignment['dueDate'],
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
                                'Teacher',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                assignment['teacher'],
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
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total > 0 ? (submissions / total) : 0.0,
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B5E3C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Removed edit/delete buttons - admin view only
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
