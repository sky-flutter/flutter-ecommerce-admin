/// Application-wide constants
class AppConstants {
  const AppConstants._();

  // App Information
  static const String appName = 'Ecommerce Admin Panel';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Admin panel for ecommerce management';

  // API Endpoints
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/v1';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String categoriesCollection = 'categories';
  static const String reviewsCollection = 'reviews';
  static const String sessionsCollection = 'sessions';
  static const String settingsCollection = 'settings';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleEditor = 'editor';
  static const String roleViewer = 'viewer';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxProductNameLength = 100;
  static const int maxProductDescriptionLength = 1000;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error Messages
  static const String networkErrorMessage = 'Network error occurred';
  static const String serverErrorMessage = 'Server error occurred';
  static const String unknownErrorMessage = 'An unknown error occurred';
  static const String validationErrorMessage = 'Please check your input';

  // Success Messages
  static const String saveSuccessMessage = 'Saved successfully';
  static const String deleteSuccessMessage = 'Deleted successfully';
  static const String updateSuccessMessage = 'Updated successfully';
}
