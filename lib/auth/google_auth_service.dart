import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_user.dart';
import 'auth_config.dart';
import 'auth_service.dart';

class GoogleAuthService extends AuthService {
  final GoogleSignIn _gsi = GoogleSignIn.instance;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _sub;

  AuthStatus _status = AuthStatus.unknown;
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
  bool get isMock => false;
  @override
  List<String> get demoAccounts => const [];

  @override
  Future<void> initialize() async {
    try {
      await _gsi.initialize(
        clientId: AuthConfig.clientId,
        serverClientId: AuthConfig.serverClientId,
      );
      _sub = _gsi.authenticationEvents.listen(
        _onAuthEvent,
        onError: (Object e) {
          _error = e.toString();
          notifyListeners();
        },
      );
      _set(AuthStatus.signedOut);
      await _gsi.attemptLightweightAuthentication();
    } catch (e) {
      _error = e.toString();
      _set(AuthStatus.signedOut);
    }
  }

  void _onAuthEvent(GoogleSignInAuthenticationEvent event) {
    if (event is GoogleSignInAuthenticationEventSignIn) {
      final acc = event.user;
      _pending = PendingAccount(
        id: acc.id,
        email: acc.email,
        photoUrl: acc.photoUrl,
        suggestedName: acc.displayName,
      );
      _error = null;
      _set(AuthStatus.needsProfile);
    } else if (event is GoogleSignInAuthenticationEventSignOut) {
      _user = null;
      _pending = null;
      _set(AuthStatus.signedOut);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    _error = null;
    _busy = true;
    notifyListeners();
    try {
      if (_gsi.supportsAuthenticate()) {
        await _gsi.authenticate();
      } else {
        _error = 'На этой платформе вход выполняется кнопкой Google SDK '
            '(на Web — renderButton). См. README.';
      }
    } on GoogleSignInException catch (e) {
      _error = 'Не удалось войти (код: ${e.code.name}). '
          'Проверьте настройку OAuth — см. README.';
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  Future<void> pickDemoAccount(String email) async {}

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
      name: display.isEmpty ? (p.suggestedName ?? p.email) : display,
      email: p.email,
      photoUrl: p.photoUrl,
      group: group,
    );
    _pending = null;
    _set(AuthStatus.signedIn);
  }

  @override
  Future<void> signOut() async {
    try {
      await _gsi.signOut();
    } catch (_) {}
    _user = null;
    _pending = null;
    _set(AuthStatus.signedOut);
  }

  void _set(AuthStatus s) {
    _status = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
