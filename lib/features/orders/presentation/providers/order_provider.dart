import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/infrastructure/firebase/firestore_service.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';

class OrderNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final FirestoreService _firestore;

  OrderNotifier(this._firestore) : super(const AsyncValue.loading()) {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      state = const AsyncValue.loading();
      final orders = await _firestore
          .collectionStream('orders')
          .map((q) => q.docs
              .map((doc) => OrderModel.fromMap(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList())
          .first;

      // Sort by creation date (newest first)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = AsyncValue.data(orders);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addOrder(OrderModel order) async {
    try {
      await _firestore.addDocument('orders', order.toMap());
      await _loadOrders(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now();
      await _firestore.updateDocument('orders', orderId, updates);
      await _loadOrders(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.deleteDocument('orders', orderId);
      await _loadOrders(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now(),
      };

      // Add specific timestamps based on status
      switch (status) {
        case 'shipped':
          updates['shippedAt'] = DateTime.now();
          break;
        case 'delivered':
          updates['deliveredAt'] = DateTime.now();
          break;
        case 'refunded':
          updates['refundedAt'] = DateTime.now();
          break;
      }

      await _firestore.updateDocument('orders', orderId, updates);
      await _loadOrders(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      await _firestore.updateDocument('orders', orderId, {
        'paymentStatus': paymentStatus,
        'updatedAt': DateTime.now(),
      });
      await _loadOrders(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addTrackingNumber(String orderId, String trackingNumber) async {
    try {
      await _firestore.updateDocument('orders', orderId, {
        'trackingNumber': trackingNumber,
        'updatedAt': DateTime.now(),
      });
      await _loadOrders(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refundOrder(String orderId, String reason) async {
    try {
      await _firestore.updateDocument('orders', orderId, {
        'status': 'refunded',
        'paymentStatus': 'refunded',
        'refundReason': reason,
        'refundedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
      await _loadOrders(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  // Get orders by status
  List<OrderModel> getOrdersByStatus(String status) {
    return state.when(
      data: (orders) =>
          orders.where((order) => order.status == status).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get orders by payment status
  List<OrderModel> getOrdersByPaymentStatus(String paymentStatus) {
    return state.when(
      data: (orders) => orders
          .where((order) => order.paymentStatus == paymentStatus)
          .toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get orders by date range
  List<OrderModel> getOrdersByDateRange(DateTime startDate, DateTime endDate) {
    return state.when(
      data: (orders) => orders
          .where((order) =>
              order.createdAt.isAfter(startDate) &&
              order.createdAt.isBefore(endDate))
          .toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get total revenue
  double getTotalRevenue() {
    return state.when(
      data: (orders) => orders
          .where((order) => order.paymentStatus == 'paid')
          .fold(0.0, (sum, order) => sum + order.total),
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
  }

  // Get total orders count
  int getTotalOrders() {
    return state.when(
      data: (orders) => orders.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  // Get pending orders count
  int getPendingOrders() {
    return state.when(
      data: (orders) =>
          orders.where((order) => order.status == 'pending').length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  // Get orders that need shipping
  List<OrderModel> getOrdersNeedingShipping() {
    return state.when(
      data: (orders) => orders
          .where((order) =>
              order.status == 'confirmed' || order.status == 'processing')
          .toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Refresh orders
  Future<void> refresh() async {
    await _loadOrders();
  }
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<OrderModel>>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return OrderNotifier(firestore);
});

// Individual order provider
final orderStreamProvider =
    FutureProvider.family<OrderModel?, String>((ref, orderId) async {
  final firestore = ref.watch(firestoreServiceProvider);
  try {
    final doc = await firestore.getDocument('orders', orderId);
    if (doc.exists) {
      return OrderModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }
    return null;
  } catch (e) {
    return null;
  }
});
