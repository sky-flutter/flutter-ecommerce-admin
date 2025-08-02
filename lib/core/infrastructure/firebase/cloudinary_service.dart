import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../constants/cloudinary_config.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

class CloudinaryService {
  late Cloudinary _cloudinaryUrlGen;

  CloudinaryService() {
    _cloudinaryUrlGen = Cloudinary.fromStringUrl(
        'cloudinary://${CloudinaryConfig.apiKey}:${CloudinaryConfig.apiSecret}@${CloudinaryConfig.cloudName}');
    _cloudinaryUrlGen.config.urlConfig.secure = true;
  }

  /// Upload a single image to Cloudinary (cross-platform)
  Future<String> uploadImage(dynamic imageFile, {String? folder}) async {
    try {
      if (kIsWeb) {
        // Handle web platform
        if (imageFile is Uint8List) {
          return await _uploadImageBytesWeb(imageFile, folder: folder);
        } else {
          throw Exception('Web platform requires Uint8List for image upload');
        }
      } else {
        // Handle mobile platform
        if (imageFile is File) {
          return await _uploadImageFile(imageFile, folder: folder);
        } else {
          throw Exception('Mobile platform requires File for image upload');
        }
      }
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  /// Upload image file (mobile only)
  Future<String> _uploadImageFile(File imageFile, {String? folder}) async {
    try {
      // Validate file before upload
      final fileName = imageFile.path.split('/').last;
      final fileSize = await imageFile.length();

      final errorMessage = CloudinaryConfig.getErrorMessage(fileName, fileSize);
      if (errorMessage.isNotEmpty) {
        throw Exception(errorMessage);
      }

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Determine file extension
      final extension = fileName.split('.').last.toLowerCase();

      return await _uploadBytesDirect(bytes, extension, folder: folder);
    } catch (e) {
      throw Exception('Failed to upload image file: $e');
    }
  }

  /// Upload image bytes (web only)
  Future<String> _uploadImageBytesWeb(Uint8List imageBytes,
      {String? folder}) async {
    try {
      // Determine file type from bytes
      final fileType = _detectFileType(imageBytes);
      final extension = fileType.extension;

      return await _uploadBytesDirect(imageBytes, extension, folder: folder);
    } catch (e) {
      throw Exception('Failed to upload image bytes: $e');
    }
  }

  /// Upload bytes directly using HTTP
  Future<String> _uploadBytesDirect(Uint8List bytes, String extension,
      {String? folder}) async {
    try {
      // Create form data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload'),
      );

      // Add upload preset
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;

      // Add folder if specified
      if (folder != null) {
        request.fields['folder'] = folder;
      }

      // Add public ID
      final publicId =
          '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
      request.fields['public_id'] = publicId;

      // Add the image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'image.$extension',
        ),
      );

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        final url = jsonResponse['secure_url'];
        return url;
      } else {
        throw Exception(
            'Upload failed: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      throw Exception('Failed to upload image bytes to Cloudinary: $e');
    }
  }

  /// Detect file type from bytes
  FileType _detectFileType(Uint8List bytes) {
    if (bytes.length < 4) return FileType.jpeg;

    // Check for JPEG
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return FileType.jpeg;
    }

    // Check for PNG
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return FileType.png;
    }

    // Check for WebP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return FileType.webp;
    }

    // Default to JPEG if unknown
    return FileType.jpeg;
  }

  /// Upload multiple images to Cloudinary (cross-platform)
  Future<List<String>> uploadImages(List<dynamic> imageFiles,
      {String? folder}) async {
    try {
      List<String> uploadedUrls = [];

      for (dynamic imageFile in imageFiles) {
        String url = await uploadImage(imageFile, folder: folder);
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload images to Cloudinary: $e');
    }
  }

  /// Get optimized image URL with transformations (manual approach)
  String getOptimizedImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    String? format,
    int? quality,
    String? crop,
  }) {
    if (!originalUrl.contains('cloudinary.com')) {
      return originalUrl; // Return original if not a Cloudinary URL
    }

    try {
      // Extract public ID from URL
      final publicId = extractPublicId(originalUrl);
      if (publicId == null) return originalUrl;

      // Build transformation string manually
      List<String> transformations = [];

      if (width != null || height != null) {
        String size = '';
        if (width != null && height != null) {
          size = 'w_$width,h_$height';
        } else if (width != null) {
          size = 'w_$width';
        } else if (height != null) {
          size = 'h_$height';
        }
        transformations.add(size);
      }

      if (crop != null) {
        transformations.add('c_$crop');
      }

      if (quality != null) {
        transformations.add('q_$quality');
      }

      if (format != null) {
        transformations.add('f_$format');
      }

      // Build the optimized URL manually
      String transformationString =
          transformations.isNotEmpty ? transformations.join('/') : '';
      final optimizedUrl =
          'https://res.cloudinary.com/${CloudinaryConfig.cloudName}/image/upload/$transformationString/$publicId';

      return optimizedUrl;
    } catch (e) {
      return originalUrl;
    }
  }

  /// Get image URL with preset transformations
  String getPresetUrl(String originalUrl, String preset) {
    final presetConfig = CloudinaryConfig.imagePresets[preset];
    if (presetConfig == null) return originalUrl;

    return getOptimizedImageUrl(
      originalUrl,
      width: presetConfig['width'],
      height: presetConfig['height'],
      crop: presetConfig['crop'],
      quality: presetConfig['quality'],
      format: presetConfig['format'],
    );
  }

  /// Get thumbnail URL (small optimized image)
  String getThumbnailUrl(String originalUrl, {int size = 300}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: size,
      height: size,
      crop: 'fill',
      quality: 80,
      format: 'webp',
    );
  }

  /// Get medium size URL
  String getMediumUrl(String originalUrl, {int size = 600}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: size,
      height: size,
      crop: 'fill',
      quality: 85,
      format: 'webp',
    );
  }

  /// Get large size URL
  String getLargeUrl(String originalUrl, {int size = 1200}) {
    return getOptimizedImageUrl(
      originalUrl,
      width: size,
      height: size,
      crop: 'fill',
      quality: 90,
      format: 'webp',
    );
  }

  /// Delete image from Cloudinary using direct HTTP
  Future<void> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signature = _generateSignature(publicId, timestamp);

      final _ = await http.post(
        Uri.parse(
            'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/destroy'),
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': CloudinaryConfig.apiKey,
          'signature': signature,
        },
      );
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Generate signature for admin operations
  String _generateSignature(String publicId, int timestamp) {
    // This is a simplified signature generation
    // In production, you should use proper HMAC-SHA1
    final data =
        'public_id=$publicId&timestamp=$timestamp${CloudinaryConfig.apiSecret}';
    return data.hashCode.toString();
  }

  /// Extract public ID from Cloudinary URL
  String? extractPublicId(String url) {
    if (!url.contains('cloudinary.com')) return null;

    try {
      Uri uri = Uri.parse(url);
      String path = uri.path;
      List<String> pathParts = path.split('/');

      if (pathParts.length < 5) return null;

      String publicId = pathParts.sublist(4).join('/');
      // Remove file extension
      // publicId = publicId.replaceAll(RegExp(r'\.(jpg|jpeg|png|webp)$'), '');

      return publicId;
    } catch (e) {
      return null;
    }
  }
}

// File type enum
enum FileType {
  jpeg,
  png,
  webp,
  unknown;

  String get extension {
    switch (this) {
      case FileType.jpeg:
        return 'jpg';
      case FileType.png:
        return 'png';
      case FileType.webp:
        return 'webp';
      case FileType.unknown:
        return 'jpg';
    }
  }
}

// Riverpod provider for Cloudinary service
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});
