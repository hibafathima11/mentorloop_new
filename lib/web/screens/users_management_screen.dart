import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop_new/utils/responsive.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'all';
  String _selectedStatus = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePaddingAll(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildFilters(),
          const SizedBox(height: 20),
          Expanded(child: _buildUsersList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Users Management',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddUserDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add User'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5E3C),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: ResponsiveHelper.getResponsivePaddingAll(context),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildRoleFilter()),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusFilter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          hintText: 'Search users by name or email...',
          hintStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(Icons.search, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRoleFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: const InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Roles')),
        DropdownMenuItem(value: 'student', child: Text('Student')),
        DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
        DropdownMenuItem(value: 'parent', child: Text('Parent')),
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedRole = value);
        }
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Status')),
        DropdownMenuItem(value: 'approved', child: Text('Approved')),
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedStatus = value);
        }
      },
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getFilteredUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading users: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final users = snapshot.data?.docs ?? [];

        if (users.isEmpty) {
          return const Center(
            child: Text('No users found', style: TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final doc = users[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildUserCard(doc.id, data);
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getFilteredUsersStream() {
    Query query = FirebaseFirestore.instance.collection('users');

    // Apply role filter
    if (_selectedRole != 'all') {
      query = query.where('role', isEqualTo: _selectedRole);
    }

    // Apply status filter
    if (_selectedStatus != 'all') {
      if (_selectedStatus == 'approved') {
        query = query.where('approved', isEqualTo: true);
      } else if (_selectedStatus == 'pending') {
        query = query.where('approved', isEqualTo: false);
      } else if (_selectedStatus == 'suspended') {
        query = query.where('suspended', isEqualTo: true);
      }
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  Widget _buildUserCard(String userId, Map<String, dynamic> userData) {
    final name = userData['name'] as String? ?? 'Unknown';
    final email = userData['email'] as String? ?? '';
    final role = userData['role'] as String? ?? 'user';
    final approved = userData['approved'] as bool? ?? false;
    final suspended = userData['suspended'] as bool? ?? false;
    final photoUrl = userData['photoUrl'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF8B5E3C),
          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
          child: photoUrl.isEmpty
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildRoleChip(role),
                const SizedBox(width: 8),
                _buildStatusChip(approved, suspended),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, userId, userData),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('View Details'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                dense: true,
              ),
            ),
            if (!approved)
              const PopupMenuItem(
                value: 'approve',
                child: ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text('Approve'),
                  dense: true,
                ),
              ),
            if (approved)
              const PopupMenuItem(
                value: 'suspend',
                child: ListTile(
                  leading: Icon(Icons.block),
                  title: Text('Suspend'),
                  dense: true,
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
        ),
        onTap: () => _showUserDetails(userId, userData),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    switch (role) {
      case 'admin':
        color = Colors.red;
        break;
      case 'teacher':
        color = Colors.blue;
        break;
      case 'parent':
        color = Colors.green;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(
        role.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildStatusChip(bool approved, bool suspended) {
    if (suspended) {
      return const Chip(
        label: Text(
          'SUSPENDED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    } else if (approved) {
      return const Chip(
        label: Text(
          'APPROVED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    } else {
      return const Chip(
        label: Text(
          'PENDING',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
  }

  void _handleUserAction(
    String action,
    String userId,
    Map<String, dynamic> userData,
  ) {
    switch (action) {
      case 'view':
        _showUserDetails(userId, userData);
        break;
      case 'edit':
        _showEditUserDialog(userId, userData);
        break;
      case 'approve':
        _approveUser(userId);
        break;
      case 'suspend':
        _suspendUser(userId);
        break;
      case 'delete':
        _deleteUser(userId);
        break;
    }
  }

  void _showUserDetails(String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) {
        final role = userData['role'] as String? ?? 'user';
        final name = userData['name'] as String? ?? 'Unknown';
        final email = userData['email'] as String? ?? 'N/A';
        final phone = userData['phone'] as String? ?? 'N/A';
        final approved = userData['approved'] == true;
        final createdAt = userData['createdAt'] as Timestamp?;
        final photoUrl = userData['photoUrl'] as String?;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Profile Info
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5E3C).withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF8B5E3C),
                        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null || photoUrl.isEmpty
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildRoleChip(role),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Info
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _detailRow(Icons.email_outlined, 'Email', email),
                      _detailRow(Icons.phone_outlined, 'Phone', phone),
                      _detailRow(
                        Icons.verified_user_outlined,
                        'Status',
                        approved ? 'Approved' : 'Pending Approval',
                        valueColor: approved ? Colors.green : Colors.orange,
                      ),
                      _detailRow(
                        Icons.calendar_today_outlined,
                        'Joined On',
                        createdAt != null
                            ? createdAt.toDate().toString().split(' ')[0]
                            : 'N/A',
                      ),
                      const Divider(height: 32),

                      // Role Specific Data
                      if (role == 'student') ...[
                        _buildStudentSection(userId),
                      ] else if (role == 'teacher') ...[
                        _buildTeacherSection(userId),
                      ] else if (role == 'parent') ...[
                        _buildParentSection(email),
                      ],
                    ],
                  ),
                ),
                // Actions
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      if (!approved) ...[
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _approveUser(userId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Approve Now'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8B5E3C)),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSection(String studentId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guardian Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('guardians')
              .where('studentId', isEqualTo: studentId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text(
                'No guardian details found',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              );
            }
            final guardian =
                snapshot.data!.docs.first.data() as Map<String, dynamic>;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _detailRow(
                    Icons.person_outline,
                    'Name',
                    guardian['name'] ?? 'N/A',
                  ),
                  _detailRow(
                    Icons.family_restroom_outlined,
                    'Relation',
                    guardian['relation'] ?? 'N/A',
                  ),
                  _detailRow(
                    Icons.phone_outlined,
                    'Phone',
                    guardian['phone'] ?? 'N/A',
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Enrolled Courses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('courses')
              .where('studentIds', arrayContains: studentId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text(
                'Not enrolled in any courses',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: snapshot.data!.docs.map((doc) {
                final course = doc.data() as Map<String, dynamic>;
                return Chip(
                  label: Text(course['title'] ?? 'Unknown Course'),
                  backgroundColor: const Color(
                    0xFF8B5E3C,
                  ).withValues(alpha: 0.1),
                  labelStyle: const TextStyle(
                    color: Color(0xFF8B5E3C),
                    fontSize: 12,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTeacherSection(String teacherId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Courses Taught',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('courses')
              .where('teacherId', isEqualTo: teacherId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text(
                'No courses assigned yet',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final course =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.book_outlined,
                    color: Color(0xFF8B5E3C),
                  ),
                  title: Text(course['title'] ?? 'Unknown Course'),
                  subtitle: Text(
                    '${(course['studentIds'] as List?)?.length ?? 0} Students Enrolled',
                  ),
                  dense: true,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildParentSection(String parentEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Linked Students',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5E3C),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('guardians')
              .where('email', isEqualTo: parentEmail)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text(
                'No students linked yet',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              );
            }
            return Column(
              children: snapshot.data!.docs.map((doc) {
                final guardian = doc.data() as Map<String, dynamic>;
                final studentId = guardian['studentId'] ?? '';
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(studentId)
                      .get(),
                  builder: (context, studentSnapshot) {
                    if (!studentSnapshot.hasData) return const SizedBox();
                    final student =
                        studentSnapshot.data!.data() as Map<String, dynamic>?;
                    if (student == null) return const SizedBox();
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.school_outlined,
                        color: Color(0xFF8B5E3C),
                      ),
                      title: Text(student['name'] ?? 'Unknown Student'),
                      subtitle: Text(student['email'] ?? ''),
                      dense: true,
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showEditUserDialog(String userId, Map<String, dynamic> userData) {
    // Implementation for editing user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit user functionality coming soon')),
    );
  }

  void _showAddUserDialog() {
    // Implementation for adding user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add user functionality coming soon')),
    );
  }

  Future<void> _approveUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'approved': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User approved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error approving user: $e')));
    }
  }

  Future<void> _suspendUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'suspended': true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User suspended successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error suspending user: $e')));
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting user: $e')));
      }
    }
  }
}
