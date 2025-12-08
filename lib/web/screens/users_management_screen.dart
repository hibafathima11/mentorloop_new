import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/widgets/admin_layout.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final _searchController = TextEditingController();
  String _selectedRole = 'All';
  String _selectedStatus = 'All';

  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'role': 'Student',
      'status': 'Active',
      'joinDate': '2024-01-15',
      'avatar': '👤',
    },
    {
      'id': '2',
      'name': 'Sarah Smith',
      'email': 'sarah@example.com',
      'role': 'Teacher',
      'status': 'Active',
      'joinDate': '2024-01-10',
      'avatar': '👩‍🏫',
    },
    {
      'id': '3',
      'name': 'Emma Wilson',
      'email': 'emma@example.com',
      'role': 'Parent',
      'status': 'Pending',
      'joinDate': '2024-02-01',
      'avatar': '👩',
    },
    {
      'id': '4',
      'name': 'Mike Johnson',
      'email': 'mike@example.com',
      'role': 'Teacher',
      'status': 'Active',
      'joinDate': '2023-12-20',
      'avatar': '👨‍🏫',
    },
    {
      'id': '5',
      'name': 'Lisa Brown',
      'email': 'lisa@example.com',
      'role': 'Student',
      'status': 'Inactive',
      'joinDate': '2024-01-05',
      'avatar': '👤',
    },
  ];

  late List<Map<String, dynamic>> _filteredUsers;

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
  }

  void _filterUsers() {
    _filteredUsers = _users.where((user) {
      final nameMatch =
          user['name'].toLowerCase().contains(_searchController.text.toLowerCase());
      final roleMatch =
          _selectedRole == 'All' || user['role'] == _selectedRole;
      final statusMatch =
          _selectedStatus == 'All' || user['status'] == _selectedStatus;
      return nameMatch && roleMatch && statusMatch;
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
      title: 'Users Management',
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
                  onChanged: (_) => _filterUsers(),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedRole,
                items: ['All', 'Student', 'Teacher', 'Parent']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                    _filterUsers();
                  }
                },
              ),
              DropdownButton<String>(
                value: _selectedStatus,
                items: ['All', 'Active', 'Inactive', 'Pending']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                    _filterUsers();
                  }
                },
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add user feature coming soon')),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Add User'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Users Table
          Container(
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
            child: _filteredUsers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: isMobile ? Axis.horizontal : Axis.vertical,
                    child: SizedBox(
                      width: isMobile ? 800 : double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Role',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Join Date',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Actions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: _filteredUsers
                            .map(
                              (user) => DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF8B5E3C)
                                                .withOpacity(0.1),
                                          ),
                                          child: Center(
                                            child: Text(
                                              user['avatar'],
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(user['name']),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(user['email'])),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getRoleColor(user['role'])
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        user['role'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _getRoleColor(user['role']),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(user['status'])
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        user['status'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(user['status']),
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(user['joinDate'])),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              size: 18),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Edit user feature coming soon',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Delete user feature coming soon',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Teacher':
        return const Color(0xFF6B9D5C);
      case 'Parent':
        return const Color(0xFF5B7DB9);
      case 'Student':
        return const Color(0xFF8B5E3C);
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
