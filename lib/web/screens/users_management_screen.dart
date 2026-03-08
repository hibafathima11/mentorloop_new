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
          _buildFilters(),
          const SizedBox(height: 20),
          Expanded(child: _buildUsersList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        SizedBox(width: 300, child: _buildSearchBar()),
        const SizedBox(width: 16),
        SizedBox(width: 150, child: _buildRoleFilter()),
        const SizedBox(width: 16),
        SizedBox(width: 150, child: _buildStatusFilter()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        onSubmitted: (value) => setState(() => _searchQuery = value),
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: Colors.black),
        decoration: const InputDecoration(
          hintText: 'Search users...',
          hintStyle: TextStyle(color: Colors.black54),
          prefixIcon: Icon(Icons.search, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildRoleFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All')),
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
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All')),
            DropdownMenuItem(value: 'approved', child: Text('Approved')),
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedStatus = value);
            }
          },
        ),
      ),
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

        var users = snapshot.data?.docs ?? [];
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          users = users.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['name'] as String? ?? '').toLowerCase();
            final email = (data['email'] as String? ?? '').toLowerCase();
            return name.contains(query) || email.contains(query);
          }).toList();
        }

        if (users.isEmpty) {
          return const Center(
            child: Text('No users found', style: TextStyle(color: Colors.grey)),
          );
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 60,
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Join Date')),
                ],
                rows: users.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildUserRow(doc.id, data);
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildUserRow(String userId, Map<String, dynamic> userData) {
    final name = userData['name'] as String? ?? 'Unknown';
    final email = userData['email'] as String? ?? '';
    final role = userData['role'] as String? ?? 'user';
    final approved = userData['approved'] as bool? ?? false;
    final suspended = userData['suspended'] as bool? ?? false;
    final photoUrl = userData['photoUrl'] as String? ?? '';
    final createdAt = userData['createdAt'] as Timestamp?;

    return DataRow(
      cells: [
        DataCell(
          InkWell(
            onTap: () => _showUserDetails(userId, userData),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        DataCell(Text(email, style: const TextStyle(color: Colors.black87))),
        DataCell(_buildRoleBadge(role)),
        DataCell(_buildStatusBadge(approved, suspended)),
        DataCell(
          Text(
            createdAt != null
                ? "${createdAt.toDate().year}-${createdAt.toDate().month.toString().padLeft(2, '0')}-${createdAt.toDate().day.toString().padLeft(2, '0')}"
                : 'N/A',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    Color bg;
    Color textColors;
    switch (role.toLowerCase()) {
      case 'admin':
        bg = Colors.red[50]!;
        textColors = Colors.red;
        break;
      case 'teacher':
        bg = Colors.green[50]!;
        textColors = Colors.green;
        break;
      case 'parent':
        bg = Colors.blue[50]!;
        textColors = Colors.blue;
        break;
      case 'student':
        bg = Colors.deepOrange[50]!;
        textColors = Colors.deepOrange;
        break;
      default:
        bg = Colors.grey[100]!;
        textColors = Colors.grey[700]!;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role[0].toUpperCase() + role.substring(1).toLowerCase(),
        style: TextStyle(
          color: textColors,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _getFilteredUsersStream() {
    Query query = FirebaseFirestore.instance.collection('users');

    if (_selectedRole != 'all') {
      query = query.where('role', isEqualTo: _selectedRole);
    }

    if (_selectedStatus != 'all') {
      if (_selectedStatus == 'approved') {
        query = query.where('approved', isEqualTo: true);
      } else if (_selectedStatus == 'pending') {
        query = query.where('approved', isEqualTo: false);
      } else if (_selectedStatus == 'suspended') {
        query = query.where('suspended', isEqualTo: true);
      }
    }

    return query.snapshots();
  }

  Widget _buildStatusBadge(bool approved, bool suspended) {
    String text;
    Color bg;
    Color textColors;

    if (suspended) {
      text = 'Suspended';
      bg = Colors.red[50]!;
      textColors = Colors.red;
    } else if (approved) {
      text = 'Active';
      bg = Colors.green[50]!;
      textColors = Colors.green;
    } else {
      text = 'Pending';
      bg = Colors.orange[50]!;
      textColors = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColors,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
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
                    color: const Color(0xFF8B5E3C).withOpacity(0.05),
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
                            _buildRoleBadge(role),
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
}
