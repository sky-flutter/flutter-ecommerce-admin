import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../shared/services/currency_provider.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../core/constants/app_theme.dart';

class PromotionsPage extends ConsumerStatefulWidget {
  const PromotionsPage({super.key});

  @override
  ConsumerState<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends ConsumerState<PromotionsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Promotion List
  List<Map<String, dynamic>> _promotions = [];

  // Add/Edit Promotion Form
  final _promotionNameController = TextEditingController();
  final _promotionCodeController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _maximumUsesController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Promotion Settings
  String _discountType = 'percentage'; // percentage or fixed
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isEditing = false;
  String? _editingPromotionId;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  @override
  void dispose() {
    _promotionNameController.dispose();
    _promotionCodeController.dispose();
    _discountAmountController.dispose();
    _minimumOrderController.dispose();
    _maximumUsesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPromotions() async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final snapshot = await firestore.collectionStream('promotions').first;

      setState(() {
        _promotions = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading promotions: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _savePromotion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestore = ref.read(firestoreServiceProvider);

      final promotionData = {
        'name': _promotionNameController.text,
        'code': _promotionCodeController.text.toUpperCase(),
        'discountType': _discountType,
        'discountAmount':
            double.tryParse(_discountAmountController.text) ?? 0.0,
        'minimumOrder': double.tryParse(_minimumOrderController.text) ?? 0.0,
        'maximumUses': int.tryParse(_maximumUsesController.text) ?? 0,
        'description': _descriptionController.text,
        'startDate': _startDate,
        'endDate': _endDate,
        'isActive': _isActive,
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };

      if (_isEditing && _editingPromotionId != null) {
        await firestore.updateDocument(
            'promotions', _editingPromotionId!, promotionData);
      } else {
        await firestore.addDocument('promotions', promotionData);
      }

      await _loadPromotions();
      _resetForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Promotion updated successfully!'
                : 'Promotion created successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving promotion: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _editPromotion(Map<String, dynamic> promotion) {
    setState(() {
      _isEditing = true;
      _editingPromotionId = promotion['id'];
      _promotionNameController.text = promotion['name'] ?? '';
      _promotionCodeController.text = promotion['code'] ?? '';
      _discountType = promotion['discountType'] ?? 'percentage';
      _discountAmountController.text =
          promotion['discountAmount']?.toString() ?? '';
      _minimumOrderController.text =
          promotion['minimumOrder']?.toString() ?? '';
      _maximumUsesController.text = promotion['maximumUses']?.toString() ?? '';
      _descriptionController.text = promotion['description'] ?? '';
      _startDate = promotion['startDate']?.toDate();
      _endDate = promotion['endDate']?.toDate();
      _isActive = promotion['isActive'] ?? true;
    });
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingPromotionId = null;
      _promotionNameController.clear();
      _promotionCodeController.clear();
      _discountAmountController.clear();
      _minimumOrderController.clear();
      _maximumUsesController.clear();
      _descriptionController.clear();
      _discountType = 'percentage';
      _startDate = null;
      _endDate = null;
      _isActive = true;
    });
  }

  Future<void> _deletePromotion(String promotionId) async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.deleteDocument('promotions', promotionId);
      await _loadPromotions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Promotion deleted successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting promotion: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? DateTime.now()
          : DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return EnhancedLayoutWrapper(
      currentRoute: '/promotions',
      child: Scaffold(
        body: userRoleAsync?.when(
              data: (role) {
                if (role != 'admin' && role != 'editor') {
                  return const Center(
                    child: Text(
                        'Access denied. You need admin or editor permissions.'),
                  );
                }

                if (_isLoadingData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Row(
                  children: [
                    // Promotions List
                    Expanded(
                      flex: 2,
                      child: _buildPromotionsList(),
                    ),
                    const SizedBox(width: 24),
                    // Add/Edit Form
                    Expanded(
                      flex: 1,
                      child: _buildPromotionForm(),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ) ??
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildPromotionsList() {
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
                  Icons.local_offer,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Promotions & Discounts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.add),
                  label: const Text('New Promotion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_promotions.isEmpty)
              const Center(
                child: Text(
                  'No promotions found. Create your first promotion!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _promotions.length,
                  itemBuilder: (context, index) {
                    final promotion = _promotions[index];
                    return _buildPromotionCard(promotion);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard(Map<String, dynamic> promotion) {
    final isActive = promotion['isActive'] ?? false;
    final startDate = promotion['startDate']?.toDate();
    final endDate = promotion['endDate']?.toDate();
    final isExpired = endDate?.isBefore(DateTime.now()) ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive && !isExpired
              ? AppTheme.successColor
              : AppTheme.errorColor,
          child: Icon(
            isActive && !isExpired ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          promotion['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${promotion['code'] ?? ''}'),
            Text(
              'Discount: ${promotion['discountAmount']?.toString() ?? ''}${promotion['discountType'] == 'percentage' ? '%' : '\$'}',
            ),
            if (startDate != null && endDate != null)
              Text(
                'Valid: ${startDate.toString().split(' ')[0]} - ${endDate.toString().split(' ')[0]}',
                style: TextStyle(
                  color: isExpired ? AppTheme.errorColor : AppTheme.neutral600,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editPromotion(promotion);
                break;
              case 'delete':
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Promotion'),
                    content: Text(
                        'Are you sure you want to delete "${promotion['name']}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deletePromotion(promotion['id']);
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isEditing ? Icons.edit : Icons.add,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isEditing ? 'Edit Promotion' : 'New Promotion',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _promotionNameController,
                  decoration: const InputDecoration(
                    labelText: 'Promotion Name *',
                    hintText: 'Summer Sale 2024',
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Promotion name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _promotionCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Promotion Code *',
                    hintText: 'SUMMER2024',
                    prefixIcon: Icon(Icons.code),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Promotion code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _discountType,
                        decoration: const InputDecoration(
                          labelText: 'Discount Type',
                          prefixIcon: Icon(Icons.percent),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'percentage',
                              child: Text('Percentage (%)')),
                          DropdownMenuItem(
                              value: 'fixed', child: Text('Fixed Amount (\$)')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _discountType = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _discountAmountController,
                        decoration: InputDecoration(
                          labelText: 'Discount Amount *',
                          hintText:
                              _discountType == 'percentage' ? '10' : '5.00',
                          prefixIcon: Icon(_discountType == 'percentage'
                              ? Icons.percent
                              : Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Discount amount is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _minimumOrderController,
                        decoration: InputDecoration(
                          labelText:
                              'Minimum Order (${ref.watch(currencySymbolProvider)})',
                          hintText: '50.00',
                          prefixIcon: const Icon(Icons.shopping_cart),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _maximumUsesController,
                        decoration: const InputDecoration(
                          labelText: 'Maximum Uses',
                          hintText: '100',
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter promotion description...',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Start Date'),
                        subtitle: Text(
                            _startDate?.toString().split(' ')[0] ?? 'Not set'),
                        leading: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('End Date'),
                        subtitle: Text(
                            _endDate?.toString().split(' ')[0] ?? 'Not set'),
                        leading: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  subtitle: const Text('Enable this promotion'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: AppTheme.primaryColor,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _savePromotion,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isLoading
                            ? 'Saving...'
                            : (_isEditing ? 'Update' : 'Create')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _resetForm,
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            side: const BorderSide(color: AppTheme.errorColor),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
