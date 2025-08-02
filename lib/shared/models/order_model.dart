import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String currency;
  final String
      status; // pending, confirmed, processing, shipped, delivered, cancelled, refunded
  final String paymentStatus; // pending, paid, failed, refunded
  final String paymentMethod; // credit_card, paypal, bank_transfer, etc.
  final String shippingAddress;
  final String billingAddress;
  final String trackingNumber;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final String? couponCode;
  final double? discountAmount;
  final String? refundReason;
  final DateTime? refundedAt;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.billingAddress,
    required this.trackingNumber,
    required this.notes,
    required this.createdAt,
    this.updatedAt,
    this.shippedAt,
    this.deliveredAt,
    this.couponCode,
    this.discountAmount,
    this.refundReason,
    this.refundedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerEmail: map['customerEmail'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      shipping: (map['shipping'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      currency: map['currency'] ?? 'USD',
      status: map['status'] ?? 'pending',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? '',
      shippingAddress: map['shippingAddress'] ?? '',
      billingAddress: map['billingAddress'] ?? '',
      trackingNumber: map['trackingNumber'] ?? '',
      notes: map['notes'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      shippedAt: map['shippedAt'] != null
          ? (map['shippedAt'] as Timestamp).toDate()
          : null,
      deliveredAt: map['deliveredAt'] != null
          ? (map['deliveredAt'] as Timestamp).toDate()
          : null,
      couponCode: map['couponCode'],
      discountAmount: map['discountAmount'] != null
          ? (map['discountAmount'] as num).toDouble()
          : null,
      refundReason: map['refundReason'],
      refundedAt: map['refundedAt'] != null
          ? (map['refundedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'currency': currency,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'trackingNumber': trackingNumber,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'shippedAt': shippedAt,
      'deliveredAt': deliveredAt,
      'couponCode': couponCode,
      'discountAmount': discountAmount,
      'refundReason': refundReason,
      'refundedAt': refundedAt,
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? total,
    String? currency,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? shippingAddress,
    String? billingAddress,
    String? trackingNumber,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    String? couponCode,
    double? discountAmount,
    String? refundReason,
    DateTime? refundedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
      refundReason: refundReason ?? this.refundReason,
      refundedAt: refundedAt ?? this.refundedAt,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] ?? 0,
      total: (map['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }
}
