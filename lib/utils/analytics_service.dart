// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  AnalyticsService._();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<int> totalAssignmentsForCourse(String courseId) async {
    final qs = await _db
        .collection('assignments')
        .where('courseId', isEqualTo: courseId)
        .get();
    return qs.size;
  }

  static Future<double> averageScoreForAssignment(String assignmentId) async {
    final qs = await _db
        .collection('submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .get();
    if (qs.docs.isEmpty) return 0;
    double sum = 0;
    int count = 0;
    for (final d in qs.docs) {
      final v = d.data()['score'];
      if (v is num) {
        sum += v.toDouble();
        count += 1;
      }
    }
    return count == 0 ? 0 : sum / count;
  }

  static Future<double> studentAssessmentAccuracy(String studentId) async {
    final qs = await _db
        .collection('video_assessments')
        .where('studentId', isEqualTo: studentId)
        .get();
    if (qs.docs.isEmpty) return 0;
    int correct = 0;
    int total = 0;
    for (final d in qs.docs) {
      final m = d.data();
      final c = (m['correctAnswers'] as num?)?.toInt() ?? 0;
      final t = (m['totalQuestions'] as num?)?.toInt() ?? 0;
      correct += c;
      total += t;
    }
    return total == 0 ? 0 : correct / total;
  }

  /// Returns list of {id, title} for assignments in the course.
  static Future<List<Map<String, String>>> getAssignmentsForCourse(
    String courseId,
  ) async {
    final qs = await _db
        .collection('assignments')
        .where('courseId', isEqualTo: courseId)
        .get();
    return qs.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'title': (data['title'] as String?) ?? 'Untitled',
      };
    }).toList();
  }

  /// Returns student IDs enrolled in the course.
  static Future<List<String>> getCourseStudentIds(String courseId) async {
    final doc = await _db.collection('courses').doc(courseId).get();
    if (!doc.exists) return [];
    final data = doc.data();
    final list = data?['studentIds'] as List<dynamic>?;
    return list?.map((e) => e.toString()).toList() ?? [];
  }

  /// Returns display name for a user (name or email).
  static Future<String> getUserDisplayName(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return uid;
    final data = doc.data();
    final name = (data?['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = (data?['email'] as String?)?.trim();
    return email ?? uid;
  }
}
