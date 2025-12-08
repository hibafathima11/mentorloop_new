import 'package:flutter/material.dart';
import 'package:mentorloop_new/web/widgets/admin_layout.dart';
import 'package:mentorloop_new/utils/data_service.dart';
import 'package:mentorloop_new/models/entities.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExamsManagementScreen extends StatefulWidget {
  const ExamsManagementScreen({super.key});

  @override
  State<ExamsManagementScreen> createState() => _ExamsManagementScreenState();
}

class _ExamsManagementScreenState extends State<ExamsManagementScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController(text: '60');
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCourseId;
  bool _creating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) _startDate = picked;
      else _endDate = picked;
    });
  }

  Future<void> _createExam() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_titleController.text.trim().isEmpty || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide title and course')),
      );
      return;
    }
    setState(() => _creating = true);
    try {
      final exam = Exam(
        id: '',
        courseId: _selectedCourseId!,
        teacherId: user.uid,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        durationMinutes: int.tryParse(_durationController.text) ?? 60,
        startDate: _startDate != null ? _startDate as dynamic : DateTime.now() as dynamic,
        endDate: _endDate != null ? _endDate as dynamic : DateTime.now().add(const Duration(days: 7)) as dynamic,
      );
      final id = await DataService.createExam(exam);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exam created')),
      );
      setState(() {
        _titleController.clear();
        _descController.clear();
        _durationController.text = '60';
        _startDate = null;
        _endDate = null;
      });

      // Open questions editor for new exam
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExamQuestionsScreen(examId: id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating exam: $e')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return AdminLayout(
      title: 'Exams',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Exam',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(
                width: 400,
                child: TextField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration (minutes)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  onPressed: () => _pickDate(context, true),
                  child: Text(_startDate == null ? 'Pick start date' : _startDate!.toLocal().toString().split(' ')[0]),
                ),
              ),
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  onPressed: () => _pickDate(context, false),
                  child: Text(_endDate == null ? 'Pick end date' : _endDate!.toLocal().toString().split(' ')[0]),
                ),
              ),
              SizedBox(
                width: 300,
                child: StreamBuilder<List<Course>>(
                  stream: DataService.watchTeacherCourses(user.uid),
                  builder: (context, snap) {
                    final courses = snap.data ?? const <Course>[];
                    return DropdownButtonFormField<String>(
                      value: _selectedCourseId,
                      items: courses
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.title)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCourseId = v),
                      decoration: InputDecoration(
                        labelText: 'Select Course',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _creating ? null : _createExam,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5E3C)),
                  child: _creating ? const CircularProgressIndicator() : const Text('Create Exam'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Your Exams',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Exam>>(
            stream: DataService.watchTeacherExams(user.uid),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              final exams = snap.data ?? const <Exam>[];
              if (exams.isEmpty) return const Text('No exams created yet');
              return Column(
                children: exams.map((exam) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(exam.title),
                      subtitle: Text(exam.description),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExamQuestionsScreen(examId: exam.id),
                                ),
                              );
                            },
                            child: const Text('Questions'),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Exam'),
                                  content: const Text('Delete this exam and its questions?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await DataService.deleteExam(exam.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exam deleted')));
                              }
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ExamQuestionsScreen extends StatefulWidget {
  final String examId;
  const ExamQuestionsScreen({super.key, required this.examId});

  @override
  State<ExamQuestionsScreen> createState() => _ExamQuestionsScreenState();
}

class _ExamQuestionsScreenState extends State<ExamQuestionsScreen> {
  final _questionController = TextEditingController();
  final _pointsController = TextEditingController(text: '1');
  final List<TextEditingController> _optionControllers = [];
  String _type = 'mcq'; // mcq | short
  int _correctIndex = 0;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _ensureOptionControllers(4);
  }

  void _ensureOptionControllers(int n) {
    while (_optionControllers.length < n) {
      _optionControllers.add(TextEditingController());
    }
    while (_optionControllers.length > n) {
      _optionControllers.removeLast().dispose();
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _pointsController.dispose();
    for (final c in _optionControllers) c.dispose();
    super.dispose();
  }

  Future<void> _addQuestion() async {
    if (_questionController.text.trim().isEmpty) return;
    setState(() => _adding = true);
    try {
      final options = _type == 'mcq'
          ? _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList()
          : <String>[];
      final q = ExamQuestion(
        id: '',
        examId: widget.examId,
        question: _questionController.text.trim(),
        options: options,
        correctIndex: _type == 'mcq' ? _correctIndex : -1,
        points: int.tryParse(_pointsController.text) ?? 1,
      );
      await DataService.addExamQuestion(q);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question added')));
      _questionController.clear();
      _pointsController.text = '1';
      for (final c in _optionControllers) c.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Questions')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: 'mcq', child: Text('MCQ')),
                    DropdownMenuItem(value: 'short', child: Text('Short Answer')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _type = v;
                      if (_type == 'mcq') _ensureOptionControllers(4);
                    });
                  },
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Points'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Question', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            if (_type == 'mcq')
              Column(
                children: _optionControllers.asMap().entries.map((e) {
                  final i = e.key;
                  final c = e.value;
                  return Row(
                    children: [
                      Radio<int>(
                        value: i,
                        groupValue: _correctIndex,
                        onChanged: (v) => setState(() => _correctIndex = v ?? 0),
                      ),
                      Expanded(
                        child: TextField(
                          controller: c,
                          decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _adding ? null : _addQuestion,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5E3C)),
                child: _adding ? const CircularProgressIndicator() : const Text('Add Question'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Existing Questions', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<ExamQuestion>>( 
                stream: DataService.watchExamQuestions(widget.examId),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  final qs = snap.data ?? const <ExamQuestion>[];
                  if (qs.isEmpty) return const Center(child: Text('No questions yet'));
                  return ListView.builder(
                    itemCount: qs.length,
                    itemBuilder: (context, index) {
                      final q = qs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(q.question),
                          subtitle: q.options.isEmpty ? const Text('Short answer') : Text('MCQ - ${q.options.length} options'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final conf = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Question'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
                                  ],
                                ),
                              );
                              if (conf == true) {
                                await DataService.deleteExamQuestion(q.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Question deleted')));
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
