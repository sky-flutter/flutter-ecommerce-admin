# Cloudinary Setup Guide for Ecommerce Admin Panel

## Overview
This guide will help you set up Cloudinary for image management in your Flutter admin panel. Cloudinary provides:
- **Automatic image optimization** and format conversion
- **CDN delivery** for fast loading
- **Image transformations** (resize, crop, quality)
- **Multiple image formats** (WebP, AVIF, etc.)
- **Organized folder structure**

## Step 1: Create Cloudinary Account

1. Go to [Cloudinary Console](https://cloudinary.com/console)
2. Sign up for a free account
3. Verify your email address

## Step 2: Get Your Credentials

After logging in to Cloudinary Console:

### Cloud Name
- Found in the **Dashboard** section
- Example: `my-cloud-name`

### Upload Preset
1. Go to **Settings** → **Upload**
2. Scroll to **Upload presets**
3. Click **Add upload preset**
4. Set **Preset name**: `ecommerce-upload`
5. Set **Signing Mode**: `Unsigned`
6. Set **Folder**: `ecommerce/products`
7. Click **Save**

## Step 3: Configure Your App

### Update Configuration File
Edit `lib/constants/cloudinary_config.dart`:

```dart
class CloudinaryConfig {
  // Replace with your actual credentials
  static const String cloudName = 'your-actual-cloud-name';
  static const String uploadPreset = 'ecommerce-upload';
  
  // Optional: Admin API credentials for advanced operations
  static const String apiKey = 'your-api-key';
  static const String apiSecret = 'your-api-secret';
  
  // ... rest of the configuration
}
```

### Get Admin API Credentials (Optional)
For advanced operations like image deletion:

1. Go to **Settings** → **Access Keys**
2. Copy your **API Key** and **API Secret**
3. Add them to the config file

## Step 4: Test the Integration

### Run the App
```bash
flutter pub get
flutter run -d chrome
```

### Test Image Upload
1. Navigate to **Products** → **Add Product**
2. Upload an image
3. Check Cloudinary Console to see the uploaded image

## Step 5: Advanced Configuration

### Custom Upload Presets
Create different presets for different use cases:

#### Product Images
- **Preset name**: `product-images`
- **Folder**: `ecommerce/products`
- **Allowed formats**: `jpg, png, webp`
- **Max file size**: `10MB`

#### User Avatars
- **Preset name**: `user-avatars`
- **Folder**: `ecommerce/users/avatars`
- **Allowed formats**: `jpg, png`
- **Max file size**: `5MB`

### Image Transformations
The app automatically applies these transformations:

#### Thumbnails (300x300)
- Format: WebP
- Quality: 80%
- Crop: Fill

#### Medium Images (600x600)
- Format: WebP
- Quality: 85%
- Crop: Fill

#### Large Images (1200x1200)
- Format: WebP
- Quality: 90%
- Crop: Fill

## Step 6: Environment Variables (Production)

For production, use environment variables:

### Create `.env` file
```env
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=ecommerce-upload
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

### Update Configuration
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryConfig {
  static String get cloudName => 
    dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'your-cloud-name';
  static String get uploadPreset => 
    dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'ecommerce-upload';
  // ... etc
}
```

## Step 7: Usage Examples

### Basic Image Upload
```dart
final cloudinary = ref.read(cloudinaryServiceProvider);
final imageUrl = await cloudinary.uploadImage(imageFile);
```

### Optimized Image Display
```dart
CloudinaryThumbnail(
  imageUrl: product.imageUrl,
  size: 100,
)

CloudinaryMediumImage(
  imageUrl: product.imageUrl,
  width: 400,
  height: 300,
)
```

### Custom Transformations
```dart
CloudinaryImage(
  imageUrl: product.imageUrl,
  preset: 'large',
  borderRadius: BorderRadius.circular(8),
)
```

## Step 8: Monitoring and Analytics

### Cloudinary Dashboard
- **Usage**: Monitor bandwidth and storage
- **Analytics**: View image performance
- **Transformations**: Track transformation usage

### Best Practices
1. **Use WebP format** for better compression
2. **Implement lazy loading** for gallery images
3. **Set appropriate quality levels** (80-90%)
4. **Use responsive images** with different sizes
5. **Monitor usage** to stay within free tier limits

## Troubleshooting

### Common Issues

#### Upload Fails
- Check upload preset configuration
- Verify cloud name is correct
- Ensure file size is within limits

#### Images Not Loading
- Check image URL format
- Verify Cloudinary domain access
- Test with direct URL

#### Transformation Not Working
- Verify transformation syntax
- Check if image is from Cloudinary
- Test with Cloudinary URL builder

### Error Messages
- **"Invalid upload preset"**: Check preset name and configuration
- **"File too large"**: Reduce image size or increase limits
- **"Invalid format"**: Check allowed file types

## Security Considerations

### Upload Security
- Use **unsigned uploads** for client-side uploads
- Set **upload presets** with restrictions
- Validate file types and sizes

### Access Control
- Use **folder-based organization**
- Implement **user-specific folders**
- Set **appropriate permissions**

## Performance Optimization

### CDN Benefits
- **Global distribution** for fast loading
- **Automatic optimization** based on device
- **Caching** for improved performance

### Image Optimization
- **Automatic format selection** (WebP, AVIF)
- **Quality optimization** based on content
- **Responsive images** for different screen sizes

## Support Resources

- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Flutter Cloudinary Package](https://pub.dev/packages/cloudinary_public)
- [Cloudinary Support](https://support.cloudinary.com)

## Next Steps

1. **Set up monitoring** for usage and performance
2. **Implement image deletion** with admin API
3. **Add image editing** capabilities
4. **Optimize for mobile** performance
5. **Set up backup** strategies 