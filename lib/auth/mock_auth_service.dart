import 'app_user.dart';
import 'auth_service.dart';

class MockAuthService extends AuthService {
  AuthStatus _status = AuthStatus.signedOut;
  AppUser? _user;
  PendingAccount? _pending;
  String? _error;
  bool _busy = false;

  @override
  AuthStatus get status => _status;
  @override
  AppUser? get user => _user;
  @override
  PendingAccount? get pending => _pending;
  @override
  String? get errorMessage => _error;
  @override
  bool get busy => _busy;
  @override
  bool get isMock => true;

  @override
  List<String> get demoAccounts => const [
        'petr.ivanov@gmail.com',
        'anna.petrova@gmail.com',
        'student@university.edu',
      ];

  @override
  Future<void> initialize() async {
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> pickDemoAccount(String email) async {
    _busy = true;
    _error = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _pending = PendingAccount(
      id: 'demo-${email.hashCode}',
      email: email,
      suggestedName: _nameFromEmail(email),
    );
    _busy = false;
    _status = AuthStatus.needsProfile;
    notifyListeners();
  }

  @override
  void completeProfile({
    required String firstName,
    required String lastName,
    String? group,
  }) {
    final p = _pending;
    if (p == null) return;
    final display = '$lastName $firstName'.trim();
    _user = AppUser(
      id: p.id,
      name: display.isEmpty ? p.email : display,
      email: p.email,
      photoUrl: p.photoUrl,
      group: group,
    );
    _pending = null;
    _status = AuthStatus.signedIn;
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _pending = null;
    _status = AuthStatus.signedOut;
    notifyListeners();
  }

  String? _nameFromEmail(String email) {
    final local = email.split('@').first;
    final parts = local.split(RegExp(r'[._]'));
    if (parts.isEmpty) return null;
    String cap(String s) =>
        s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    return parts.map(cap).join(' ');
  }
}
