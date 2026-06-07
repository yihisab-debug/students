import 'package:flutter/material.dart';

import 'auth/auth_service.dart';
import 'auth/student_auth_service.dart';
import 'screens/auth_gate.dart';
import 'startup.dart';
import 'theme/app_theme.dart';

void main() => bootstrap(const StudentApp());

class StudentApp extends StatefulWidget {
  const StudentApp({super.key});

  @override
  State<StudentApp> createState() => _StudentAppState();
}

class _StudentAppState extends State<StudentApp> {
  late final AuthService _auth = StudentAuthService();

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Зачётка · Студент',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: AuthGate(auth: _auth),
    );
  }
}
