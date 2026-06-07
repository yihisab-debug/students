import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../config.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final AuthService auth;
  const OnboardingScreen({super.key, required this.auth});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<String> get groups => AppConfig.groups;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  String? _group;
  String? _error;

  @override
  void initState() {
    super.initState();
    final suggested = widget.auth.pending?.suggestedName?.trim();
    if (suggested != null && suggested.isNotEmpty) {
      final parts = suggested.split(RegExp(r'\s+'));
      _firstName.text = parts.first;
      if (parts.length > 1) _lastName.text = parts.sublist(1).join(' ');
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  void _submit() {
    final first = _firstName.text.trim();
    final last = _lastName.text.trim();
    if (first.isEmpty || last.isEmpty) {
      setState(() => _error = 'Укажите имя и фамилию');
      return;
    }
    if (_group == null) {
      setState(() => _error = 'Выберите группу');
      return;
    }
    widget.auth.completeProfile(
      firstName: first,
      lastName: last,
      group: _group,
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.auth.pending?.email ?? '';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Расскажите о себе',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink)),
                  const SizedBox(height: 6),
                  const Text('Заполните профиль, чтобы продолжить',
                      style:
                          TextStyle(color: AppTheme.inkSoft, fontSize: 14)),
                  const SizedBox(height: 20),
                  if (email.isNotEmpty) _accountBadge(email),
                  const SizedBox(height: 24),
                  _label('Имя'),
                  const SizedBox(height: 6),
                  _field(_firstName, 'Пётр'),
                  const SizedBox(height: 16),
                  _label('Фамилия'),
                  const SizedBox(height: 6),
                  _field(_lastName, 'Иванов'),
                  const SizedBox(height: 16),
                  _label('Группа'),
                  const SizedBox(height: 6),
                  _groupDropdown(),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!,
                        style: const TextStyle(color: Color(0xFFC0392B))),
                  ],
                  const SizedBox(height: 26),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _submit,
                      child: const Text('Продолжить',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: widget.auth.signOut,
                    child: const Text('Сменить аккаунт',
                        style: TextStyle(color: AppTheme.inkSoft)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _accountBadge(String email) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary,
            child: Text(email.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(email,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.ink, fontSize: 13.5)),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF22A06B), size: 18),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.w700, color: AppTheme.ink, fontSize: 13.5));

  Widget _field(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEDEEF5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEDEEF5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _groupDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDEEF5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _group,
          isExpanded: true,
          hint: const Text('Выберите группу'),
          borderRadius: BorderRadius.circular(14),
          items: [
            for (final g in groups)
              DropdownMenuItem(value: g, child: Text(g)),
          ],
          onChanged: (v) => setState(() => _group = v),
        ),
      ),
    );
  }
}
