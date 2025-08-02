import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/infrastructure/firebase/firestore_service.dart';
import '../../features/users/presentation/providers/user_provider.dart';

class CurrencyNotifier extends StateNotifier<String> {
  final FirestoreService _firestore;

  CurrencyNotifier(this._firestore) : super('USD') {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      final doc = await _firestore.getDocument('payment_settings', 'main');
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final currency = data['currency'] as String? ?? 'USD';
        state = currency;
      }
    } catch (e) {
      // Keep default USD if there's an error
      state = 'USD';
    }
  }

  Future<void> updateCurrency(String currency) async {
    try {
      final doc = await _firestore.getDocument('payment_settings', 'main');
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['currency'] = currency;
        await _firestore.updateDocument('payment_settings', 'main', data);
      } else {
        await _firestore.addDocument(
            'payment_settings', {'currency': currency}, 'main');
      }
      state = currency;
    } catch (e) {
      // Handle error
      rethrow;
    }
  }

  String get symbol {
    switch (state) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'CHF';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      default:
        return '\$';
    }
  }

  String formatPrice(double amount) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  String formatPriceWithoutDecimal(double amount) {
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return CurrencyNotifier(firestore);
});

final currencySymbolProvider = Provider<String>((ref) {
  final currency = ref.watch(currencyProvider);
  final notifier = ref.read(currencyProvider.notifier);
  return notifier.symbol;
});

final currencyFormatterProvider = Provider<CurrencyNotifier>((ref) {
  return ref.read(currencyProvider.notifier);
});
