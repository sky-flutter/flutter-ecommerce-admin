import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/users/presentation/providers/user_provider.dart';
import 'seed_data.dart';

class SeedDataLoader {
  static Future<void> loadOrderSeedData(
      BuildContext context, WidgetRef ref) async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final ordersData = SeedData.getOrderSeedData();

      int successCount = 0;
      int errorCount = 0;

      for (final orderData in ordersData) {
        try {
          await firestore.addDocument('orders', orderData);
          successCount++;
        } catch (e) {
          errorCount++;
          print('Error adding order: $e');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Orders seed data loaded: $successCount successful, $errorCount failed'),
            backgroundColor: errorCount > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders seed data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> loadReviewSeedData(
      BuildContext context, WidgetRef ref) async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final reviewsData = SeedData.getReviewSeedData();

      int successCount = 0;
      int errorCount = 0;

      for (final reviewData in reviewsData) {
        try {
          await firestore.addDocument('reviews', reviewData);
          successCount++;
        } catch (e) {
          errorCount++;
          print('Error adding review: $e');
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Reviews seed data loaded: $successCount successful, $errorCount failed'),
            backgroundColor: errorCount > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reviews seed data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> loadAllSeedData(
      BuildContext context, WidgetRef ref) async {
    try {
      await loadOrderSeedData(context, ref);
      await Future.delayed(
          const Duration(seconds: 1)); // Small delay between operations
      await loadReviewSeedData(context, ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All seed data loaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading seed data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static void showSeedDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Seed Data'),
        content: const Text(
            'This will add sample orders and reviews to your database for testing. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              loadAllSeedData(context, ref);
            },
            child: const Text('Load All Data'),
          ),
        ],
      ),
    );
  }
}
