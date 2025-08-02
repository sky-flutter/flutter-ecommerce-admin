import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_admin_panel/shared/services/currency_provider.dart';

class InventoryPricingSection extends ConsumerWidget {
  final TextEditingController priceController;
  final TextEditingController costPriceController;
  final TextEditingController discountController;
  final TextEditingController stockController;
  final TextEditingController skuController;
  final TextEditingController barcodeController;

  const InventoryPricingSection({
    super.key,
    required this.priceController,
    required this.costPriceController,
    required this.discountController,
    required this.stockController,
    required this.skuController,
    required this.barcodeController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Inventory & Pricing',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Price and Cost Price Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Selling Price *',
                      hintText: '0.00',
                      prefixText: ref.watch(currencySymbolProvider),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid price';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Price must be greater than 0';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: costPriceController,
                    decoration: InputDecoration(
                      labelText: 'Cost Price',
                      hintText: '0.00',
                      prefixText: ref.watch(currencySymbolProvider),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid cost price';
                        }
                        if (double.parse(value) < 0) {
                          return 'Cost price cannot be negative';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Discount and Stock Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: discountController,
                    decoration: const InputDecoration(
                      labelText: 'Discount (%)',
                      hintText: '0',
                      suffixText: '%',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid discount';
                        }
                        final discount = double.parse(value);
                        if (discount < 0 || discount > 100) {
                          return 'Discount must be between 0 and 100';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Quantity *',
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Stock quantity is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid quantity';
                      }
                      if (int.parse(value) < 0) {
                        return 'Stock cannot be negative';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // SKU and Barcode Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU',
                      hintText: 'Enter Stock Keeping Unit',
                      border: OutlineInputBorder(),
                      helperText: 'Unique identifier for inventory management',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Barcode',
                      hintText: 'Enter product barcode',
                      border: OutlineInputBorder(),
                      helperText: 'For scanning and identification',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Profit Margin Display (calculated)
            if (priceController.text.isNotEmpty &&
                costPriceController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Profit Margin: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      _calculateProfitMargin(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _calculateProfitMargin() {
    try {
      final price = double.tryParse(priceController.text) ?? 0;
      final cost = double.tryParse(costPriceController.text) ?? 0;

      if (price <= 0 || cost <= 0) return 'N/A';

      final profit = price - cost;
      final margin = (profit / price) * 100;

      return '${profit.toStringAsFixed(2)}';
    } catch (e) {
      return 'N/A';
    }
  }
}
