import 'grade.dart';
import 'submission.dart';

enum SubjectStatus { passed, inProgress }

extension SubjectStatusLabel on SubjectStatus {
  String get label {
    switch (this) {
      case SubjectStatus.passed:
        return 'Зачтено';
      case SubjectStatus.inProgress:
        return 'В процессе';
    }
  }
}

class Subject {
  final String id;
  final String name;
  final String teacher;
  final int semester;

  final double finalGrade;
  final SubjectStatus status;
  final List<Grade> grades;

  final List<({String label, String value})> summary;

  final List<Submission> submissions;

  bool isFavorite;

  Subject({
    required this.id,
    required this.name,
    required this.teacher,
    required this.semester,
    required this.finalGrade,
    required this.status,
    required this.grades,
    required this.summary,
    this.submissions = const [],
    this.isFavorite = false,
  });

  bool get isCompleted => status == SubjectStatus.passed;

  int get pendingCount =>
      submissions.where((s) => !s.isGraded).length;
}

