// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

class SeoMetadataSection extends StatelessWidget {
  final TextEditingController slugController;
  final TextEditingController metaTitleController;
  final TextEditingController metaDescriptionController;

  const SeoMetadataSection({
    super.key,
    required this.slugController,
    required this.metaTitleController,
    required this.metaDescriptionController,
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
                  Icons.search_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'SEO & Metadata',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Optimize your product for search engines and social media',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Slug Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'URL Slug',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will be used in the product URL. Use only lowercase letters, numbers, and hyphens.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: slugController,
                  decoration: const InputDecoration(
                    labelText: 'URL Slug',
                    hintText: 'my-awesome-product',
                    border: OutlineInputBorder(),
                    prefixText: '/products/',
                    helperText: 'Example: my-awesome-product',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'URL slug is required';
                    }
                    if (!RegExp(r'^[a-z0-9-]+$').hasMatch(value)) {
                      return 'Only lowercase letters, numbers, and hyphens are allowed';
                    }
                    if (value.startsWith('-') || value.endsWith('-')) {
                      return 'Slug cannot start or end with a hyphen';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Meta Title Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meta Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will appear in search engine results and browser tabs. Keep it under 60 characters.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: metaTitleController,
                  decoration: InputDecoration(
                    labelText: 'Meta Title',
                    hintText: 'Enter a compelling title for search engines',
                    border: const OutlineInputBorder(),
                    suffixText: '${metaTitleController.text.length}/60',
                    helperText: 'Recommended: 50-60 characters',
                  ),
                  maxLength: 60,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Meta title is required';
                    }
                    if (value.length < 30) {
                      return 'Meta title should be at least 30 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Meta Description Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meta Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will appear in search engine results. Keep it under 160 characters.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: metaDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Meta Description',
                    hintText:
                        'Enter a compelling description for search engines',
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                    suffixText: '${metaDescriptionController.text.length}/160',
                    helperText: 'Recommended: 150-160 characters',
                  ),
                  maxLines: 3,
                  maxLength: 160,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Meta description is required';
                    }
                    if (value.length < 120) {
                      return 'Meta description should be at least 120 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // SEO Preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Engine Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metaTitleController.text.isNotEmpty
                              ? metaTitleController.text
                              : 'Your product title will appear here',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'yourdomain.com/products/${slugController.text.isNotEmpty ? slugController.text : 'product-slug'}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metaDescriptionController.text.isNotEmpty
                              ? metaDescriptionController.text
                              : 'Your product description will appear here in search results',
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
