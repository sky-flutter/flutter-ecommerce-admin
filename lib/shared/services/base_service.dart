import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';

/// Base service class providing common functionality for all services
abstract class BaseService {
  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Gets the Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Creates a new document in a collection
  Future<DocumentReference> createDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      throw ServiceException('Failed to create document: $e');
    }
  }

  /// Updates a document in a collection
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw ServiceException('Failed to update document: $e');
    }
  }

  /// Deletes a document from a collection
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw ServiceException('Failed to delete document: $e');
    }
  }

  /// Gets a document from a collection
  Future<DocumentSnapshot> getDocument(
    String collection,
    String documentId,
  ) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      throw ServiceException('Failed to get document: $e');
    }
  }

  /// Gets documents from a collection with optional query
  Future<QuerySnapshot> getDocuments(
    String collection, {
    List<Query<dynamic> Function(Query<dynamic>)>? queries,
  }) async {
    try {
      Query<dynamic> query = _firestore.collection(collection);

      if (queries != null) {
        for (final queryFunction in queries) {
          query = queryFunction(query);
        }
      }

      return await query.get();
    } catch (e) {
      throw ServiceException('Failed to get documents: $e');
    }
  }

  /// Streams documents from a collection with optional query
  Stream<QuerySnapshot> streamDocuments(
    String collection, {
    List<Query<dynamic> Function(Query<dynamic>)>? queries,
  }) {
    try {
      Query<dynamic> query = _firestore.collection(collection);

      if (queries != null) {
        for (final queryFunction in queries) {
          query = queryFunction(query);
        }
      }

      return query.snapshots();
    } catch (e) {
      throw ServiceException('Failed to stream documents: $e');
    }
  }

  /// Validates if a document exists
  Future<bool> documentExists(String collection, String documentId) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return doc.exists;
    } catch (e) {
      throw ServiceException('Failed to check document existence: $e');
    }
  }

  /// Gets server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Creates a batch write
  WriteBatch createBatch() => _firestore.batch();

  /// Runs a transaction
  Future<T> runTransaction<T>(Future<T> Function(Transaction) update) async {
    try {
      return await _firestore.runTransaction(update);
    } catch (e) {
      throw ServiceException('Failed to run transaction: $e');
    }
  }
}

/// Exception thrown by services
class ServiceException implements Exception {
  final String message;

  const ServiceException(this.message);

  @override
  String toString() => 'ServiceException: $message';
}
