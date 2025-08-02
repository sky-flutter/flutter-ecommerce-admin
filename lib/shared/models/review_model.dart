import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String productName;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String orderId;
  final int rating; // 1-5 stars
  final String title;
  final String comment;
  final List<String> images; // URLs to review images
  final bool isVerified; // Whether the customer actually purchased the product
  final bool isHelpful; // Whether the review is marked as helpful
  final int helpfulCount; // Number of people who found this helpful
  final String status; // pending, approved, rejected, spam
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? approvedAt;
  final String? adminNotes; // Notes from admin about the review
  final bool isAnonymous; // Whether the review is anonymous
  final String? reply; // Admin reply to the review
  final DateTime? repliedAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.orderId,
    required this.rating,
    required this.title,
    required this.comment,
    required this.images,
    required this.isVerified,
    required this.isHelpful,
    required this.helpfulCount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.approvedAt,
    this.adminNotes,
    this.isAnonymous = false,
    this.reply,
    this.repliedAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      orderId: map['orderId'] ?? '',
      rating: map['rating'] ?? 0,
      title: map['title'] ?? '',
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      isVerified: map['isVerified'] ?? false,
      isHelpful: map['isHelpful'] ?? false,
      helpfulCount: map['helpfulCount'] ?? 0,
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      approvedAt: map['approvedAt'] != null
          ? (map['approvedAt'] as Timestamp).toDate()
          : null,
      adminNotes: map['adminNotes'],
      isAnonymous: map['isAnonymous'] ?? false,
      reply: map['reply'],
      repliedAt: map['repliedAt'] != null
          ? (map['repliedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'orderId': orderId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
      'isVerified': isVerified,
      'isHelpful': isHelpful,
      'helpfulCount': helpfulCount,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'approvedAt': approvedAt,
      'adminNotes': adminNotes,
      'isAnonymous': isAnonymous,
      'reply': reply,
      'repliedAt': repliedAt,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? orderId,
    int? rating,
    String? title,
    String? comment,
    List<String>? images,
    bool? isVerified,
    bool? isHelpful,
    int? helpfulCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? approvedAt,
    String? adminNotes,
    bool? isAnonymous,
    String? reply,
    DateTime? repliedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      orderId: orderId ?? this.orderId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      isVerified: isVerified ?? this.isVerified,
      isHelpful: isHelpful ?? this.isHelpful,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      reply: reply ?? this.reply,
      repliedAt: repliedAt ?? this.repliedAt,
    );
  }

  // Helper method to get star rating display
  String get starRating {
    return '★' * rating + '☆' * (5 - rating);
  }

  // Helper method to get status color
  Color get statusColor {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'spam':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
