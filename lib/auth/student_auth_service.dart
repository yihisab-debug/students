import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_user.dart';
import 'firebase_auth_service.dart';

class StudentAuthService extends FirebaseAuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loadProfile(User fbUser) async {
    final email = fbUser.email ?? '';
    if (email.isEmpty) return null;
    final snap = await _db.collection('students').doc(email).get();
    final d = snap.data();
    if (d == null) return null;
    final name = (d['name'] ?? '') as String;
    final group = d['group'] as String?;
    if (name.isEmpty || group == null || group.isEmpty) return null;
    return AppUser(
      id: fbUser.uid,
      name: name,
      email: email,
      photoUrl: fbUser.photoURL,
      group: group,
    );
  }

  @override
  Future<AppUser> saveProfile(
    User fbUser, {
    required String firstName,
    required String lastName,
    String? group,
  }) async {
    final email = fbUser.email ?? fbUser.uid;
    final name = '$lastName $firstName'.trim();
    await _db.collection('students').doc(email).set({
      'uid': fbUser.uid,
      'email': email,
      'name': name,
      'group': group,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return AppUser(
      id: fbUser.uid,
      name: name.isEmpty ? email : name,
      email: email,
      photoUrl: fbUser.photoURL,
      group: group,
    );
  }
}
