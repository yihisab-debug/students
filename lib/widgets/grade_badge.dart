import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradeBadge extends StatelessWidget {
  final double grade;
  final double size;

  const GradeBadge({super.key, required this.grade, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.gradeColor(grade);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.18)!],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        grade.toStringAsFixed(1),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}
