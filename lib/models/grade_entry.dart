import 'package:cloud_firestore/cloud_firestore.dart';

class GradeEntry {
  final String? id;
  final String studentEmail;
  final String group;
  final String subject;
  final String title;
  final int score;
  final DateTime date;
  final String teacher;

  GradeEntry({
    this.id,
    required this.studentEmail,
    required this.group,
    required this.subject,
    required this.title,
    required this.score,
    required this.date,
    required this.teacher,
  });

  Map<String, dynamic> toMap() => {
        'studentEmail': studentEmail,
        'group': group,
        'subject': subject,
        'title': title,
        'score': score,
        'date': Timestamp.fromDate(date),
        'teacher': teacher,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory GradeEntry.fromMap(String id, Map<String, dynamic> m) => GradeEntry(
        id: id,
        studentEmail: (m['studentEmail'] ?? '') as String,
        group: (m['group'] ?? '') as String,
        subject: (m['subject'] ?? '') as String,
        title: (m['title'] ?? '') as String,
        score: (m['score'] as num?)?.toInt() ?? 0,
        date: m['date'] is Timestamp
            ? (m['date'] as Timestamp).toDate()
            : DateTime.now(),
        teacher: (m['teacher'] ?? '') as String,
      );
}
