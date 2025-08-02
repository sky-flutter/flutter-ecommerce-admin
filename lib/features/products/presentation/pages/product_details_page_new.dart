import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../shared/widgets/cloudinary_image.dart';
import '../../../../shared/widgets/product_details_shimmer.dart';
import '../../../../core/infrastructure/firebase/storage_service.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../shared/widgets/custom_card.dart';

class ProductDetailsPageNew extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsPageNew({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailsPageNew> createState() =>
      _ProductDetailsPageNewState();
}

class _ProductDetailsPageNewState extends ConsumerState<ProductDetailsPageNew> {
  ProductModel? _product;
  bool _isLoading = true;
  bool _isDeleting = false;
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final doc = await firestore.getDocument('products', widget.productId);

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _product = ProductModel.fromMap(data, doc.id);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found'),
              backgroundColor: Colors.red,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ProductDetailsShimmer();
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(
          child: Text('Product not found'),
        ),
      );
    }

    // Create a list of images including main image and gallery images
    final List<String> allImages = [
      _product!.imageUrl,
      ..._product!.galleryUrls
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/products/add/${_product!.id}'),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Product',
          ),
          IconButton(
            onPressed: _isDeleting
                ? null
                : () {
                    // Delete action
                  },
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete),
            tooltip: 'Delete Product',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Product Images
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Main Image
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CloudinaryImage(
                        imageUrl: allImages[_selectedImageIndex],
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Thumbnail Images
                  if (allImages.length > 1)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImageIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedImageIndex == index
                                      ? Colors.blue
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: _selectedImageIndex == index ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CloudinaryImage(
                                  imageUrl: allImages[index],
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 48),

            // Right Column - Product Information
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title
                  Text(
                    _product!.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Category
                  Row(
                    children: [
                      CustomCard(
                        title: _product!.category,
                        value: 'Category',
                        icon: Icons.category,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      CustomCard(
                        title: _product!.subcategory ?? 'No subcategory',
                        value: 'Subcategory',
                        icon: Icons.category,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Reviews
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                            5,
                            (index) => const Icon(
                                  Icons.star,
                                  color: Colors.black,
                                  size: 20,
                                )),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(2000 Reviews)',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price
                  Row(
                    children: [
                      Text(
                        'Price:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${_product!.finalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 32, color: Colors.red),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${_product!.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_product!.discount > 0) ...[
                        Text(
                          '${_product!.discount.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Size Options
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      CustomCard(
                        title: 'Active',
                        value: 'Active',
                        icon: Icons.check,
                        color: Colors.green,
                      ),
                      CustomCard(
                        title: 'Featured',
                        value: 'Featured',
                        icon: Icons.star,
                        color: Colors.orange,
                      ),
                      CustomCard(
                        title: 'New Arrival',
                        value: 'New Arrival',
                        icon: Icons.new_releases,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _product!.tags
                        .map((tag) => CustomCard(
                              title: tag,
                              value: tag,
                              icon: Icons.tag,
                              color: Colors.blue,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  if (_product!.videoUrl.isNotEmpty) ...[
                    // Video
                    const Text(
                      'Video',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
