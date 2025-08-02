import 'package:ecommerce_admin_panel/shared/widgets/cloudinary_image.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class MediaSection extends StatelessWidget {
  final File? mainImage;
  final Uint8List? mainImageBytes;
  final List<File> galleryImages;
  final List<Uint8List> galleryImageBytes;
  final TextEditingController videoLinkController;
  final Function(ImageSource) onPickMainImage;
  final VoidCallback onPickGalleryImages;
  final Function(int) onRemoveGalleryImage;
  final Function(int)? onRemoveExistingGalleryImage;
  final String? existingMainImageUrl;
  final List<String> existingGalleryUrls;

  const MediaSection({
    super.key,
    required this.mainImage,
    required this.mainImageBytes,
    required this.galleryImageBytes,
    required this.galleryImages,
    required this.videoLinkController,
    required this.onPickMainImage,
    required this.onPickGalleryImages,
    required this.onRemoveGalleryImage,
    required this.onRemoveExistingGalleryImage,
    this.existingMainImageUrl,
    this.existingGalleryUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
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
                  Icons.photo_library_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Media',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Main Image Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Main Product Image *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will be the primary image displayed for your product',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Main Image Display
                if (mainImage != null || mainImageBytes != null) ...[
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(mainImage?.path ?? '',
                              fit: BoxFit.contain)
                          : Image.file(mainImage!, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else if (existingMainImageUrl != null &&
                    existingMainImageUrl!.isNotEmpty) ...[
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CloudinaryImage(
                        imageUrl: existingMainImageUrl!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Main Image Upload Buttons
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showImageSourceDialog(context, true),
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text((mainImage == null &&
                              mainImageBytes == null &&
                              (existingMainImageUrl == null ||
                                  existingMainImageUrl!.isEmpty))
                          ? 'Upload Main Image'
                          : 'Change Main Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (mainImage != null || mainImageBytes != null) ...[
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _showRemoveDialog(context, true),
                        icon: const Icon(Icons.delete),
                        label: const Text('Remove'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Gallery Images Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gallery Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add multiple images to showcase your product from different angles',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),

                // Existing Gallery Images
                if (existingGalleryUrls.isNotEmpty) ...[
                  const Text(
                    'Current Gallery Images:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: existingGalleryUrls.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(existingGalleryUrls[index],
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () =>
                                  onRemoveExistingGalleryImage?.call(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // New Gallery Images Grid
                if (galleryImages.isNotEmpty) ...[
                  const Text(
                    'New Gallery Images:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: galleryImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(galleryImages[index].path,
                                      fit: BoxFit.cover)
                                  : Image.file(galleryImages[index],
                                      fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => onRemoveGalleryImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Gallery Upload Button
                ElevatedButton.icon(
                  onPressed: onPickGalleryImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Add Gallery Images'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Video Link Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video Link',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add a YouTube or Vimeo link to showcase your product in action',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: videoLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Video URL',
                    hintText:
                        'https://youtube.com/watch?v=... or https://vimeo.com/...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.video_library),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!value.contains('youtube.com') &&
                          !value.contains('youtu.be') &&
                          !value.contains('vimeo.com')) {
                        return 'Please enter a valid YouTube or Vimeo URL';
                      }
                    }
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, bool isMainImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              isMainImage ? 'Select Main Image Source' : 'Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  onPickMainImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  onPickMainImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveDialog(BuildContext context, bool isMainImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Image'),
          content: Text(
              'Are you sure you want to remove the ${isMainImage ? 'main' : 'gallery'} image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Handle remove main image
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
