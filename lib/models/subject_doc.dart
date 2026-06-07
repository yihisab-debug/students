import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectDoc {
  final String id;
  final String name;
  final String group;
  final String teacher;
  final String teacherEmail;
  final int semester;

  SubjectDoc({
    required this.id,
    required this.name,
    required this.group,
    required this.teacher,
    required this.teacherEmail,
    required this.semester,
  });

  factory SubjectDoc.fromMap(String id, Map<String, dynamic> m) => SubjectDoc(
        id: id,
        name: (m['name'] ?? '') as String,
        group: (m['group'] ?? '') as String,
        teacher: (m['teacher'] ?? '') as String,
        teacherEmail: (m['teacherEmail'] ?? '') as String,
        semester: (m['semester'] as num?)?.toInt() ?? 7,
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'group': group,
        'teacher': teacher,
        'teacherEmail': teacherEmail,
        'semester': semester,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
