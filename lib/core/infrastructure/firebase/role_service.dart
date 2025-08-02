import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> getUserRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] ?? 'viewer';
  }

  Future<void> setUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).update({'role': role});
  }

  Future<bool> isAdmin(String uid) async => (await getUserRole(uid)) == 'admin';
  Future<bool> isEditor(String uid) async =>
      (await getUserRole(uid)) == 'editor';
  Future<bool> isViewer(String uid) async =>
      (await getUserRole(uid)) == 'viewer';
}
