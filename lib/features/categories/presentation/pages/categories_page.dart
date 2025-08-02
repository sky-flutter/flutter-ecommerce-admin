import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../core/utils/seed_categories.dart';
import '../providers/category_notifier.dart';
import '../providers/category_provider.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Active', 'Inactive'];

  Future<void> _seedInitialCategories() async {
    try {
      await CategorySeeder.seedCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Initial categories seeded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error seeding categories: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(customAuthStateProvider);
    final categoriesAsync = ref.watch(categoriesHierarchyProvider);

    return EnhancedLayoutWrapper(
      currentRoute: '/categories',
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _seedInitialCategories(),
                      icon: const Icon(Icons.grass),
                      label: const Text('Seed Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showAddCategoryDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Category'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search categories...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).cardColor),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    underline: const SizedBox(),
                    items: _filterOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Categories List
          Expanded(
            child: categoriesAsync.when(
              data: (hierarchy) {
                final mainCategories = hierarchy['main'] ?? [];
                final filteredCategories = mainCategories.where((category) {
                  final matchesSearch = category.name
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                  final matchesFilter = _selectedFilter == 'All' ||
                      (_selectedFilter == 'Active' && category.isActive) ||
                      (_selectedFilter == 'Inactive' && !category.isActive);
                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredCategories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No categories found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first category to get started',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    final subcategories = hierarchy[category.id] ?? [];

                    return _buildCategoryCard(category, subcategories);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
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
                      'Error loading categories',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        color: Colors.red[500],
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

  Widget _buildCategoryCard(
      CategoryModel category, List<CategoryModel> subcategories) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              category.isActive ? Colors.green[100] : Colors.grey[100],
          child: Icon(
            Icons.category,
            color: category.isActive ? Colors.green[700] : Colors.grey[600],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: category.isActive ? Colors.green[100] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      category.isActive ? Colors.green[700] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category.description != null &&
                category.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  category.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${subcategories.length} subcategories',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showAddSubcategoryDialog(context, category),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add Subcategory',
            ),
            IconButton(
              onPressed: () => _showEditCategoryDialog(context, category),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Category',
            ),
            IconButton(
              onPressed: () => _toggleCategoryStatus(category),
              icon: Icon(
                category.isActive ? Icons.visibility_off : Icons.visibility,
              ),
              tooltip: category.isActive ? 'Deactivate' : 'Activate',
            ),
            IconButton(
              onPressed: () => _showDeleteConfirmation(context, category),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Category',
              color: Colors.red[400],
            ),
          ],
        ),
        children: [
          if (subcategories.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: subcategories.map((subcategory) {
                  return _buildSubcategoryTile(subcategory);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryTile(CategoryModel subcategory) {
    return ListTile(
      leading: CircleAvatar(
        radius: 16,
        backgroundColor:
            subcategory.isActive ? Colors.blue[100] : Colors.grey[100],
        child: Icon(
          Icons.subdirectory_arrow_right,
          size: 16,
          color: subcategory.isActive ? Colors.blue[700] : Colors.grey[600],
        ),
      ),
      title: Text(
        subcategory.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle:
          subcategory.description != null && subcategory.description!.isNotEmpty
              ? Text(
                  subcategory.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                )
              : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: subcategory.isActive ? Colors.blue[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              subcategory.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 10,
                color:
                    subcategory.isActive ? Colors.blue[700] : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showEditCategoryDialog(context, subcategory),
            icon: const Icon(Icons.edit_outlined, size: 18),
            tooltip: 'Edit Subcategory',
          ),
          IconButton(
            onPressed: () => _toggleCategoryStatus(subcategory),
            icon: Icon(
              subcategory.isActive ? Icons.visibility_off : Icons.visibility,
              size: 18,
            ),
            tooltip: subcategory.isActive ? 'Deactivate' : 'Activate',
          ),
          IconButton(
            onPressed: () => _showDeleteConfirmation(context, subcategory),
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: 'Delete Subcategory',
            color: Colors.red[400],
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  void _showAddSubcategoryDialog(
      BuildContext context, CategoryModel parentCategory) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(parentCategory: parentCategory),
    );
  }

  void _showEditCategoryDialog(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );
  }

  void _showDeleteConfirmation(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCategory(category);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCategoryStatus(CategoryModel category) async {
    try {
      await ref.read(categoryNotifierProvider.notifier).toggleCategoryStatus(
            category.id,
            !category.isActive,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${category.name} ${category.isActive ? 'deactivated' : 'activated'} successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    try {
      await ref
          .read(categoryNotifierProvider.notifier)
          .deleteCategory(category.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.name} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class AddCategoryDialog extends ConsumerStatefulWidget {
  final CategoryModel? parentCategory;

  const AddCategoryDialog({super.key, this.parentCategory});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;
  int _sortOrder = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubcategory = widget.parentCategory != null;

    return AlertDialog(
      title: Text(isSubcategory ? 'Add Subcategory' : 'Add Category'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '0',
                    decoration: const InputDecoration(
                      labelText: 'Sort Order',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _sortOrder = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Active'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveCategory,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final category = CategoryModel(
        id: '', // Will be set by Firestore
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        imageUrl: null,
        parentId: widget.parentCategory?.id,
        isActive: _isActive,
        sortOrder: _sortOrder,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(categoryNotifierProvider.notifier).addCategory(category);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.parentCategory != null ? 'Subcategory' : 'Category'} added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class EditCategoryDialog extends ConsumerStatefulWidget {
  final CategoryModel category;

  const EditCategoryDialog({super.key, required this.category});

  @override
  ConsumerState<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends ConsumerState<EditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late bool _isActive;
  late int _sortOrder;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController =
        TextEditingController(text: widget.category.description ?? '');
    _isActive = widget.category.isActive;
    _sortOrder = widget.category.sortOrder;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Edit ${widget.category.isSubcategory ? 'Subcategory' : 'Category'}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _sortOrder.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Sort Order',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _sortOrder = int.tryParse(value) ?? 0;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Active'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateCategory,
          child: const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updateData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'isActive': _isActive,
        'sortOrder': _sortOrder,
      };

      CategoryModel categoryModel =
          CategoryModel.fromMap(updateData, widget.category.id);

      await ref.read(categoryNotifierProvider.notifier).updateCategory(
            widget.category.id,
            categoryModel,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.category.isSubcategory ? 'Subcategory' : 'Category'} updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
