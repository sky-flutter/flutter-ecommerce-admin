import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ecommerce_admin_panel/shared/models/category_model.dart';

class ProductInfoSection extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final CategoryModel? selectedCategory;
  final CategoryModel? selectedSubcategory;
  final TextEditingController brandController;
  final TextEditingController tagsController;
  final Function(CategoryModel?) onCategoryChanged;
  final Function(CategoryModel?) onSubcategoryChanged;
  final List<CategoryModel> categories;
  final List<CategoryModel> subcategories;

  const ProductInfoSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.selectedSubcategory,
    required this.brandController,
    required this.tagsController,
    required this.onCategoryChanged,
    required this.onSubcategoryChanged,
    required this.categories,
    required this.subcategories,
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
                  Icons.info_outline,
                  color: Theme.of(context).iconTheme.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Product Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Name and Brand Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name *',
                      hintText: 'Enter product name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Product name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      hintText: 'Enter brand name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                hintText: 'Enter product description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Category and Subcategory Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<CategoryModel>(
                    value: selectedCategory != null &&
                            selectedCategory!.name.isNotEmpty
                        ? selectedCategory
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<CategoryModel>(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: onCategoryChanged,
                    validator: (value) {
                      if (value == null || value.name.isEmpty) {
                        return 'Category is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: selectedCategory != null &&
                          selectedCategory!.name.isNotEmpty &&
                          subcategories.isNotEmpty
                      ? DropdownButtonFormField<CategoryModel>(
                          value: selectedSubcategory != null &&
                                  selectedSubcategory!.name.isNotEmpty
                              ? selectedSubcategory
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Subcategory',
                            border: OutlineInputBorder(),
                          ),
                          items: subcategories.map((subcategory) {
                            return DropdownMenuItem<CategoryModel>(
                              value: subcategory,
                              child: Text(subcategory.name),
                            );
                          }).toList(),
                          onChanged: onSubcategoryChanged,
                        )
                      : DropdownButtonFormField<CategoryModel>(
                          value: null,
                          decoration: const InputDecoration(
                            labelText: 'Subcategory',
                            border: OutlineInputBorder(),
                          ),
                          items: const [],
                          onChanged: null,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Tags
            TextFormField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText:
                    'Enter tags separated by commas (e.g., electronics, wireless, bluetooth)',
                border: OutlineInputBorder(),
                helperText: 'Tags help customers find your product',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
