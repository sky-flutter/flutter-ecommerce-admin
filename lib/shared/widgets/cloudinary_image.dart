import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/infrastructure/firebase/cloudinary_service.dart';

class CloudinaryImage extends ConsumerWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? preset; // 'thumbnail', 'medium', 'large', 'original'

  const CloudinaryImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.preset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudinary = ref.read(cloudinaryServiceProvider);

    // Get optimized URL based on preset or dimensions
    String optimizedUrl = imageUrl;
    if (imageUrl.contains('cloudinary.com')) {
      if (preset != null) {
        optimizedUrl = cloudinary.getPresetUrl(imageUrl, preset!);
      } else if (width != null || height != null) {
        optimizedUrl = cloudinary.getOptimizedImageUrl(
          imageUrl,
          width: width?.toInt(),
          height: height?.toInt(),
          crop: 'scale',
          quality: 85,
          format: 'webp',
        );
      }
    }

    Widget imageWidget = Image.network(
      optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 32,
                ),
              ),
            );
      },
    );

    // Apply border radius if specified
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

// Convenience widgets for common use cases
class CloudinaryThumbnail extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const CloudinaryThumbnail({
    super.key,
    required this.imageUrl,
    this.size = 100,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CloudinaryImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      preset: 'thumbnail',
      borderRadius: borderRadius,
    );
  }
}

class CloudinaryMediumImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CloudinaryMediumImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CloudinaryImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      preset: 'medium',
      borderRadius: borderRadius,
    );
  }
}

class CloudinaryLargeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const CloudinaryLargeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return CloudinaryImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      preset: 'large_fill',
      borderRadius: borderRadius,
    );
  }
}
