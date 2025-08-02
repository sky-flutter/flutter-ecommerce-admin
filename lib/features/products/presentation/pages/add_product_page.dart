import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/product_model.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../shared/services/currency_provider.dart';
import '../../../../features/categories/presentation/providers/category_provider.dart';
import '../../../../core/infrastructure/firebase/cloudinary_service.dart';
import 'widgets/product_info_section.dart';
import 'widgets/inventory_pricing_section.dart';
import 'widgets/media_section.dart';
import 'widgets/configuration_section.dart';
import 'widgets/seo_metadata_section.dart';

class AddProductPage extends ConsumerStatefulWidget {
  final String? productId; // null for add mode, non-null for edit mode

  const AddProductPage({
    super.key,
    this.productId,
  });

  @override
  ConsumerState<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends ConsumerState<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isLoadingProduct = false;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isNewArrival = false;

  // Product Info
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  CategoryModel? _selectedCategory = null;
  CategoryModel? _selectedSubcategory = null;
  final _brandController = TextEditingController();
  final _tagsController = TextEditingController();

  // Inventory & Pricing
  final _priceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();

  // Media
  File? _mainImage;
  Uint8List? _mainImageBytes;
  List<File> _galleryImages = [];
  List<Uint8List> _galleryImageBytes = [];
  final _videoLinkController = TextEditingController();

  // Existing media URLs (for edit mode)
  String _existingMainImageUrl = '';
  List<String> _existingGalleryUrls = [];

  // SEO & Metadata
  final _slugController = TextEditingController();
  final _metaTitleController = TextEditingController();
  final _metaDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateSubcategories();
    _nameController.addListener(_generateSlug);

    // Load product data if in edit mode
    if (widget.productId != null) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    if (widget.productId == null) return;

    setState(() => _isLoadingProduct = true);

    try {
      final firestore = ref.read(firestoreServiceProvider);
      final doc = await firestore.getDocument('products', widget.productId!);

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final product = ProductModel.fromMap(data, doc.id);

        // Populate form fields
        _nameController.text = product.name;
        _descriptionController.text = product.description;
        _brandController.text = product.brand ?? '';
        _tagsController.text = product.tags.join(', ');
        _priceController.text = product.price.toString();
        _costPriceController.text = product.costPrice?.toString() ?? '';
        _discountController.text = product.discount.toString();
        _stockController.text = product.stock.toString();
        _skuController.text = product.sku ?? '';
        _barcodeController.text = product.barcode ?? '';
        _videoLinkController.text = product.videoUrl ?? '';
        _slugController.text = product.slug ?? '';
        _metaTitleController.text = product.metaTitle ?? '';
        _metaDescriptionController.text = product.metaDescription ?? '';

        // Set status flags
        _isActive = product.isActive;
        _isFeatured = product.isFeatured;
        _isNewArrival = product.isNewArrival;

        // Store existing media URLs
        _existingMainImageUrl = product.imageUrl;
        _existingGalleryUrls = product.galleryUrls;

        // Load categories
        await _loadCategoriesForProduct(product);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingProduct = false);
      }
    }
  }

  Future<void> _loadCategoriesForProduct(ProductModel product) async {
    try {
      final categoriesAsync = ref.read(categoriesHierarchyProvider);
      final categories = await categoriesAsync.when(
        data: (data) => data,
        loading: () => <String, List<CategoryModel>>{},
        error: (_, __) => <String, List<CategoryModel>>{},
      );

      // Find and set the main category
      final mainCategories = categories['main'] ?? [];
      if (mainCategories.isNotEmpty) {
        try {
          _selectedCategory = mainCategories.firstWhere(
            (cat) => cat.name == product.category,
          );
        } catch (e) {
          _selectedCategory = mainCategories.first;
        }
      }

      // Find and set the subcategory
      if (product.subcategory != null && _selectedCategory != null) {
        final subcategories = categories[_selectedCategory!.id] ?? [];
        if (subcategories.isNotEmpty) {
          try {
            _selectedSubcategory = subcategories.firstWhere(
              (cat) => cat.name == product.subcategory,
            );
          } catch (e) {
            // Subcategory not found, leave as null
          }
        }
      }

      // Update UI after setting categories
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle category loading errors gracefully
      print('Error loading categories: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _tagsController.dispose();
    _priceController.dispose();
    _costPriceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _videoLinkController.dispose();
    _slugController.dispose();
    _metaTitleController.dispose();
    _metaDescriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateSubcategories() {
    setState(() {
      _selectedSubcategory = null;
    });
  }

  void _generateSlug() {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      final slug = name
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '-')
          .trim();
      _slugController.text = slug;
      if (_metaTitleController.text.isEmpty) {
        _metaTitleController.text = name;
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _mainImage = File(image.path);
      });
    }
  }

  Future<void> _pickGalleryImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (images.isNotEmpty) {
      for (var image in images) {
        final bytes = await image.readAsBytes();
        _galleryImageBytes.add(bytes);
        _galleryImages.add(File(image.path));
      }
      setState(() {});
    }
  }

  void _removeGalleryImage(int index) {
    setState(() {
      _galleryImages.removeAt(index);
    });
  }

  void _removeExistingGalleryImage(int index) {
    setState(() {
      _existingGalleryUrls.removeAt(index);
    });
  }

  Future<void> _pickMainImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _mainImageBytes = bytes; // Add this field to your state
          _mainImage = File(image.path); // Clear the File reference
        });
      } else {
        // For mobile, use File
        setState(() {
          _mainImage = File(image.path);
          _mainImageBytes = null; // Clear the bytes reference
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Check for image based on platform (only for new products)
    if (widget.productId == null &&
        (kIsWeb ? _mainImageBytes == null : _mainImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a main product image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestore = ref.read(firestoreServiceProvider);
      final cloudinary = ref.read(cloudinaryServiceProvider);

      String mainImageUrl = _existingMainImageUrl;
      List<String> galleryUrls = List.from(_existingGalleryUrls);

      // Upload new main image if selected
      if (kIsWeb ? _mainImageBytes != null : _mainImage != null) {
        mainImageUrl = await cloudinary.uploadImage(
          kIsWeb ? _mainImageBytes! : _mainImage!,
          folder: 'ecommerce/products/main',
        );
      }

      // Upload new gallery images if selected
      if (_galleryImageBytes.isNotEmpty) {
        final newGalleryUrls = await cloudinary.uploadImages(
          _galleryImageBytes,
          folder: 'ecommerce/products/gallery',
        );
        galleryUrls.addAll(newGalleryUrls);
      }

      // Prepare product data
      final productData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'category_id': _selectedCategory?.id,
        'subcategory_id': _selectedSubcategory?.id,
        'category_name': _selectedCategory?.name,
        'subcategory_name': _selectedSubcategory?.name,
        'brand': _brandController.text,
        'tags': _tagsController.text.split(',').map((e) => e.trim()).toList(),
        'price': double.parse(_priceController.text),
        'costPrice': double.tryParse(_costPriceController.text) ?? 0.0,
        'discount': double.tryParse(_discountController.text) ?? 0.0,
        'stock': int.parse(_stockController.text),
        'sku': _skuController.text,
        'barcode': _barcodeController.text,
        'mainImageUrl': mainImageUrl,
        'galleryUrls': galleryUrls,
        'videoLink': _videoLinkController.text,
        'isActive': _isActive,
        'isFeatured': _isFeatured,
        'isNewArrival': _isNewArrival,
        'slug': _slugController.text,
        'metaTitle': _metaTitleController.text,
        'metaDescription': _metaDescriptionController.text,
        'updatedAt': DateTime.now(),
        // Add Cloudinary-specific data
        'imageProvider': 'cloudinary',
        'mainImagePublicId': cloudinary.extractPublicId(mainImageUrl),
        'galleryImagePublicIds': galleryUrls
            .map((url) => cloudinary.extractPublicId(url))
            .whereType<String>()
            .toList(),
      };

      if (widget.productId == null) {
        // Add new product
        productData['createdAt'] = DateTime.now();
        await firestore.addDocument('products', productData);
      } else {
        // Update existing product
        await firestore.updateDocument(
            'products', widget.productId!, productData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.productId == null
                ? 'Product added successfully!'
                : 'Product updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.push('/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error ${widget.productId == null ? 'adding' : 'updating'} product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProduct) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _buildAddProductForm();
  }

  Widget _buildAddProductForm() {
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    final categoriesAsync = ref.watch(categoriesHierarchyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
        actions: [
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveProduct,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isLoading
                ? (widget.productId == null ? 'Saving...' : 'Updating...')
                : (widget.productId == null
                    ? 'Save Product'
                    : 'Update Product')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          )
        ],
      ),
      body: userRoleAsync?.when(
            data: (role) {
              if (role != 'admin' && role != 'editor') {
                return const Center(
                  child: Text(
                      'Access denied. You need admin or editor permissions.'),
                );
              }
              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Form Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(24),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Product Info Section
                              categoriesAsync.when(
                                data: (categories) {
                                  final subcategories =
                                      categories[_selectedCategory?.id ?? ''] ??
                                          [];

                                  return ProductInfoSection(
                                    nameController: _nameController,
                                    descriptionController:
                                        _descriptionController,
                                    selectedCategory: _selectedCategory,
                                    selectedSubcategory: _selectedSubcategory,
                                    brandController: _brandController,
                                    categories: categories['main'] ?? [],
                                    subcategories: subcategories,
                                    tagsController: _tagsController,
                                    onCategoryChanged: (value) {
                                      setState(() {
                                        _selectedCategory =
                                            value as CategoryModel?;
                                        _selectedSubcategory =
                                            null; // Reset subcategory when category changes
                                      });
                                    },
                                    onSubcategoryChanged: (value) {
                                      setState(() {
                                        _selectedSubcategory =
                                            value as CategoryModel?;
                                      });
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (error, stack) => Center(
                                  child: Text('Error: $error'),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Inventory & Pricing Section
                              InventoryPricingSection(
                                priceController: _priceController,
                                costPriceController: _costPriceController,
                                discountController: _discountController,
                                stockController: _stockController,
                                skuController: _skuController,
                                barcodeController: _barcodeController,
                              ),
                              const SizedBox(height: 32),

                              // Media Section
                              MediaSection(
                                mainImage: _mainImage,
                                mainImageBytes: _mainImageBytes,
                                galleryImageBytes: _galleryImageBytes,
                                galleryImages: _galleryImages,
                                videoLinkController: _videoLinkController,
                                onPickMainImage: _pickMainImage,
                                onPickGalleryImages: _pickGalleryImages,
                                onRemoveGalleryImage: _removeGalleryImage,
                                existingMainImageUrl: _existingMainImageUrl,
                                existingGalleryUrls: _existingGalleryUrls,
                                onRemoveExistingGalleryImage:
                                    _removeExistingGalleryImage,
                              ),
                              const SizedBox(height: 32),

                              // Configuration Section
                              ConfigurationSection(
                                isActive: _isActive,
                                isFeatured: _isFeatured,
                                isNewArrival: _isNewArrival,
                                onActiveChanged: (value) =>
                                    setState(() => _isActive = value!),
                                onFeaturedChanged: (value) =>
                                    setState(() => _isFeatured = value!),
                                onNewArrivalChanged: (value) =>
                                    setState(() => _isNewArrival = value!),
                              ),
                              const SizedBox(height: 32),

                              // SEO & Metadata Section
                              SeoMetadataSection(
                                slugController: _slugController,
                                metaTitleController: _metaTitleController,
                                metaDescriptionController:
                                    _metaDescriptionController,
                              ),
                              const SizedBox(height: 100), // Bottom padding
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ) ??
          const Center(child: CircularProgressIndicator()),
    );
  }
}
