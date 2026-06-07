import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/app_user.dart';
import '../models/grade.dart';
import '../models/subject.dart';
import '../models/subject_doc.dart';
import '../models/submission.dart';

class StudentData {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Subject>> watchSubjects(AppUser user) {
    final subjectsStream = _db
        .collection('subjects')
        .where('group', isEqualTo: user.group)
        .snapshots();
    final submissionsStream = _db
        .collection('submissions')
        .where('studentEmail', isEqualTo: user.email)
        .snapshots();

    return _combine(subjectsStream, submissionsStream, (subjSnap, subSnap) {
      final subjects =
          subjSnap.docs.map((d) => SubjectDoc.fromMap(d.id, d.data())).toList();
      final submissions =
          subSnap.docs.map((d) => Submission.fromMap(d.id, d.data())).toList();

      final bySubject = <String, List<Submission>>{};
      for (final s in submissions) {
        bySubject.putIfAbsent(s.subjectId, () => <Submission>[]).add(s);
      }

      final result = subjects.map((sd) {
        final subs = (bySubject[sd.id] ?? <Submission>[])
          ..sort((a, b) => a.date.compareTo(b.date));
        final graded = subs.where((s) => s.isGraded).toList();
        final scores = graded.map((s) => s.score!).toList();
        final avg = scores.isEmpty
            ? 0.0
            : scores.reduce((a, b) => a + b) / scores.length;
        final finalGrade =
            double.parse((avg / 20).clamp(0.0, 5.0).toStringAsFixed(1));
        final hasPending = subs.any((s) => !s.isGraded);
        final status = (graded.isNotEmpty && !hasPending)
            ? SubjectStatus.passed
            : SubjectStatus.inProgress;

        return Subject(
          id: sd.id,
          name: sd.name,
          teacher: sd.teacher.isEmpty ? '—' : sd.teacher,
          semester: sd.semester,
          finalGrade: finalGrade,
          status: status,
          grades: [
            for (final s in graded)
              Grade(title: s.title, score: s.score, date: s.date),
          ],
          summary: [
            for (final s in graded.take(3))
              (label: _short(s.title), value: '${s.score}'),
          ],
          submissions: subs,
        );
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return result;
    });
  }

  Stream<List<Submission>> watchSubmissions(AppUser user, String subjectId) {
    return _db
        .collection('submissions')
        .where('studentEmail', isEqualTo: user.email)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Submission.fromMap(d.id, d.data()))
          .where((s) => s.subjectId == subjectId)
          .toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  Future<void> submitTask({
    required AppUser user,
    required Subject subject,
    required String title,
  }) async {
    final sub = Submission(
      id: '',
      subjectId: subject.id,
      subjectName: subject.name,
      group: user.group ?? '',
      studentEmail: user.email,
      studentName: user.name,
      title: title,
      status: SubStatus.submitted,
      score: null,
      date: DateTime.now(),
      teacher: subject.teacher,
    );
    await _db.collection('submissions').add(sub.toMap());
  }

  Stream<R> _combine<A, B, R>(
      Stream<A> a, Stream<B> b, R Function(A, B) f) {
    late StreamController<R> ctrl;
    A? lastA;
    B? lastB;
    var hasA = false, hasB = false;
    StreamSubscription<A>? sa;
    StreamSubscription<B>? sb;
    void emit() {
      if (hasA && hasB) ctrl.add(f(lastA as A, lastB as B));
    }

    ctrl = StreamController<R>(
      onListen: () {
        sa = a.listen((v) {
          lastA = v;
          hasA = true;
          emit();
        }, onError: ctrl.addError);
        sb = b.listen((v) {
          lastB = v;
          hasB = true;
          emit();
        }, onError: ctrl.addError);
      },
      onCancel: () async {
        await sa?.cancel();
        await sb?.cancel();
      },
    );
    return ctrl.stream;
  }
}

String _short(String title) {
  final t = title.toLowerCase();
  if (t.contains('лаборатор')) {
    final n = RegExp(r'\d+').firstMatch(title)?.group(0);
    return n != null ? 'Лаб. $n' : 'Лаб.';
  }
  if (t.contains('экзам')) return 'Экзамен';
  if (t.contains('тест')) return 'Тест';
  if (t.contains('курсов')) return 'Курсовая';
  if (t.contains('проект')) return 'Проект';
  return title.length > 12 ? '${title.substring(0, 12)}…' : title;
}
