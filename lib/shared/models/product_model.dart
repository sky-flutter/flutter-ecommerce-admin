import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String? subcategory;
  final List<String> galleryUrls;
  final double price;
  final double finalPrice;
  final int stock;
  final String videoUrl;
  final int discount;
  final DateTime createdAt;
  final bool isActive;
  final bool isFeatured;
  final bool isNewArrival;
  final List<String> tags;
  final String? brand;
  final double? costPrice;
  final String? sku;
  final String? barcode;
  final String? slug;
  final String? metaTitle;
  final String? metaDescription;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    this.subcategory,
    required this.galleryUrls,
    required this.price,
    required this.finalPrice,
    required this.stock,
    required this.videoUrl,
    required this.discount,
    required this.createdAt,
    required this.isActive,
    required this.isFeatured,
    required this.isNewArrival,
    required this.tags,
    this.brand,
    this.costPrice,
    this.sku,
    this.barcode,
    this.slug,
    this.metaTitle,
    this.metaDescription,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['mainImageUrl'] ?? '',
      category: map['category_name'] ?? map['category'] ?? '',
      subcategory: map['subcategory_name'] ?? map['subcategory'],
      galleryUrls: List<String>.from(map['galleryUrls'] ?? []),
      price: (map['price'] as num).toDouble(),
      finalPrice: (map['finalPrice'] as num?)?.toDouble() ?? (map['price'] as num).toDouble(),
      stock: map['stock'] ?? 0,
      discount: map['discount'] ?? 0,
      videoUrl: map['videoLink'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
      isFeatured: map['isFeatured'] ?? false,
      isNewArrival: map['isNewArrival'] ?? false,
      tags: List<String>.from(map['tags'] ?? []),
      brand: map['brand'],
      costPrice: (map['costPrice'] as num?)?.toDouble(),
      sku: map['sku'],
      barcode: map['barcode'],
      slug: map['slug'],
      metaTitle: map['metaTitle'],
      metaDescription: map['metaDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'mainImageUrl': imageUrl,
      'category': category,
      'subcategory': subcategory,
      'galleryUrls': galleryUrls,
      'price': price,
      'finalPrice': finalPrice,
      'videoLink': videoUrl,
      'stock': stock,
      'discount': discount,
      'createdAt': createdAt,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isNewArrival': isNewArrival,
      'tags': tags,
      'brand': brand,
      'costPrice': costPrice,
      'sku': sku,
      'barcode': barcode,
      'slug': slug,
      'metaTitle': metaTitle,
      'metaDescription': metaDescription,
    };
  }
}
