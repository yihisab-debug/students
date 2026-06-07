import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import 'grade_badge.dart';

class SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final passed = subject.isCompleted;
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDEEF5)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1E2233),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: AppTheme.headerGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ink,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline,
                                          size: 14, color: AppTheme.inkSoft),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          subject.teacher,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: AppTheme.inkSoft,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: onToggleFavorite,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                subject.isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: subject.isFavorite
                                    ? const Color(0xFFE0A800)
                                    : AppTheme.inkSoft,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            GradeBadge(grade: subject.finalGrade, size: 52),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    passed
                                        ? 'Итоговая оценка'
                                        : 'Текущая оценка',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 0.4,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.inkSoft,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _StatusPill(status: subject.status),
                                ],
                              ),
                            ),
                            _Chip(
                              text: 'Сем. ${subject.semester}',
                              bg: const Color(0xFFEFEFFB),
                              fg: AppTheme.primaryDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in subject.summary)
                              _SummaryChip(label: s.label, value: s.value),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final SubjectStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final passed = status == SubjectStatus.passed;
    final color = passed ? const Color(0xFF22A06B) : const Color(0xFFE0A800);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(passed ? Icons.check_circle : Icons.hourglass_bottom,
            size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          status.label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Chip({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: fg, fontSize: 11.5, fontWeight: FontWeight.w700)),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: const TextStyle(fontSize: 12, color: AppTheme.inkSoft)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink)),
        ],
      ),
    );
  }
}
