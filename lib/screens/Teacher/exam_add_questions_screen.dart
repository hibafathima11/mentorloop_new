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
  String _questionType = 'mcq'; // 'mcq' or 'short'
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
        options: _questionType == 'mcq'
            ? [
                _option1.text.trim(),
                _option2.text.trim(),
                _option3.text.trim(),
                _option4.text.trim(),
              ]
            : [], // Empty options for short answer
        correctIndex: _questionType == 'mcq' ? _correctIndex : -1, // -1 for short answer
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Type Selection
                DropdownButtonFormField<String>(
                  value: _questionType,
                  decoration: InputDecoration(
                    labelText: 'Question Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getResponsiveCardRadius(context),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'mcq',
                      child: Text('Multiple Choice (MCQ)'),
                    ),
                    DropdownMenuItem(
                      value: 'short',
                      child: Text('Short Answer'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _questionType = value;
                        _correctIndex = 0;
                      });
                    }
                  },
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                // Question Text
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
                // MCQ Options (only show for MCQ type)
                if (_questionType == 'mcq') ...[
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
                  // Correct Answer Selection (only for MCQ)
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
                ] else ...[
                  // Short Answer Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Short answer questions will be manually graded by the teacher.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                // Points
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
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final points = int.tryParse(v);
                    if (points == null || points <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
                // Add Question Button
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
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context)),
                // Existing Questions List
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Existing Questions',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<ExamQuestion>>(
                  stream: DataService.watchExamQuestions(widget.examId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final questions = snapshot.data ?? [];
                    if (questions.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No questions added yet'),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(q.question),
                            subtitle: Text(
                              q.options.isEmpty
                                  ? 'Short Answer (${q.points} points)'
                                  : 'MCQ - ${q.options.length} options (${q.points} points)',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Delete Question'),
                                    content: const Text(
                                        'Are you sure you want to delete this question?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true && mounted) {
                                  try {
                                    await DataService.deleteExamQuestion(q.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Question deleted')),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
