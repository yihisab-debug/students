import 'package:cloud_firestore/cloud_firestore.dart';

class SubStatus {
  static const submitted = 'submitted';
  static const graded = 'graded';
}

class Submission {
  final String id;
  final String subjectId;
  final String subjectName;
  final String group;
  final String studentEmail;
  final String studentName;
  final String title;
  final String status;
  final int? score;
  final DateTime date;
  final String teacher;

  Submission({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.group,
    required this.studentEmail,
    required this.studentName,
    required this.title,
    required this.status,
    required this.score,
    required this.date,
    required this.teacher,
  });

  bool get isGraded => status == SubStatus.graded && score != null;

  factory Submission.fromMap(String id, Map<String, dynamic> m) => Submission(
        id: id,
        subjectId: (m['subjectId'] ?? '') as String,
        subjectName: (m['subjectName'] ?? '') as String,
        group: (m['group'] ?? '') as String,
        studentEmail: (m['studentEmail'] ?? '') as String,
        studentName: (m['studentName'] ?? '') as String,
        title: (m['title'] ?? '') as String,
        status: (m['status'] ?? SubStatus.submitted) as String,
        score: (m['score'] as num?)?.toInt(),
        date: m['date'] is Timestamp
            ? (m['date'] as Timestamp).toDate()
            : DateTime.now(),
        teacher: (m['teacher'] ?? '') as String,
      );

  Map<String, dynamic> toMap() => {
        'subjectId': subjectId,
        'subjectName': subjectName,
        'group': group,
        'studentEmail': studentEmail,
        'studentName': studentName,
        'title': title,
        'status': status,
        'score': score,
        'date': Timestamp.fromDate(date),
        'teacher': teacher,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
