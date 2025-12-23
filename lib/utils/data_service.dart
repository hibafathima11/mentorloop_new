import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorloop_new/models/entities.dart' hide Timestamp;

class DataService {
  DataService._();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Users
  static Future<UserProfile?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.id, doc.data()!);
  }

  static Stream<List<UserProfile>> streamTeachers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => UserProfile.fromMap(d.id, d.data())).toList(),
        );
  }

  static Stream<List<UserProfile>> streamStudents() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => UserProfile.fromMap(d.id, d.data())).toList(),
        );
  }

  static Future<String?> getLinkedStudentId(String parentId) async {
    final doc = await _db.collection('parent_links').doc(parentId).get();
    if (!doc.exists) return null;
    return doc.data()!['studentId'] as String?;
  }

  static Future<void> setParentStudentLink({
    required String parentId,
    required String studentId,
  }) async {
    await _db.collection('parent_links').doc(parentId).set({
      'parentId': parentId,
      'studentId': studentId,
      'linkedAt': FieldValue.serverTimestamp(),
    });
  }

  // Courses
  static Future<String> createCourse(Course course) async {
    final ref = await _db.collection('courses').add(course.toMap());
    return ref.id;
  }

  static Stream<List<Course>> watchTeacherCourses(String teacherId) {
    return _db
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((s) => s.docs.map((d) => Course.fromMap(d.id, d.data())).toList());
  }

  static Stream<List<Course>> watchAllCourses() {
    return _db
        .collection('courses')
        .snapshots()
        .map((s) => s.docs.map((d) => Course.fromMap(d.id, d.data())).toList());
  }

  static Stream<List<Course>> watchStudentCourses(String studentId) {
    return _db
        .collection('courses')
        .where('studentIds', arrayContains: studentId)
        .snapshots()
        .map((s) => s.docs.map((d) => Course.fromMap(d.id, d.data())).toList());
  }

  // Study materials
  static Future<String> addMaterial(StudyMaterial material) async {
    final ref = await _db.collection('materials').add(material.toMap());
    return ref.id;
  }

  static Stream<List<StudyMaterial>> watchCourseMaterials(String courseId) {
    return _db
        .collection('materials')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => StudyMaterial.fromMap(d.id, d.data())).toList(),
        );
  }

  // Videos and questions
  static Future<String> addVideo(CourseVideo video) async {
    final ref = await _db.collection('videos').add(video.toMap());
    return ref.id;
  }

  static Stream<List<CourseVideo>> watchCourseVideos(String courseId) {
    return _db
        .collection('videos')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => CourseVideo.fromMap(d.id, d.data())).toList(),
        );
  }

  static Stream<List<CourseVideo>> watchTeacherVideos(String teacherId) {
    return _db
        .collection('videos')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => CourseVideo.fromMap(d.id, d.data())).toList(),
        );
  }

  static Future<String> addVideoQuestion(VideoQuestion q) async {
    final ref = await _db.collection('video_questions').add(q.toMap());
    return ref.id;
  }

  static Stream<List<VideoQuestion>> watchVideoQuestions(String videoId) {
    return _db
        .collection('video_questions')
        .where('videoId', isEqualTo: videoId)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => VideoQuestion.fromMap(d.id, d.data())).toList(),
        );
  }

  // Student answers during video
  static Future<void> saveVideoAnswer({
    required String videoId,
    required String questionId,
    required String studentId,
    required int selectedIndex,
    required bool isCorrect,
  }) async {
    await _db.collection('video_answers').add({
      'videoId': videoId,
      'questionId': questionId,
      'studentId': studentId,
      'selectedIndex': selectedIndex,
      'isCorrect': isCorrect,
      'answeredAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> saveVideoAssessmentResult({
    required String videoId,
    required String studentId,
    required int totalQuestions,
    required int correctAnswers,
    required int totalDurationSeconds,
  }) async {
    await _db.collection('video_assessments').add({
      'videoId': videoId,
      'studentId': studentId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'totalDurationSeconds': totalDurationSeconds,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<List<Map<String, dynamic>>> watchStudentAssessmentsToday(
    String studentId,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _db
        .collection('video_assessments')
        .where('studentId', isEqualTo: studentId)
        .where('completedAt', isGreaterThanOrEqualTo: todayStart)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  // Assignments
  static Future<String> createAssignment(Assignment a) async {
    final ref = await _db.collection('assignments').add(a.toMap());
    return ref.id;
  }

  static Stream<List<Assignment>> watchCourseAssignments(String courseId) {
    return _db
        .collection('assignments')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Assignment.fromMap(d.id, d.data())).toList(),
        );
  }

  static Future<String> submitAssignment(Submission s) async {
    final ref = await _db.collection('submissions').add(s.toMap());
    return ref.id;
  }

  static Stream<List<Submission>> watchAssignmentSubmissions(
    String assignmentId,
  ) {
    return _db
        .collection('submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .snapshots()
        .map(
          (s) => s.docs.map((d) => Submission.fromMap(d.id, d.data())).toList(),
        );
  }

  static Future<void> assignStudentToCourse(
    String courseId,
    String studentId,
  ) async {
    final ref = _db.collection('courses').doc(courseId);
    await ref.update({
      'studentIds': FieldValue.arrayUnion([studentId]),
    });
  }

  // Doubts / complaints
  static Future<String> createDoubtThread(DoubtThread t) async {
    final ref = await _db.collection('doubts').add(t.toMap());
    return ref.id;
  }

  static Stream<List<DoubtThread>> watchCourseDoubts(String courseId) {
    return _db
        .collection('doubts')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => DoubtThread.fromMap(d.id, d.data())).toList(),
        );
  }

  static Future<String> addDoubtMessage(DoubtMessage m) async {
    final ref = await _db.collection('doubt_messages').add(m.toMap());
    return ref.id;
  }

  static Stream<List<DoubtMessage>> watchDoubtMessages(String threadId) {
    return _db
        .collection('doubt_messages')
        .where('threadId', isEqualTo: threadId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => DoubtMessage.fromMap(d.id, d.data())).toList(),
        );
  }

  // Parent feedback
  static Future<String> sendParentFeedback(ParentFeedback f) async {
    final ref = await _db.collection('parent_feedback').add(f.toMap());
    return ref.id;
  }

  static Stream<List<ParentFeedback>> watchParentFeedbackForTeacher(
    String teacherId,
  ) {
    return _db
        .collection('parent_feedback')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => ParentFeedback.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  // Attendance
  static Future<String> addAttendance(AttendanceRecord r) async {
    final ref = await _db.collection('attendance').add(r.toMap());
    return ref.id;
  }

  static Stream<List<AttendanceRecord>> watchStudentAttendance(
    String studentId,
  ) {
    return _db
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => AttendanceRecord.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  // Chat
  static Future<String> createOrGetOneToOneThread({
    required String userA,
    required String userB,
    String title = '',
  }) async {
    final members = [userA, userB]..sort();
    final q = await _db
        .collection('chat_threads')
        .where('memberIds', arrayContains: members.first)
        .get();
    for (final d in q.docs) {
      final data = d.data();
      final ids = List<String>.from((data['memberIds'] as List?) ?? const []);
      ids.sort();
      if (ids.length == 2 && ids[0] == members[0] && ids[1] == members[1]) {
        return d.id;
      }
    }
    final ref = await _db.collection('chat_threads').add({
      'memberIds': members,
      'title': title,
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Stream<List<ChatThread>> watchMyThreads(String uid) {
    return _db
        .collection('chat_threads')
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => ChatThread.fromMap(d.id, d.data()))
              .where((t) => t.memberIds.contains(uid))
              .toList(),
        );
  }

  static Stream<List<ChatMessage>> watchThreadMessages(String threadId) {
    return _db
        .collection('chat_messages')
        .where('threadId', isEqualTo: threadId)
        .orderBy('createdAt')
        .snapshots()
        .map(
          (s) => s.docs
              .map((d) => ChatMessage.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  static Future<String> sendChatMessage({
    required String threadId,
    required String senderId,
    required String text,
  }) async {
    final batch = _db.batch();
    final msgRef = _db.collection('chat_messages').doc();
    batch.set(msgRef, {
      'threadId': threadId,
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('chat_threads').doc(threadId), {
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return msgRef.id;
  }

  // Unread tracking using per-user read timestamps
  static Stream<int> watchUnreadCountForThread({
    required String threadId,
    required String uid,
  }) {
    final readsDoc = _db
        .collection('chat_thread_reads')
        .doc('${threadId}__${uid}');

    return readsDoc.snapshots().asyncMap((readSnap) async {
      final lastReadData = readSnap.data()?['lastReadAt'];
      final lastRead = lastReadData;
      final allMsgs = await _db.collection('chat_messages').get();
      final msgs = allMsgs.docs
          .map((d) => ChatMessage.fromMap(d.id, d.data()))
          .where((m) => m.threadId == threadId)
          .toList();

      if (lastRead != null && lastReadData != null) {
        final filtered = msgs.where((m) {
          if (m.createdAt == null) return false;
          final mTime = m.createdAt;
          final lTime = lastRead;
          if (mTime == null || lTime == null) return false;
          // Compare timestamps
          try {
            final mMillis = (mTime as dynamic).millisecondsSinceEpoch ?? 0;
            final lMillis = (lTime as dynamic).millisecondsSinceEpoch ?? 0;
            return mMillis > lMillis;
          } catch (e) {
            return false;
          }
        }).toList();
        final count = filtered.where((m) => m.senderId != uid).length;
        return count;
      }
      final count = msgs.where((m) => m.senderId != uid).length;
      return count;
    });
  }

  static Future<void> markThreadRead({
    required String threadId,
    required String uid,
  }) async {
    await _db.collection('chat_thread_reads').doc('${threadId}__${uid}').set({
      'lastReadAt': FieldValue.serverTimestamp(),
    });
  }

  // Exams
  static Future<String> createExam(Exam exam) async {
    final ref = await _db.collection('exams').add(exam.toMap());
    return ref.id;
  }

  static Stream<List<Exam>> watchTeacherExams(String teacherId) {
    return _db
        .collection('exams')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((s) => s.docs.map((d) => Exam.fromMap(d.id, d.data())).toList());
  }

  static Stream<List<Exam>> watchCourseExams(String courseId) {
    return _db
        .collection('exams')
        .where('courseId', isEqualTo: courseId)
        .snapshots()
        .map((s) => s.docs.map((d) => Exam.fromMap(d.id, d.data())).toList());
  }

  static Stream<List<Exam>> watchAllExams() {
    return _db
        .collection('exams')
        .snapshots()
        .map((s) => s.docs.map((d) => Exam.fromMap(d.id, d.data())).toList());
  }

  static Future<Exam?> getExam(String examId) async {
    final doc = await _db.collection('exams').doc(examId).get();
    if (!doc.exists) return null;
    return Exam.fromMap(doc.id, doc.data()!);
  }

  // Exam Questions
  static Future<String> addExamQuestion(ExamQuestion question) async {
    final ref = await _db.collection('exam_questions').add(question.toMap());
    return ref.id;
  }

  static Stream<List<ExamQuestion>> watchExamQuestions(String examId) {
    return _db
        .collection('exam_questions')
        .where('examId', isEqualTo: examId)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => ExamQuestion.fromMap(d.id, d.data())).toList(),
        );
  }

  // Exam Attempts
  static Future<String> createExamAttempt(ExamAttempt attempt) async {
    final ref = await _db.collection('exam_attempts').add(attempt.toMap());
    return ref.id;
  }

  static Future<void> updateExamAttempt(
    String attemptId,
    ExamAttempt attempt,
  ) async {
    await _db
        .collection('exam_attempts')
        .doc(attemptId)
        .update(attempt.toMap());
  }

  static Stream<List<ExamAttempt>> watchStudentExamAttempts(String studentId) {
    return _db
        .collection('exam_attempts')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => ExamAttempt.fromMap(d.id, d.data())).toList(),
        );
  }

  static Future<ExamAttempt?> getExamAttempt(String attemptId) async {
    final doc = await _db.collection('exam_attempts').doc(attemptId).get();
    if (!doc.exists) return null;
    return ExamAttempt.fromMap(doc.id, doc.data()!);
  }

  static Stream<List<ExamAttempt>> watchExamAttempts(String examId) {
    return _db
        .collection('exam_attempts')
        .where('examId', isEqualTo: examId)
        .snapshots()
        .map(
          (s) =>
              s.docs.map((d) => ExamAttempt.fromMap(d.id, d.data())).toList(),
        );
  }

  static Future<ExamAttempt?> getStudentExamAttempt(
    String examId,
    String studentId,
  ) async {
    final q = await _db
        .collection('exam_attempts')
        .where('examId', isEqualTo: examId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return ExamAttempt.fromMap(q.docs.first.id, q.docs.first.data());
  }

  // DELETE Operations
  static Future<void> deleteCourse(String courseId) async {
    await _db.collection('courses').doc(courseId).delete();
  }

  static Future<void> deleteMaterial(String materialId) async {
    await _db.collection('materials').doc(materialId).delete();
  }

  static Future<void> deleteVideo(String videoId) async {
    await _db.collection('videos').doc(videoId).delete();
  }

  static Future<void> deleteVideoQuestion(String questionId) async {
    await _db.collection('video_questions').doc(questionId).delete();
  }

  static Future<void> deleteAssignment(String assignmentId) async {
    await _db.collection('assignments').doc(assignmentId).delete();
  }

  static Future<void> deleteSubmission(String submissionId) async {
    await _db.collection('submissions').doc(submissionId).delete();
  }

  static Future<void> deleteExam(String examId) async {
    await _db.collection('exams').doc(examId).delete();
  }

  static Future<void> deleteExamQuestion(String questionId) async {
    await _db.collection('exam_questions').doc(questionId).delete();
  }

  static Future<void> deleteDoubtThread(String threadId) async {
    await _db.collection('doubts').doc(threadId).delete();
  }

  static Future<void> deleteDoubtMessage(String messageId) async {
    await _db.collection('doubt_messages').doc(messageId).delete();
  }

  // UPDATE Operations (additional)
  static Future<void> updateCourse(String courseId, Course course) async {
    await _db.collection('courses').doc(courseId).update(course.toMap());
  }

  static Future<void> updateMaterial(
    String materialId,
    StudyMaterial material,
  ) async {
    await _db.collection('materials').doc(materialId).update(material.toMap());
  }

  static Future<void> updateVideo(String videoId, CourseVideo video) async {
    await _db.collection('videos').doc(videoId).update(video.toMap());
  }

  static Future<void> updateAssignment(
    String assignmentId,
    Assignment assignment,
  ) async {
    await _db
        .collection('assignments')
        .doc(assignmentId)
        .update(assignment.toMap());
  }

  static Future<void> updateExam(String examId, Exam exam) async {
    await _db.collection('exams').doc(examId).update(exam.toMap());
  }

  static Future<void> updateSubmission(
    String submissionId,
    Submission submission,
  ) async {
    await _db
        .collection('submissions')
        .doc(submissionId)
        .update(submission.toMap());
  }

  static Future<void> removeStudentFromCourse(
    String courseId,
    String studentId,
  ) async {
    final ref = _db.collection('courses').doc(courseId);
    await ref.update({
      'studentIds': FieldValue.arrayRemove([studentId]),
    });
  }
}
