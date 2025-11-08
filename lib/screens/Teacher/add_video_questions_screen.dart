import 'package:flutter/material.dart';
import 'package:mentorloop/utils/colors.dart';
import 'package:mentorloop/utils/responsive.dart';
import 'package:mentorloop/utils/data_service.dart';
import 'package:mentorloop/models/entities.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVideoQuestionsScreen extends StatefulWidget {
  const AddVideoQuestionsScreen({super.key});

  @override
  State<AddVideoQuestionsScreen> createState() =>
      _AddVideoQuestionsScreenState();
}

class _AddVideoQuestionsScreenState extends State<AddVideoQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _videoId = TextEditingController();
  final _question = TextEditingController();
  final _option1 = TextEditingController();
  final _option2 = TextEditingController();
  final _option3 = TextEditingController();
  final _option4 = TextEditingController();
  final _showAt = TextEditingController();
  int _correctIndex = 0;
  bool _isSaving = false;
  String? _currentTeacherId;
  String? _selectedVideoId;

  @override
  void initState() {
    super.initState();
    _currentTeacherId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _videoId.dispose();
    _question.dispose();
    _option1.dispose();
    _option2.dispose();
    _option3.dispose();
    _option4.dispose();
    _showAt.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final showAt = int.tryParse(_showAt.text.trim()) ?? 0;
      final q = VideoQuestion(
        id: '',
        videoId: _selectedVideoId ?? '',
        question: _question.text.trim(),
        options: [
          _option1.text.trim(),
          _option2.text.trim(),
          _option3.text.trim(),
          _option4.text.trim(),
        ],
        correctIndex: _correctIndex,
        showAtSecond: showAt,
      );
      await DataService.addVideoQuestion(q);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Question added')));
      _question.clear();
      _option1.clear();
      _option2.clear();
      _option3.clear();
      _option4.clear();
      _showAt.clear();
      setState(() => _correctIndex = 0);
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
          'Add Video Questions',
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
                  StreamBuilder<List<CourseVideo>>(
                    stream: _currentTeacherId == null
                        ? const Stream.empty()
                        : DataService.watchTeacherVideos(_currentTeacherId!),
                    builder: (context, snapshot) {
                      final videos = snapshot.data ?? const <CourseVideo>[];
                      return DropdownButtonFormField<String>(
                        value: _selectedVideoId,
                        items: videos
                            .map(
                              (v) => DropdownMenuItem(
                                value: v.id,
                                child: Text(v.title),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedVideoId = v),
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
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  _field(context, _question, 'Question'),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  _field(context, _option1, 'Option 1'),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  _field(context, _option2, 'Option 2'),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  _field(context, _option3, 'Option 3'),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  _field(context, _option4, 'Option 4'),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  _field(
                    context,
                    _showAt,
                    'Show at (second)',
                    type: TextInputType.number,
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveMargin(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                  Row(
                    children: [
                      const Text('Correct option index:'),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: _correctIndex,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('0')),
                          DropdownMenuItem(value: 1, child: Text('1')),
                          DropdownMenuItem(value: 2, child: Text('2')),
                          DropdownMenuItem(value: 3, child: Text('3')),
                        ],
                        onChanged: (v) =>
                            setState(() => _correctIndex = v ?? 0),
                      ),
                    ],
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
                      onPressed: _isSaving ? null : _submit,
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
                          : const Text('Add Question'),
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
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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
