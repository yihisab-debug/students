import 'package:flutter/foundation.dart';
import 'app_user.dart';

enum AuthStatus {
  unknown,
  signedOut,
  needsProfile,
  signedIn,
}

abstract class AuthService extends ChangeNotifier {
  AuthStatus get status;
  AppUser? get user;
  PendingAccount? get pending;
  String? get errorMessage;
  bool get busy;

  Future<void> initialize();

  Future<void> signInWithGoogle();

  Future<void> completeProfile({
    required String firstName,
    required String lastName,
    String? group,
  });

  Future<void> signOut();
}
