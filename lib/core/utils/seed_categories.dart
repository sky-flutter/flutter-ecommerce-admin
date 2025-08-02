import 'package:cloud_firestore/cloud_firestore.dart';

class CategorySeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedCategories() async {
    try {
      // Main Categories
      final mainCategories = [
        {
          'name': 'Electronics',
          'description': 'Electronic devices and accessories',
          'isActive': true,
          'sortOrder': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Clothing',
          'description': 'Fashion and apparel',
          'isActive': true,
          'sortOrder': 2,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Books',
          'description': 'Books and publications',
          'isActive': true,
          'sortOrder': 3,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Home & Garden',
          'description': 'Home improvement and garden supplies',
          'isActive': true,
          'sortOrder': 4,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Sports & Outdoors',
          'description': 'Sports equipment and outdoor gear',
          'isActive': true,
          'sortOrder': 5,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Beauty & Health',
          'description': 'Beauty products and health supplies',
          'isActive': true,
          'sortOrder': 6,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Automotive',
          'description': 'Automotive parts and accessories',
          'isActive': true,
          'sortOrder': 7,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Toys & Games',
          'description': 'Toys, games, and entertainment',
          'isActive': true,
          'sortOrder': 8,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
      ];

      // Add main categories
      final categoryRefs = <String, DocumentReference>{};
      for (final categoryData in mainCategories) {
        final docRef = await _db.collection('categories').add(categoryData);
        categoryRefs[categoryData['name'] as String] = docRef;
      }

      // Subcategories
      final subcategories = [
        // Electronics subcategories
        {
          'name': 'Smartphones',
          'description': 'Mobile phones and smartphones',
          'parentId': categoryRefs['Electronics']!.id,
          'isActive': true,
          'sortOrder': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Laptops',
          'description': 'Portable computers and laptops',
          'parentId': categoryRefs['Electronics']!.id,
          'isActive': true,
          'sortOrder': 2,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Tablets',
          'description': 'Tablet computers and iPads',
          'parentId': categoryRefs['Electronics']!.id,
          'isActive': true,
          'sortOrder': 3,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Accessories',
          'description': 'Electronic accessories and peripherals',
          'parentId': categoryRefs['Electronics']!.id,
          'isActive': true,
          'sortOrder': 4,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Audio',
          'description': 'Audio equipment and headphones',
          'parentId': categoryRefs['Electronics']!.id,
          'isActive': true,
          'sortOrder': 5,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },

        // Clothing subcategories
        {
          'name': 'Men',
          'description': 'Men\'s clothing and apparel',
          'parentId': categoryRefs['Clothing']!.id,
          'isActive': true,
          'sortOrder': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Women',
          'description': 'Women\'s clothing and apparel',
          'parentId': categoryRefs['Clothing']!.id,
          'isActive': true,
          'sortOrder': 2,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Kids',
          'description': 'Children\'s clothing and apparel',
          'parentId': categoryRefs['Clothing']!.id,
          'isActive': true,
          'sortOrder': 3,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Shoes',
          'description': 'Footwear for all ages',
          'parentId': categoryRefs['Clothing']!.id,
          'isActive': true,
          'sortOrder': 4,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Accessories',
          'description': 'Fashion accessories and jewelry',
          'parentId': categoryRefs['Clothing']!.id,
          'isActive': true,
          'sortOrder': 5,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },

        // Books subcategories
        {
          'name': 'Fiction',
          'description': 'Fiction books and novels',
          'parentId': categoryRefs['Books']!.id,
          'isActive': true,
          'sortOrder': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Non-Fiction',
          'description': 'Non-fiction books and educational materials',
          'parentId': categoryRefs['Books']!.id,
          'isActive': true,
          'sortOrder': 2,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Educational',
          'description': 'Educational books and textbooks',
          'parentId': categoryRefs['Books']!.id,
          'isActive': true,
          'sortOrder': 3,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Children',
          'description': 'Children\'s books and picture books',
          'parentId': categoryRefs['Books']!.id,
          'isActive': true,
          'sortOrder': 4,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Comics',
          'description': 'Comic books and graphic novels',
          'parentId': categoryRefs['Books']!.id,
          'isActive': true,
          'sortOrder': 5,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },

        // Home & Garden subcategories
        {
          'name': 'Furniture',
          'description': 'Home furniture and decor',
          'parentId': categoryRefs['Home & Garden']!.id,
          'isActive': true,
          'sortOrder': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Decor',
          'description': 'Home decoration and accessories',
          'parentId': categoryRefs['Home & Garden']!.id,
          'isActive': true,
          'sortOrder': 2,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Kitchen',
          'description': 'Kitchen appliances and utensils',
          'parentId': categoryRefs['Home & Garden']!.id,
          'isActive': true,
          'sortOrder': 3,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Garden',
          'description': 'Garden tools and plants',
          'parentId': categoryRefs['Home & Garden']!.id,
          'isActive': true,
          'sortOrder': 4,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Tools',
          'description': 'Home improvement tools',
          'parentId': categoryRefs['Home & Garden']!.id,
          'isActive': true,
          'sortOrder': 5,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },

        // Sports & Outdoors subcategories
        {
          'name': 'Fitness',
          'description': 'Fitness equipment and accessories',
          'parentId': categoryRefs['Sports & Outdoors']!.id,
          'isActive': true,
          'sortOrder': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Outdoor',
          'description': 'Outdoor recreation equipment',
          'parentId': categoryRefs['Sports & Outdoors']!.id,
          'isActive': true,
          'sortOrder': 2,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Team Sports',
          'description': 'Team sports equipment',
          'parentId': categoryRefs['Sports & Outdoors']!.id,
          'isActive': true,
          'sortOrder': 3,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Water Sports',
          'description': 'Water sports and swimming equipment',
          'parentId': categoryRefs['Sports & Outdoors']!.id,
          'isActive': true,
          'sortOrder': 4,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },

        // Beauty & Health subcategories
        {
          'name': 'Skincare',
          'description': 'Skincare products and treatments',
          'parentId': categoryRefs['Beauty & Health']!.id,
          'isActive': true,
          'sortOrder': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Makeup',
          'description': 'Cosmetics and makeup products',
          'parentId': categoryRefs['Beauty & Health']!.id,
          'isActive': true,
          'sortOrder': 2,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Haircare',
          'description': 'Hair care products and styling tools',
          'parentId': categoryRefs['Beauty & Health']!.id,
          'isActive': true,
          'sortOrder': 3,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Fragrances',
          'description': 'Perfumes and fragrances',
          'parentId': categoryRefs['Beauty & Health']!.id,
          'isActive': true,
          'sortOrder': 4,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },

        // Automotive subcategories
        {
          'name': 'Car Parts',
          'description': 'Automotive parts and components',
          'parentId': categoryRefs['Automotive']!.id,
          'isActive': true,
          'sortOrder': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Accessories',
          'description': 'Car accessories and modifications',
          'parentId': categoryRefs['Automotive']!.id,
          'isActive': true,
          'sortOrder': 2,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Tools',
          'description': 'Automotive tools and equipment',
          'parentId': categoryRefs['Automotive']!.id,
          'isActive': true,
          'sortOrder': 3,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Maintenance',
          'description': 'Car maintenance and care products',
          'parentId': categoryRefs['Automotive']!.id,
          'isActive': true,
          'sortOrder': 4,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },

        // Toys & Games subcategories
        {
          'name': 'Board Games',
          'description': 'Board games and tabletop games',
          'parentId': categoryRefs['Toys & Games']!.id,
          'isActive': true,
          'sortOrder': 1,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Action Figures',
          'description': 'Action figures and collectibles',
          'parentId': categoryRefs['Toys & Games']!.id,
          'isActive': true,
          'sortOrder': 2,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Educational',
          'description': 'Educational toys and learning games',
          'parentId': categoryRefs['Toys & Games']!.id,
          'isActive': true,
          'sortOrder': 3,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
        {
          'name': 'Puzzles',
          'description': 'Puzzles and brain teasers',
          'parentId': categoryRefs['Toys & Games']!.id,
          'isActive': true,
          'sortOrder': 4,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        },
      ];

      // Add subcategories
      for (final subcategoryData in subcategories) {
        await _db.collection('categories').add(subcategoryData);
      }

      print('Categories seeded successfully!');
    } catch (e) {
      print('Error seeding categories: $e');
    }
  }
}
