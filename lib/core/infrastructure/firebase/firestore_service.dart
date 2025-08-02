import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Enable offline persistence
  FirestoreService() {
    _db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // Generic add
  Future<void> addDocument(String collection, Map<String, dynamic> data,
      [String? docId]) async {
    try {
      if (docId != null) {
        await _db.collection(collection).doc(docId).set(data);
      } else {
        await _db.collection(collection).add(data);
      }
    } catch (e) {
      if (e.toString().contains('offline') ||
          e.toString().contains('unavailable')) {
        throw Exception(
            'No internet connection. Please check your connection and try again.');
      }
      throw Exception('Failed to add document: $e');
    }
  }

  // Generic update
  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(docId).update(data);
    } catch (e) {
      if (e.toString().contains('offline') ||
          e.toString().contains('unavailable')) {
        throw Exception(
            'No internet connection. Please check your connection and try again.');
      }
      throw Exception('Failed to update document: $e');
    }
  }

  // Generic delete
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      if (e.toString().contains('offline') ||
          e.toString().contains('unavailable')) {
        throw Exception(
            'No internet connection. Please check your connection and try again.');
      }
      throw Exception('Failed to delete document: $e');
    }
  }

  // Generic get
  Stream<QuerySnapshot> collectionStream(String collection) {
    return _db.collection(collection).snapshots().handleError((error) {
      if (error.toString().contains('offline') ||
          error.toString().contains('unavailable')) {
        throw Exception(
            'No internet connection. Please check your connection and try again.');
      }
      throw Exception('Failed to fetch data: $error');
    });
  }

  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    try {
      return await _db.collection(collection).doc(docId).get();
    } catch (e) {
      if (e.toString().contains('offline') ||
          e.toString().contains('unavailable')) {
        throw Exception(
            'No internet connection. Please check your connection and try again.');
      }
      throw Exception('Failed to get document: $e');
    }
  }

  // Check if Firestore is available
  Future<bool> isFirestoreAvailable() async {
    try {
      await _db.collection('_health').doc('check').get();
      return true;
    } catch (e) {
      return false;
    }
  }
}
