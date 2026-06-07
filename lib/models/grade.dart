class Grade {
  final String title;
  final int? score;
  final DateTime? date;

  const Grade({
    required this.title,
    this.score,
    this.date,
  });

  bool get isGraded => score != null;
}
