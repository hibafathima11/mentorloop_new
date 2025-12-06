import 'package:flutter/material.dart';
import 'package:mentorloop_new/utils/colors.dart';
import 'package:mentorloop_new/utils/responsive.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';

class ExamAddQuestionsScreen extends StatefulWidget {
  final String examId;
  const ExamAddQuestionsScreen({super.key, required this.examId});

  @override
  State<ExamAddQuestionsScreen> createState() => _ExamAddQuestionsScreenState();
}

class _ExamAddQuestionsScreenState extends State<ExamAddQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _question = TextEditingController();
  final _option1 = TextEditingController();
  final _option2 = TextEditingController();
  final _option3 = TextEditingController();
  final _option4 = TextEditingController();
  final _points = TextEditingController(text: '1');
  int _correctIndex = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _question.dispose();
    _option1.dispose();
    _option2.dispose();
    _option3.dispose();
    _option4.dispose();
    _points.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final points = int.tryParse(_points.text.trim()) ?? 1;
      final q = ExamQuestion(
        id: '',
        examId: widget.examId,
        question: _question.text.trim(),
        options: [
          _option1.text.trim(),
          _option2.text.trim(),
          _option3.text.trim(),
          _option4.text.trim(),
        ],
        correctIndex: _correctIndex,
        points: points,
      );
      await DataService.addExamQuestion(q);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question added')),
      );
      _question.clear();
      _option1.clear();
      _option2.clear();
      _option3.clear();
      _option4.clear();
      _points.clear();
      setState(() => _correctIndex = 0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
          'Add Exam Questions',
          style: TextStyle(color: Color(0xFF8B5E3C)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePaddingAll(context),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _question,
                  maxLines: 3,
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                TextFormField(
                  controller: _option1,
                  decoration: InputDecoration(
                    labelText: 'Option 1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                TextFormField(
                  controller: _option2,
                  decoration: InputDecoration(
                    labelText: 'Option 2',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                TextFormField(
                  controller: _option3,
                  decoration: InputDecoration(
                    labelText: 'Option 3',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                TextFormField(
                  controller: _option4,
                  decoration: InputDecoration(
                    labelText: 'Option 4',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                TextFormField(
                  controller: _points,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Points',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                Text(
                  'Correct Answer:',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                RadioListTile<int>(
                  title: const Text('Option 1'),
                  value: 0,
                  groupValue: _correctIndex,
                  onChanged: (v) => setState(() => _correctIndex = v!),
                ),
                RadioListTile<int>(
                  title: const Text('Option 2'),
                  value: 1,
                  groupValue: _correctIndex,
                  onChanged: (v) => setState(() => _correctIndex = v!),
                ),
                RadioListTile<int>(
                  title: const Text('Option 3'),
                  value: 2,
                  groupValue: _correctIndex,
                  onChanged: (v) => setState(() => _correctIndex = v!),
                ),
                RadioListTile<int>(
                  title: const Text('Option 4'),
                  value: 3,
                  groupValue: _correctIndex,
                  onChanged: (v) => setState(() => _correctIndex = v!),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
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
                        ? SizedBox(
                            height: ResponsiveHelper.getResponsiveIconSize(context),
                            width: ResponsiveHelper.getResponsiveIconSize(context),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Add Question',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

