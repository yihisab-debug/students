import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  final AuthService auth;
  const LoginScreen({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppTheme.headerGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 38),
                ),
                const SizedBox(height: 20),
                const Text('Зачётка',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink)),
                const SizedBox(height: 6),
                const Text('Кабинет студента · успеваемость',
                    style: TextStyle(color: AppTheme.inkSoft, fontSize: 14)),
                const SizedBox(height: 36),
                if (auth.errorMessage != null) _errorBox(auth.errorMessage!),
                _GoogleButton(
                  busy: auth.busy,
                  onTap: auth.busy ? null : auth.signInWithGoogle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorBox(String msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3B6B6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFC0392B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(msg,
                style: const TextStyle(
                    color: Color(0xFFC0392B), fontSize: 12.5)),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool busy;
  final VoidCallback? onTap;
  const _GoogleButton({required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDADCE6)),
            ),
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _GoogleG(),
                        const SizedBox(width: 12),
                        Text(
                          'Войти через Google',
                          style: TextStyle(
                            color: AppTheme.ink.withOpacity(0.85),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          colors: [
            Color(0xFF4285F4),
            Color(0xFF34A853),
            Color(0xFFFBBC05),
            Color(0xFFEA4335),
          ],
        ).createShader(rect),
        child: const Center(
          child: Text('G',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0)),
        ),
      ),
    );
  }
}
