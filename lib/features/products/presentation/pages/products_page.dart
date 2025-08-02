import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../shared/widgets/search_bar.dart' as custom;
import '../../../../shared/widgets/cloudinary_image.dart';
import '../../../../shared/widgets/product_shimmer.dart';
import '../../../../shared/models/product_model.dart';
import '../providers/product_provider.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../shared/services/storage_service_provider.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../shared/services/currency_provider.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<ProductModel> _filteredProducts = [];

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return EnhancedLayoutWrapper(
      currentRoute: '/products',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
            child: ResponsiveBuilder(
              builder: (context, sizingInformation) {
                if (sizingInformation.isMobile) {
                  return Column(
                    children: [
                      custom.SearchBar(
                        hintText: 'Search products...',
                        onChanged: (query) =>
                            setState(() => _searchQuery = query),
                      ),
                      const SizedBox(height: 16),
                      if (userRoleAsync?.value == 'admin' ||
                          userRoleAsync?.value == 'editor')
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: () => context.go('/products/add'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: custom.SearchBar(
                          hintText: 'Search products...',
                          onChanged: (query) =>
                              setState(() => _searchQuery = query),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (userRoleAsync?.value == 'admin' ||
                          userRoleAsync?.value == 'editor')
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () => context.go('/products/add'),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                        ),
                    ],
                  );
                }
              },
            ),
          ),
          // Products Grid
          Expanded(
            child: productsAsync.when(
              data: (productsSnapshot) {
                final products = productsSnapshot.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ProductModel.fromMap(data, doc.id);
                }).toList();

                // Filter products based on search and category
                _filteredProducts = products.where((product) {
                  final matchesSearch = product.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      product.description
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                  final matchesCategory = _selectedCategory == 'All' ||
                      product.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (_filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filter criteria',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return _buildProductsGrid();
              },
              loading: () => _buildShimmerGrid(),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        int crossAxisCount = 4;
        if (sizingInformation.isMobile) {
          crossAxisCount = 2;
        } else if (sizingInformation.isTablet) {
          crossAxisCount = 3;
        }
        return ProductShimmer(
          crossAxisCount: crossAxisCount,
          itemCount: 8,
        );
      },
    );
  }

  Widget _buildProductsGrid() {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        int crossAxisCount = 5;
        double childAspectRatio = 0.70;

        if (sizingInformation.isMobile) {
          crossAxisCount = 2;
          childAspectRatio = 0.8;
        } else if (sizingInformation.isTablet) {
          crossAxisCount = 3;
          childAspectRatio = 0.75;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Theme.of(context).cardColor,
          child: InkWell(
            onTap: () => context.go('/products/${product.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with AspectRatio
                Stack(
                  children: [
                    CloudinaryImage(
                      imageUrl: product.imageUrl,
                      height: 320,
                      width: 320,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    // Category Badge
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Action Buttons
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Row(
                        children: [
                          // Edit Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.blue,
                              ),
                              onPressed: () =>
                                  context.go('/products/add/${product.id}'),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Delete Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  _showDeleteProductDialog(context, product),
                              padding: const EdgeInsets.all(6),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Product Info
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Price Row
                      Row(
                        children: [
                          Text(
                            ref
                                .watch(currencyFormatterProvider)
                                .formatPrice(product.price),
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          // Stock Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: product.stock > 0
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: product.stock > 0
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.red.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              product.stock > 0 ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                color: product.stock > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Stock Count
                      Text(
                        'Stock: ${product.stock}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteProductDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final storage = ref.read(storageServiceProvider);

      // Delete image from storage (if using Firebase Storage)
      if (product.imageUrl.contains('firebase')) {
        await storage.deleteFile(product.imageUrl);
      }
      // Note: For Cloudinary, you would need admin API to delete images
      // This is handled separately in the Cloudinary service

      // Delete product from Firestore
      await firestore.deleteDocument('products', product.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Product ${product.name} deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting product: $e')),
        );
      }
    }
  }
}
