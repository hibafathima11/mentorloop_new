import 'package:flutter/material.dart';
import 'package:mentorloop/utils/colors.dart';
import 'package:mentorloop/utils/responsive.dart';
import 'package:mentorloop/utils/data_service.dart';
import 'package:mentorloop/models/entities.dart';
// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignmentCreateScreen extends StatefulWidget {
  const AssignmentCreateScreen({super.key});

  @override
  State<AssignmentCreateScreen> createState() => _AssignmentCreateScreenState();
}

class _AssignmentCreateScreenState extends State<AssignmentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseId = TextEditingController();
  final _title = TextEditingController();
  final _description = TextEditingController();
  DateTime _dueAt = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;
  String? _currentTeacherId;
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _getCurrentTeacherId();
  }

  @override
  void dispose() {
    _courseId.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _getCurrentTeacherId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentTeacherId = user.uid;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current user. Please try again.'),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final a = Assignment(
        id: '',
        courseId: _selectedCourseId ?? '',
        teacherId: _currentTeacherId!,
        title: _title.text.trim(),
        description: _description.text.trim(),
        dueAt: _dueAt,
      );
      await DataService.createAssignment(a);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Assignment created')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Create Assignment',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Container(
            padding: ResponsiveHelper.getResponsivePaddingAll(context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getResponsiveCardRadius(context),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Course',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<List<Course>>(
                          stream: _currentTeacherId == null
                              ? const Stream.empty()
                              : DataService.watchTeacherCourses(
                                  _currentTeacherId!,
                                ),
                          builder: (context, snapshot) {
                            final courses = snapshot.data ?? const <Course>[];
                            return DropdownButtonFormField<String>(
                              value: _selectedCourseId,
                              items: courses
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.title),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCourseId = v),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _field(context, _title, 'Title'),
                  const SizedBox(height: 12),
                  _field(context, _description, 'Description', lines: 4),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Due date: '),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueAt,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) setState(() => _dueAt = picked);
                        },
                        child: Text('${_dueAt.toLocal()}'.split(' ')[0]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveHelper.getResponsiveButtonHeight(context),
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5E3C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveCardRadius(context),
                          ),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Create'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    TextEditingController c,
    String label, {
    int lines = 1,
  }) {
    return TextFormField(
      controller: c,
      maxLines: lines,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
