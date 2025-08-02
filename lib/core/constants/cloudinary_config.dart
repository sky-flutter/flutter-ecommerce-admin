class CloudinaryConfig {
  // Cloudinary credentials
  // Replace these with your actual Cloudinary credentials
  static const String cloudName = 'dmetjcyyf';
  static const String uploadPreset = 'admin_panel_product';

  // Optional: Admin API credentials for advanced operations
  static const String apiKey = '848773435389778';
  static const String apiSecret = '79kb63w4UyXB0f2cXQV64wqQ4KU';

  // Upload settings
  static const String defaultFolder = 'ecommerce/products/main';
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFormats = ['jpg', 'jpeg', 'png', 'webp'];

  // Image transformation presets
  static const Map<String, Map<String, dynamic>> imagePresets = {
    'thumbnail': {
      'width': 300,
      'height': 300,
      'crop': 'fill',
      'quality': 80,
      'format': 'webp',
    },
    'medium': {
      'width': 600,
      'height': 600,
      'crop': 'fill',
      'quality': 85,
      'format': 'webp',
    },
    'large_fill': {
      'width': 1200,
      'height': 1200,
      'crop': 'fill',
      'quality': 90,
      'format': 'webp',
    },
    'original': {
      'quality': 95,
      'format': 'auto',
    },
  };

  // Validation methods
  static bool isValidImageFormat(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedFormats.contains(extension);
  }

  static bool isValidFileSize(int fileSize) {
    return fileSize <= maxFileSize;
  }

  static String getErrorMessage(String fileName, int fileSize) {
    if (!isValidImageFormat(fileName)) {
      return 'Invalid file format. Allowed formats: ${allowedFormats.join(', ')}';
    }
    if (!isValidFileSize(fileSize)) {
      return 'File size too large. Maximum size: ${(maxFileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '';
  }
}
