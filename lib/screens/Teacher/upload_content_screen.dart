import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:mentorloop_new/utils/cloudinary_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

class UploadContentScreen extends StatefulWidget {
  const UploadContentScreen({super.key});

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _materialFormKey = GlobalKey<FormState>();
  final _videoFormKey = GlobalKey<FormState>();

  // Material controllers
  final _materialCourseId = TextEditingController();
  final _materialTitle = TextEditingController();
  final _materialType = ValueNotifier<String>('link');
  final _materialUrl = TextEditingController();
  // Removed manual local path; we will use system file picker

  // Video controllers
  final _videoCourseId = TextEditingController();
  final _videoTitle = TextEditingController();
  final _videoUrl = TextEditingController();
  final _videoDuration = TextEditingController();
  // Removed manual local path; we will use system file picker

  // Current teacher ID
  String? _currentTeacherId;
  String? _selectedMaterialCourseId;
  String? _selectedVideoCourseId;

  bool _isSavingMaterial = false;
  bool _isSavingVideo = false;
  bool _isUploadingMaterial = false;
  bool _isUploadingVideo = false;


  @override
  void initState() {
    super.initState();
    _getCurrentTeacherId();
  }

  @override
  void dispose() {
    _materialCourseId.dispose();
    _materialTitle.dispose();
    _materialUrl.dispose();

    _materialType.dispose();

    _videoCourseId.dispose();
    _videoTitle.dispose();
    _videoUrl.dispose();
    _videoDuration.dispose();

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

  Future<void> _uploadMaterialToCloudinary() async {
    setState(() => _isUploadingMaterial = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) {
        if (mounted) {
          setState(() => _isUploadingMaterial = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected')),
          );
        }
        return;
      }
      final path = result.files.single.path;
      if (path == null) {
        if (mounted) {
          setState(() => _isUploadingMaterial = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not access file path')),
          );
        }
        return;
      }
      final file = File(path);
      if (!await file.exists()) {
        if (mounted) {
          setState(() => _isUploadingMaterial = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File does not exist')),
          );
        }
        return;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading file...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      final secureUrl = await CloudinaryService.uploadFile(
        file: file,
        resourceType: 'auto',
      );
      
      if (secureUrl.isEmpty) {
        throw Exception('Upload succeeded but no URL returned');
      }
      
      _materialUrl.text = secureUrl;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Material uploaded successfully!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingMaterial = false);
    }
  }

  Future<void> _uploadVideoToCloudinary() async {
    setState(() => _isUploadingVideo = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.video,
      );
      if (result == null || result.files.isEmpty) {
        if (mounted) {
          setState(() => _isUploadingVideo = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No file selected')),
          );
        }
        return;
      }
      final path = result.files.single.path;
      if (path == null) {
        if (mounted) {
          setState(() => _isUploadingVideo = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not access file path')),
          );
        }
        return;
      }
      final file = File(path);
      if (!await file.exists()) {
        if (mounted) {
          setState(() => _isUploadingVideo = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File does not exist')),
          );
        }
        return;
      }
      
      // Show uploading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading video... This may take a while.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      final secureUrl = await CloudinaryService.uploadFile(
        file: file,
        resourceType: 'video',
      );
      
      if (secureUrl.isEmpty) {
        throw Exception('Upload succeeded but no URL returned');
      }
      
      _videoUrl.text = secureUrl;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Video uploaded successfully!\nURL: ${secureUrl.substring(0, secureUrl.length > 50 ? 50 : secureUrl.length)}...'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingVideo = false);
    }
  }

  Future<void> _submitMaterial() async {
    if (!_materialFormKey.currentState!.validate()) return;
    if (_currentTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current user. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedMaterialCourseId == null || _selectedMaterialCourseId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_materialUrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a URL or upload a file'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isSavingMaterial = true);
    try {
      final material = StudyMaterial(
        id: '',
        courseId: _selectedMaterialCourseId!,
        teacherId: _currentTeacherId!,
        title: _materialTitle.text.trim(),
        type: _materialType.value,
        url: _materialUrl.text.trim(),
      );
      await DataService.addMaterial(material);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Material saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      _materialTitle.clear();
      _materialUrl.clear();
      setState(() {
        _selectedMaterialCourseId = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving material: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingMaterial = false);
    }
  }

  Future<void> _submitVideo() async {
    if (!_videoFormKey.currentState!.validate()) return;
    if (_currentTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current user. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedVideoCourseId == null || _selectedVideoCourseId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_videoUrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a video first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isSavingVideo = true);
    try {
      final duration = int.tryParse(_videoDuration.text.trim()) ?? 0;
      if (duration <= 0) {
        throw Exception('Duration must be greater than 0');
      }
      final video = CourseVideo(
        id: '',
        courseId: _selectedVideoCourseId!,
        teacherId: _currentTeacherId!,
        title: _videoTitle.text.trim(),
        url: _videoUrl.text.trim(),
        durationSeconds: duration,
      );
      await DataService.addVideo(video);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      _videoTitle.clear();
      _videoUrl.clear();
      _videoDuration.clear();
      setState(() {
        _selectedVideoCourseId = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving video: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSavingVideo = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Upload Content',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study Materials',
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
              _buildMaterialForm(context),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 30,
                  tablet: 40,
                  desktop: 50,
                ),
              ),
              Text(
                'Course Videos',
                style: TextStyle(
                  color: const Color(0xFF8B5E3C),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveMargin(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
              _buildVideoForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialForm(BuildContext context) {
    return Container(
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
        key: _materialFormKey,
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
                        : DataService.watchTeacherCourses(_currentTeacherId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Error loading courses: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      final courses = snapshot.data ?? const <Course>[];
                      if (courses.isEmpty) {
                        return const Text(
                          'No courses found. Please create a course first.',
                          style: TextStyle(color: Colors.orange),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedMaterialCourseId,
                        items: courses
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.title),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedMaterialCourseId = v),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveCardRadius(context),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding:
                              ResponsiveHelper.getResponsivePaddingSymmetric(
                                context,
                                horizontal: 16,
                                vertical: 14,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
            _buildTextField(
              context,
              controller: _materialTitle,
              label: 'Title',
              validator: _nonEmpty,
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
            ValueListenableBuilder<String>(
              valueListenable: _materialType,
              builder: (context, value, _) {
                return DropdownButtonFormField<String>(
                  value: value,
                  items: const [
                    DropdownMenuItem(value: 'link', child: Text('Link')),
                    DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                    DropdownMenuItem(value: 'doc', child: Text('Doc')),
                  ],
                  onChanged: (v) => _materialType.value = v ?? 'link',
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding:
                        ResponsiveHelper.getResponsivePaddingSymmetric(
                          context,
                          horizontal: 16,
                          vertical: 14,
                        ),
                  ),
                );
              },
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isUploadingMaterial
                    ? null
                    : _uploadMaterialToCloudinary,
                icon: _isUploadingMaterial
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload, color: Color(0xFF8B5E3C)),
                label: const Text('Upload'),
              ),
            ),
            _buildTextField(
              context,
              controller: _materialUrl,
              label: 'URL (auto-filled after upload)',
              validator: _nonEmpty,
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.getResponsiveButtonHeight(context),
              child: ElevatedButton(
                onPressed: _isSavingMaterial ? null : _submitMaterial,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5E3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                  ),
                ),
                child: _isSavingMaterial
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save Material'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoForm(BuildContext context) {
    return Container(
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
        key: _videoFormKey,
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
                        : DataService.watchTeacherCourses(_currentTeacherId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text(
                          'Error loading courses: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      }
                      final courses = snapshot.data ?? const <Course>[];
                      if (courses.isEmpty) {
                        return const Text(
                          'No courses found. Please create a course first.',
                          style: TextStyle(color: Colors.orange),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedVideoCourseId,
                        items: courses
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.title),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedVideoCourseId = v),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ResponsiveHelper.getResponsiveCardRadius(context),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding:
                              ResponsiveHelper.getResponsivePaddingSymmetric(
                                context,
                                horizontal: 16,
                                vertical: 14,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
            _buildTextField(
              context,
              controller: _videoTitle,
              label: 'Title',
              validator: _nonEmpty,
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _isUploadingVideo ? null : _uploadVideoToCloudinary,
                icon: _isUploadingVideo
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload, color: Color(0xFF8B5E3C)),
                label: const Text('Upload'),
              ),
            ),
            _buildTextField(
              context,
              controller: _videoUrl,
              label: 'Video URL (auto-filled after upload)',
              validator: _nonEmpty,
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
            _buildTextField(
              context,
              controller: _videoDuration,
              label: 'Duration (seconds)',
              validator: _nonEmpty,
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveMargin(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: ResponsiveHelper.getResponsiveButtonHeight(context),
              child: ElevatedButton(
                onPressed: _isSavingVideo ? null : _submitVideo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5E3C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getResponsiveCardRadius(context),
                    ),
                  ),
                ),
                child: _isSavingVideo
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save Video'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _nonEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveHelper.getResponsiveCardRadius(context),
          ),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: ResponsiveHelper.getResponsivePaddingSymmetric(
          context,
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
