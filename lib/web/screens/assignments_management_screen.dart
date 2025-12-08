import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/widgets/admin_layout.dart';

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

  final List<Map<String, dynamic>> _assignments = [
    {
      'id': '1',
      'title': 'Flutter Widgets Assignment',
      'course': 'Flutter Development Basics',
      'teacher': 'Sarah Smith',
      'dueDate': '2024-02-15',
      'submissions': 18,
      'total': 24,
      'status': 'Active',
      'icon': '📋',
    },
    {
      'id': '2',
      'title': 'Web API Integration Project',
      'course': 'Advanced Web Technologies',
      'teacher': 'Mike Johnson',
      'dueDate': '2024-02-10',
      'submissions': 16,
      'total': 18,
      'status': 'Active',
      'icon': '🌐',
    },
    {
      'id': '3',
      'title': 'Data Analysis with Python',
      'course': 'Data Science Fundamentals',
      'teacher': 'Sarah Smith',
      'dueDate': '2024-02-20',
      'submissions': 28,
      'total': 32,
      'status': 'Active',
      'icon': '📊',
    },
    {
      'id': '4',
      'title': 'UI Mockup Design',
      'course': 'UI/UX Design Principles',
      'teacher': 'Emma Wilson',
      'dueDate': '2024-03-05',
      'submissions': 0,
      'total': 15,
      'status': 'Pending',
      'icon': '🎨',
    },
    {
      'id': '5',
      'title': 'Mobile App Prototype',
      'course': 'Mobile App Development',
      'teacher': 'Mike Johnson',
      'dueDate': '2024-02-28',
      'submissions': 22,
      'total': 28,
      'status': 'Active',
      'icon': '📱',
    },
  ];

  late List<Map<String, dynamic>> _filteredAssignments;

  @override
  void initState() {
    super.initState();
    _filteredAssignments = _assignments;
  }

  void _filterAssignments() {
    _filteredAssignments = _assignments.where((assignment) {
      final titleMatch = assignment['title']
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
      final statusMatch = _selectedStatus == 'All' ||
          assignment['status'] == _selectedStatus;
      return titleMatch && statusMatch;
    }).toList();
    setState(() {});
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

    return AdminLayout(
      title: 'Assignments Management',
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
                  onChanged: (_) => _filterAssignments(),
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
                    _filterAssignments();
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Create assignment feature coming soon'),
                    ),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('New Assignment'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Assignments List
          if (_filteredAssignments.isEmpty)
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
                final submissionPercentage =
                    (assignment['submissions'] / assignment['total'] * 100)
                        .toStringAsFixed(0);

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
                                '${assignment['submissions']}/${assignment['total']} ($submissionPercentage%)',
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
                          value: assignment['submissions'] / assignment['total'],
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF8B5E3C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('View details coming soon'),
                                ),
                              );
                            },
                            child: const Text('View Submissions'),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Edit assignment coming soon'),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Delete assignment coming soon'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
