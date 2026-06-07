import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_user.dart';
import 'auth_config.dart';
import 'auth_service.dart';

abstract class FirebaseAuthService extends AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _gsi = GoogleSignIn.instance;
  StreamSubscription<User?>? _sub;
  bool _gsiReady = false;

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

  Future<AppUser?> loadProfile(User fbUser);

  Future<AppUser> saveProfile(
    User fbUser, {
    required String firstName,
    required String lastName,
    String? group,
  });

  @override
  Future<void> initialize() async {
    try {
      await _gsi.initialize(
        clientId: AuthConfig.clientId,
        serverClientId: AuthConfig.serverClientId,
      );
      _gsiReady = true;
    } catch (e) {
      _error = e.toString();
    }
    _sub = _auth.authStateChanges().listen(_onUser);
  }

  Future<void> _onUser(User? fbUser) async {
    if (fbUser == null) {
      _user = null;
      _pending = null;
      _set(AuthStatus.signedOut);
      return;
    }
    _pending = PendingAccount(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      photoUrl: fbUser.photoURL,
      suggestedName: fbUser.displayName,
    );
    try {
      final profile = await loadProfile(fbUser);
      if (profile != null) {
        _user = profile;
        _set(AuthStatus.signedIn);
      } else {
        _set(AuthStatus.needsProfile);
      }
    } catch (e) {
      _error = e.toString();
      _set(AuthStatus.needsProfile);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    _error = null;
    _busy = true;
    notifyListeners();
    try {
      if (!_gsiReady) {
        await _gsi.initialize(
          clientId: AuthConfig.clientId,
          serverClientId: AuthConfig.serverClientId,
        );
        _gsiReady = true;
      }
      final googleUser = await _gsi.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authz = await googleUser.authorizationClient
          .authorizeScopes(const ['email', 'profile']);
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: authz.accessToken,
      );
      await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      _error = 'Вход отменён или не удался (код: ${e.code.name}).';
    } on FirebaseAuthException catch (e) {
      _error = 'Ошибка Firebase: ${e.code}';
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  Future<void> completeProfile({
    required String firstName,
    required String lastName,
    String? group,
  }) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return;
    _busy = true;
    notifyListeners();
    try {
      _user = await saveProfile(
        fbUser,
        firstName: firstName,
        lastName: lastName,
        group: group,
      );
      _set(AuthStatus.signedIn);
    } catch (e) {
      _error = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _gsi.signOut();
    } catch (_) {}
    await _auth.signOut();
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
