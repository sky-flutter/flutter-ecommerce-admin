import 'package:cloud_firestore/cloud_firestore.dart';

class SeedData {
  static List<Map<String, dynamic>> getOrderSeedData() {
    return [
      {
        'customerId': 'customer_001',
        'customerName': 'John Smith',
        'customerEmail': 'john.smith@email.com',
        'customerPhone': '+1-555-0123',
        'items': [
          {
            'productId': 'product_001',
            'productName': 'Charcoal Detox Cleanser',
            'productImage':
                'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/charcoal-cleanser.jpg',
            'price': 165.0,
            'quantity': 2,
            'total': 330.0,
          },
          {
            'productId': 'product_002',
            'productName': 'Vitamin C Serum',
            'productImage':
                'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/vitamin-c-serum.jpg',
            'price': 89.0,
            'quantity': 1,
            'total': 89.0,
          },
        ],
        'subtotal': 419.0,
        'tax': 41.9,
        'shipping': 15.0,
        'total': 475.9,
        'currency': 'USD',
        'status': 'delivered',
        'paymentStatus': 'paid',
        'paymentMethod': 'credit_card',
        'shippingAddress': '123 Main St, New York, NY 10001',
        'billingAddress': '123 Main St, New York, NY 10001',
        'trackingNumber': 'TRK123456789',
        'notes': 'Fragile items, handle with care',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 5))),
        'updatedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 2))),
        'shippedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 4))),
        'deliveredAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 2))),
        'couponCode': 'WELCOME10',
        'discountAmount': 41.9,
      },
      {
        'customerId': 'customer_002',
        'customerName': 'Sarah Johnson',
        'customerEmail': 'sarah.johnson@email.com',
        'customerPhone': '+1-555-0456',
        'items': [
          {
            'productId': 'product_003',
            'productName': 'Hyaluronic Acid Moisturizer',
            'productImage':
                'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/moisturizer.jpg',
            'price': 75.0,
            'quantity': 1,
            'total': 75.0,
          },
        ],
        'subtotal': 75.0,
        'tax': 7.5,
        'shipping': 0.0,
        'total': 82.5,
        'currency': 'USD',
        'status': 'shipped',
        'paymentStatus': 'paid',
        'paymentMethod': 'paypal',
        'shippingAddress': '456 Oak Ave, Los Angeles, CA 90210',
        'billingAddress': '456 Oak Ave, Los Angeles, CA 90210',
        'trackingNumber': 'TRK987654321',
        'notes': 'Free shipping applied',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 3))),
        'updatedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1))),
        'shippedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1))),
        'couponCode': 'FREESHIP',
        'discountAmount': 15.0,
      },
      {
        'customerId': 'customer_003',
        'customerName': 'Michael Brown',
        'customerEmail': 'michael.brown@email.com',
        'customerPhone': '+1-555-0789',
        'items': [
          {
            'productId': 'product_004',
            'productName': 'Retinol Night Cream',
            'productImage':
                'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/retinol-cream.jpg',
            'price': 120.0,
            'quantity': 1,
            'total': 120.0,
          },
          {
            'productId': 'product_005',
            'productName': 'Sunscreen SPF 50',
            'productImage':
                'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/sunscreen.jpg',
            'price': 45.0,
            'quantity': 2,
            'total': 90.0,
          },
        ],
        'subtotal': 210.0,
        'tax': 21.0,
        'shipping': 10.0,
        'total': 241.0,
        'currency': 'USD',
        'status': 'processing',
        'paymentStatus': 'paid',
        'paymentMethod': 'credit_card',
        'shippingAddress': '789 Pine St, Chicago, IL 60601',
        'billingAddress': '789 Pine St, Chicago, IL 60601',
        'trackingNumber': '',
        'notes': 'Customer requested expedited shipping',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 12))),
        'updatedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 6))),
      },
      {
        'customerId': 'customer_004',
        'customerName': 'Emily Davis',
        'customerEmail': 'emily.davis@email.com',
        'customerPhone': '+1-555-0321',
        'items': [
          {
            'productId': 'product_001',
            'productName': 'Charcoal Detox Cleanser',
            'productImage':
                'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/charcoal-cleanser.jpg',
            'price': 165.0,
            'quantity': 1,
            'total': 165.0,
          },
        ],
        'subtotal': 165.0,
        'tax': 16.5,
        'shipping': 15.0,
        'total': 196.5,
        'currency': 'USD',
        'status': 'pending',
        'paymentStatus': 'pending',
        'paymentMethod': 'credit_card',
        'shippingAddress': '321 Elm St, Miami, FL 33101',
        'billingAddress': '321 Elm St, Miami, FL 33101',
        'trackingNumber': '',
        'notes': '',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 2))),
        'updatedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 2))),
      },
      {
        'customerId': 'customer_005',
        'customerName': 'David Wilson',
        'customerEmail': 'david.wilson@email.com',
        'customerPhone': '+1-555-0654',
        'items': [
          {
            'productId': 'product_006',
            'productName': 'Face Mask Set',
            'productImage':
                'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/face-mask.jpg',
            'price': 35.0,
            'quantity': 3,
            'total': 105.0,
          },
        ],
        'subtotal': 105.0,
        'tax': 10.5,
        'shipping': 0.0,
        'total': 115.5,
        'currency': 'USD',
        'status': 'cancelled',
        'paymentStatus': 'refunded',
        'paymentMethod': 'credit_card',
        'shippingAddress': '654 Maple Dr, Seattle, WA 98101',
        'billingAddress': '654 Maple Dr, Seattle, WA 98101',
        'trackingNumber': '',
        'notes': 'Customer cancelled due to shipping delay',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 7))),
        'updatedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 6))),
        'refundReason': 'Customer request',
        'refundedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 6))),
      },
    ];
  }

  static List<Map<String, dynamic>> getReviewSeedData() {
    return [
      {
        'productId': 'product_001',
        'productName': 'Charcoal Detox Cleanser',
        'customerId': 'customer_001',
        'customerName': 'John Smith',
        'customerEmail': 'john.smith@email.com',
        'orderId': 'order_001',
        'rating': 5,
        'title': 'Amazing product!',
        'comment':
            'This cleanser is absolutely fantastic! It leaves my skin feeling clean and refreshed without being harsh. I love how it removes all the dirt and oil. Highly recommend!',
        'images': [
          'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/review1.jpg',
        ],
        'isVerified': true,
        'isHelpful': true,
        'helpfulCount': 12,
        'status': 'approved',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 3))),
        'approvedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 2))),
        'isAnonymous': false,
        'reply':
            'Thank you for your wonderful review, John! We\'re glad you love our Charcoal Detox Cleanser.',
        'repliedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1))),
      },
      {
        'productId': 'product_002',
        'productName': 'Vitamin C Serum',
        'customerId': 'customer_002',
        'customerName': 'Sarah Johnson',
        'customerEmail': 'sarah.johnson@email.com',
        'orderId': 'order_002',
        'rating': 4,
        'title': 'Good serum, but expensive',
        'comment':
            'The serum works well and I can see improvement in my skin tone. However, it\'s quite expensive for the amount you get. The packaging is nice and it absorbs quickly.',
        'images': [],
        'isVerified': true,
        'isHelpful': false,
        'helpfulCount': 5,
        'status': 'approved',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 4))),
        'approvedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 3))),
        'isAnonymous': false,
      },
      {
        'productId': 'product_003',
        'productName': 'Hyaluronic Acid Moisturizer',
        'customerId': 'customer_003',
        'customerName': 'Michael Brown',
        'customerEmail': 'michael.brown@email.com',
        'orderId': 'order_003',
        'rating': 5,
        'title': 'Perfect for my dry skin',
        'comment':
            'This moisturizer is a lifesaver for my dry skin! It provides intense hydration without feeling greasy. I use it morning and night and my skin has never looked better.',
        'images': [
          'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/review2.jpg',
          'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/review3.jpg',
        ],
        'isVerified': true,
        'isHelpful': true,
        'helpfulCount': 8,
        'status': 'approved',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 5))),
        'approvedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 4))),
        'isAnonymous': false,
      },
      {
        'productId': 'product_001',
        'productName': 'Charcoal Detox Cleanser',
        'customerId': 'customer_004',
        'customerName': 'Emily Davis',
        'customerEmail': 'emily.davis@email.com',
        'orderId': 'order_004',
        'rating': 3,
        'title': 'Okay, but not for sensitive skin',
        'comment':
            'The cleanser works well for deep cleaning, but it was too harsh for my sensitive skin. It caused some redness and irritation. Might work better for normal to oily skin types.',
        'images': [],
        'isVerified': true,
        'isHelpful': false,
        'helpfulCount': 3,
        'status': 'approved',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 6))),
        'approvedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 5))),
        'isAnonymous': false,
      },
      {
        'productId': 'product_004',
        'productName': 'Retinol Night Cream',
        'customerId': 'customer_005',
        'customerName': 'David Wilson',
        'customerEmail': 'david.wilson@email.com',
        'orderId': 'order_005',
        'rating': 5,
        'title': 'Excellent anti-aging results',
        'comment':
            'I\'ve been using this retinol cream for 3 months and the results are amazing! Fine lines have diminished and my skin texture has improved significantly. Worth every penny!',
        'images': [
          'https://res.cloudinary.com/demo/image/upload/v1/samples/beauty/review4.jpg',
        ],
        'isVerified': true,
        'isHelpful': true,
        'helpfulCount': 15,
        'status': 'approved',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 7))),
        'approvedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 6))),
        'isAnonymous': false,
      },
      {
        'productId': 'product_002',
        'productName': 'Vitamin C Serum',
        'customerId': 'anonymous_001',
        'customerName': 'Anonymous',
        'customerEmail': 'anonymous@email.com',
        'orderId': 'order_006',
        'rating': 2,
        'title': 'Didn\'t work for me',
        'comment':
            'I used this serum for 2 months and didn\'t see any improvement in my skin. It also caused some breakouts. Maybe it\'s not suitable for my skin type.',
        'images': [],
        'isVerified': false,
        'isHelpful': false,
        'helpfulCount': 1,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 6))),
        'isAnonymous': true,
      },
      {
        'productId': 'product_003',
        'productName': 'Hyaluronic Acid Moisturizer',
        'customerId': 'customer_006',
        'customerName': 'Lisa Anderson',
        'customerEmail': 'lisa.anderson@email.com',
        'orderId': 'order_007',
        'rating': 1,
        'title': 'Terrible product',
        'comment':
            'This moisturizer broke me out horribly! My skin was clear before using this and now I have acne all over my face. Waste of money.',
        'images': [],
        'isVerified': true,
        'isHelpful': false,
        'helpfulCount': 0,
        'status': 'rejected',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1))),
        'adminNotes':
            'Review contains inappropriate language and unsubstantiated claims',
        'isAnonymous': false,
      },
      {
        'productId': 'product_005',
        'productName': 'Sunscreen SPF 50',
        'customerId': 'customer_007',
        'customerName': 'Robert Taylor',
        'customerEmail': 'robert.taylor@email.com',
        'orderId': 'order_008',
        'rating': 4,
        'title': 'Good protection, lightweight',
        'comment':
            'This sunscreen provides excellent protection and doesn\'t feel heavy on the skin. It absorbs quickly and doesn\'t leave a white cast. Perfect for daily use.',
        'images': [],
        'isVerified': true,
        'isHelpful': false,
        'helpfulCount': 2,
        'status': 'approved',
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 2))),
        'approvedAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(days: 1))),
        'isAnonymous': false,
      },
    ];
  }
}
