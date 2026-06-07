import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> bootstrap(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (DefaultFirebaseOptions.android.apiKey == 'REPLACE_ME') {
    runApp(const _MessageApp(
      icon: Icons.settings_suggest_outlined,
      title: 'Нужна настройка Firebase',
      message:
          'Выполните `flutterfire configure` в папке проекта, чтобы создать '
          'firebase_options.dart с ключами вашего проекта Firebase, '
          'затем перезапустите приложение.\n\nПодробности — в README.',
    ));
    return;
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    runApp(_MessageApp(
      icon: Icons.error_outline,
      title: 'Ошибка запуска Firebase',
      message: '$e',
    ));
    return;
  }

  runApp(app);
}

class _MessageApp extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _MessageApp({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 56, color: const Color(0xFF8A8FA3)),
                  const SizedBox(height: 16),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E2233))),
                  const SizedBox(height: 12),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF6B7185), height: 1.4)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
