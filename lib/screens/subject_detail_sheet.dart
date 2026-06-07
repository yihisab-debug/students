import 'package:flutter/material.dart';
import '../auth/app_user.dart';
import '../data/student_data.dart';
import '../models/subject.dart';
import '../models/submission.dart';
import '../theme/app_theme.dart';
import '../widgets/grade_badge.dart';

class SubjectDetailSheet extends StatelessWidget {
  final Subject subject;
  final StudentData data;
  final AppUser user;

  const SubjectDetailSheet({
    super.key,
    required this.subject,
    required this.data,
    required this.user,
  });

  static Future<void> show(
    BuildContext context, {
    required Subject subject,
    required StudentData data,
    required AppUser user,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          SubjectDetailSheet(subject: subject, data: data, user: user),
    );
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
  }

  Future<void> _submitTask(BuildContext context) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Сдать задание'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Название задания',
            hintText: 'напр. Лабораторная работа 3',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Отправить'),
          ),
        ],
      ),
    );
    if (title != null && title.isNotEmpty) {
      await data.submitTask(user: user, subject: subject, title: title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              _headerBar(context),
              Expanded(
                child: StreamBuilder<List<Submission>>(
                  stream: data.watchSubmissions(user, subject.id),
                  builder: (context, snap) {
                    final subs = snap.data ?? subject.submissions;
                    final graded = subs.where((s) => s.isGraded).toList();
                    final scores = graded.map((s) => s.score!).toList();
                    final avg = scores.isEmpty
                        ? 0.0
                        : scores.reduce((a, b) => a + b) / scores.length;
                    final finalGrade = double.parse(
                        (avg / 20).clamp(0.0, 5.0).toStringAsFixed(1));

                    return ListView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
                      children: [
                        _summaryCard(finalGrade, graded.isNotEmpty),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => _submitTask(context),
                            icon: const Icon(Icons.upload_file_rounded),
                            label: const Text('Сдать задание',
                                style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text('Мои сдачи',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ink)),
                        const SizedBox(height: 12),
                        if (subs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                  'Заданий пока нет. Нажмите «Сдать задание».',
                                  style: TextStyle(color: AppTheme.inkSoft)),
                            ),
                          )
                        else
                          for (final s in subs) _submissionRow(s),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _headerBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('${subject.teacher} · Семестр ${subject.semester}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13.5)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(double finalGrade, bool hasGrades) {
    final color = AppTheme.gradeColor(finalGrade);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEEF5)),
      ),
      child: Row(
        children: [
          GradeBadge(grade: finalGrade, size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ИТОГОВАЯ ОЦЕНКА',
                    style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.inkSoft)),
                const SizedBox(height: 6),
                Text(
                  hasGrades ? 'по оценённым заданиям' : 'оценок пока нет',
                  style: TextStyle(
                      color: hasGrades ? color : AppTheme.inkSoft,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _submissionRow(Submission s) {
    final graded = s.isGraded;
    final color = graded
        ? AppTheme.scoreColor(s.score)
        : const Color(0xFFE0A800);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.ink)),
                const SizedBox(height: 3),
                Text('Сдано: ${_fmt(s.date)}',
                    style: const TextStyle(
                        fontSize: 12.5, color: AppTheme.inkSoft)),
              ],
            ),
          ),
          if (graded)
            Text('${s.score}',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color))
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('На проверке',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5)),
            ),
        ],
      ),
    );
  }
}
