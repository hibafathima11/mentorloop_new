// ignore_for_file: uri_does_not_exist, undefined_class, undefined_identifier
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;

// Provide a local alias so analyzer doesn't error when Firestore types
// aren't available in analysis context.
typedef Timestamp = dynamic;

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // student | teacher | parent | admin
  final bool approved;
  final Timestamp? createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.approved,
    this.createdAt,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: (map['name'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'student',
      approved: (map['approved'] as bool?) ?? false,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'approved': approved,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String teacherId;
  final List<String> studentIds;
  final Timestamp? createdAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherId,
    required this.studentIds,
    this.createdAt,
  });

  factory Course.fromMap(String id, Map<String, dynamic> map) {
    return Course(
      id: id,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      studentIds: List<String>.from((map['studentIds'] as List?) ?? const []),
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'teacherId': teacherId,
      'studentIds': studentIds,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class StudyMaterial {
  final String id;
  final String courseId;
  final String teacherId;
  final String title;
  final String type; // pdf | doc | link
  final String url;
  final Timestamp? createdAt;

  StudyMaterial({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.title,
    required this.type,
    required this.url,
    this.createdAt,
  });

  factory StudyMaterial.fromMap(String id, Map<String, dynamic> map) {
    return StudyMaterial(
      id: id,
      courseId: (map['courseId'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'link',
      url: (map['url'] as String?) ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'teacherId': teacherId,
      'title': title,
      'type': type,
      'url': url,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class CourseVideo {
  final String id;
  final String courseId;
  final String teacherId;
  final String title;
  final String url;
  final int durationSeconds;
  final Timestamp? createdAt;

  CourseVideo({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.title,
    required this.url,
    required this.durationSeconds,
    this.createdAt,
  });

  factory CourseVideo.fromMap(String id, Map<String, dynamic> map) {
    return CourseVideo(
      id: id,
      courseId: (map['courseId'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      url: (map['url'] as String?) ?? '',
      durationSeconds: (map['durationSeconds'] as int?) ?? 0,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'teacherId': teacherId,
      'title': title,
      'url': url,
      'durationSeconds': durationSeconds,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class VideoQuestion {
  final String id;
  final String videoId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int showAtSecond;

  VideoQuestion({
    required this.id,
    required this.videoId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.showAtSecond,
  });

  factory VideoQuestion.fromMap(String id, Map<String, dynamic> map) {
    return VideoQuestion(
      id: id,
      videoId: (map['videoId'] as String?) ?? '',
      question: (map['question'] as String?) ?? '',
      options: List<String>.from((map['options'] as List?) ?? const []),
      correctIndex: (map['correctIndex'] as int?) ?? 0,
      showAtSecond: (map['showAtSecond'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoId': videoId,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'showAtSecond': showAtSecond,
    };
  }
}

class Assignment {
  final String id;
  final String courseId;
  final String teacherId;
  final String title;
  final String description;
  final Timestamp dueAt;
  final Timestamp? createdAt;

  Assignment({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.dueAt,
    this.createdAt,
  });

  factory Assignment.fromMap(String id, Map<String, dynamic> map) {
    return Assignment(
      id: id,
      courseId: (map['courseId'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      dueAt: (map['dueAt'] as Timestamp?) ?? map['dueAt'],
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'dueAt': dueAt,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class Submission {
  final String id;
  final String assignmentId;
  final String studentId;
  final String attachmentUrl;
  final String status; // submitted | graded
  final double? score;
  final String? feedback;
  final Timestamp? submittedAt;

  Submission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.attachmentUrl,
    required this.status,
    this.score,
    this.feedback,
    this.submittedAt,
  });

  factory Submission.fromMap(String id, Map<String, dynamic> map) {
    return Submission(
      id: id,
      assignmentId: (map['assignmentId'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      attachmentUrl: (map['attachmentUrl'] as String?) ?? '',
      status: (map['status'] as String?) ?? 'submitted',
      score: (map['score'] as num?)?.toDouble(),
      feedback: map['feedback'] as String?,
      submittedAt: map['submittedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'attachmentUrl': attachmentUrl,
      'status': status,
      'score': score,
      'feedback': feedback,
      'submittedAt': submittedAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class DoubtThread {
  final String id;
  final String courseId;
  final String createdBy;
  final String title;
  final Timestamp? createdAt;

  DoubtThread({
    required this.id,
    required this.courseId,
    required this.createdBy,
    required this.title,
    this.createdAt,
  });

  factory DoubtThread.fromMap(String id, Map<String, dynamic> map) {
    return DoubtThread(
      id: id,
      courseId: (map['courseId'] as String?) ?? '',
      createdBy: (map['createdBy'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'createdBy': createdBy,
      'title': title,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class DoubtMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String text;
  final Timestamp? createdAt;

  DoubtMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.text,
    this.createdAt,
  });

  factory DoubtMessage.fromMap(String id, Map<String, dynamic> map) {
    return DoubtMessage(
      id: id,
      threadId: (map['threadId'] as String?) ?? '',
      senderId: (map['senderId'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'threadId': threadId,
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class ParentFeedback {
  final String id;
  final String parentId;
  final String studentId;
  final String teacherId;
  final String message;
  final Timestamp? createdAt;

  ParentFeedback({
    required this.id,
    required this.parentId,
    required this.studentId,
    required this.teacherId,
    required this.message,
    this.createdAt,
  });

  factory ParentFeedback.fromMap(String id, Map<String, dynamic> map) {
    return ParentFeedback(
      id: id,
      parentId: (map['parentId'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      message: (map['message'] as String?) ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'studentId': studentId,
      'teacherId': teacherId,
      'message': message,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class AttendanceRecord {
  final String id;
  final String studentId;
  final String courseId;
  final bool present;
  final Timestamp date;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.present,
    required this.date,
  });

  factory AttendanceRecord.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceRecord(
      id: id,
      studentId: (map['studentId'] as String?) ?? '',
      courseId: (map['courseId'] as String?) ?? '',
      present: (map['present'] as bool?) ?? false,
      date: (map['date'] as Timestamp?) ?? map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'present': present,
      'date': date,
    };
  }
}

class ChatThread {
  final String id;
  final List<String> memberIds; // e.g., [adminUid, teacherUid]
  final String title; // optional display title
  final Timestamp? lastMessageAt;

  ChatThread({
    required this.id,
    required this.memberIds,
    required this.title,
    this.lastMessageAt,
  });

  factory ChatThread.fromMap(String id, Map<String, dynamic> map) {
    return ChatThread(
      id: id,
      memberIds: List<String>.from((map['memberIds'] as List?) ?? const []),
      title: (map['title'] as String?) ?? '',
      lastMessageAt: map['lastMessageAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberIds': memberIds,
      'title': title,
      'lastMessageAt': lastMessageAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class ChatMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String text;
  final Timestamp? createdAt;

  ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.text,
    this.createdAt,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> map) {
    return ChatMessage(
      id: id,
      threadId: (map['threadId'] as String?) ?? '',
      senderId: (map['senderId'] as String?) ?? '',
      text: (map['text'] as String?) ?? '',
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'threadId': threadId,
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class Exam {
  final String id;
  final String courseId;
  final String teacherId;
  final String title;
  final String description;
  final int durationMinutes;
  final Timestamp startDate;
  final Timestamp endDate;
  final Timestamp? createdAt;

  Exam({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.startDate,
    required this.endDate,
    this.createdAt,
  });

  factory Exam.fromMap(String id, Map<String, dynamic> map) {
    // Handle Timestamp conversion safely
    dynamic startDateValue = map['startDate'];
    dynamic endDateValue = map['endDate'];

    Timestamp startDate;
    Timestamp endDate;

    if (startDateValue == null) {
      startDate =
          cloud_firestore.Timestamp.fromDate(DateTime.now()) as Timestamp;
    } else {
      startDate = startDateValue as Timestamp;
    }

    if (endDateValue == null) {
      endDate = cloud_firestore.Timestamp.fromDate(DateTime.now()) as Timestamp;
    } else {
      endDate = endDateValue as Timestamp;
    }

    return Exam(
      id: id,
      courseId: (map['courseId'] as String?) ?? '',
      teacherId: (map['teacherId'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      durationMinutes: (map['durationMinutes'] as int?) ?? 60,
      startDate: startDate,
      endDate: endDate,
      createdAt: map['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'durationMinutes': durationMinutes,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class ExamQuestion {
  final String id;
  final String examId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final int points;

  ExamQuestion({
    required this.id,
    required this.examId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.points,
  });

  factory ExamQuestion.fromMap(String id, Map<String, dynamic> map) {
    return ExamQuestion(
      id: id,
      examId: (map['examId'] as String?) ?? '',
      question: (map['question'] as String?) ?? '',
      options: List<String>.from((map['options'] as List?) ?? const []),
      correctIndex: (map['correctIndex'] as int?) ?? 0,
      points: (map['points'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'points': points,
    };
  }
}

class ExamAttempt {
  final String id;
  final String examId;
  final String studentId;
  final Map<String, int> answers; // questionId -> selectedOptionIndex
  final int score;
  final int totalPoints;
  final Timestamp? startedAt;
  final Timestamp? submittedAt;

  ExamAttempt({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.answers,
    required this.score,
    required this.totalPoints,
    this.startedAt,
    this.submittedAt,
  });

  factory ExamAttempt.fromMap(String id, Map<String, dynamic> map) {
    final answersMap = map['answers'] as Map?;
    return ExamAttempt(
      id: id,
      examId: (map['examId'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      answers: answersMap != null
          ? Map<String, int>.from(
              answersMap.map((k, v) => MapEntry(k.toString(), v as int)),
            )
          : {},
      score: (map['score'] as int?) ?? 0,
      totalPoints: (map['totalPoints'] as int?) ?? 0,
      startedAt: map['startedAt'] as Timestamp?,
      submittedAt: map['submittedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'studentId': studentId,
      'answers': answers,
      'score': score,
      'totalPoints': totalPoints,
      'startedAt': startedAt ?? FieldValue.serverTimestamp(),
      'submittedAt': submittedAt ?? FieldValue.serverTimestamp(),
    };
  }
}
