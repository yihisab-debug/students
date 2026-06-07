import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class AuthGate extends StatefulWidget {
  final AuthService auth;
  const AuthGate({super.key, required this.auth});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    widget.auth.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.auth,
      builder: (context, _) {
        switch (widget.auth.status) {
          case AuthStatus.unknown:
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          case AuthStatus.signedOut:
            return LoginScreen(auth: widget.auth);
          case AuthStatus.needsProfile:
            return OnboardingScreen(auth: widget.auth);
          case AuthStatus.signedIn:
            return HomeScreen(auth: widget.auth, user: widget.auth.user!);
        }
      },
    );
  }
}
