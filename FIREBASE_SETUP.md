# Firebase Setup Guide for Ecommerce Admin Panel

## Current Project Configuration
- **Project ID**: adminpanel-625f5
- **API Key**: AIzaSyAwRjdRnz9mSXrtIaFtwMyN8E53ujNJoaA
- **Web App ID**: 1:619643496568:web:932d2bd3e31ca91e6fa58d

## IMMEDIATE FIX FOR OFFLINE ERROR

### Step 1: Update Firestore Security Rules (CRITICAL)
Go to Firebase Console → Firestore Database → Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow all reads and writes for development (REMOVE IN PRODUCTION)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Step 2: Update Storage Security Rules
Go to Firebase Console → Storage → Rules and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

### Step 3: Create Initial Admin User
1. Go to Firebase Console → Authentication → Users
2. Click "Add user"
3. Enter email: `admin@example.com`
4. Enter password: `admin123`
5. Go to Firestore Database → Start collection
6. Collection ID: `users`
7. Document ID: (copy the UID from the created user)
8. Add fields:
   - `email`: `admin@example.com`
   - `displayName`: `Admin User`
   - `role`: `admin`
   - `createdAt`: (current timestamp)

## Prerequisites
- Google account
- Flutter project with web support enabled

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `adminpanel-625f5` (already created)
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Firebase Services

### Authentication
1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable "Email/Password" authentication
3. Click "Save"

### Firestore Database
1. Go to "Firestore Database" → "Create database"
2. Choose "Start in test mode" (for development)
3. Select a location close to your users
4. Click "Done"

### Storage
1. Go to "Storage" → "Get started"
2. Choose "Start in test mode" (for development)
3. Select a location
4. Click "Done"

## Step 3: Configure Platform-Specific Settings

### Web Configuration ✅ COMPLETED
- Firebase config already added to `web/index.html`
- Web app registered in Firebase Console

### Android Configuration
1. In Firebase Console, go to "Project settings"
2. Click "Add app" → "Android" icon
3. Enter package name: `com.app.ecommerce_admin_panel`
4. Download `google-services.json`
5. Replace the placeholder file in `android/app/google-services.json`

### iOS Configuration
1. In Firebase Console, go to "Project settings"
2. Click "Add app" → "iOS" icon
3. Enter bundle ID: `com.example.ecommerceAdminPanel`
4. Download `GoogleService-Info.plist`
5. Replace the placeholder file in `ios/Runner/GoogleService-Info.plist`

## Step 4: Production Security Rules (After Testing)

Once everything works, update Firestore rules to:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'editor']);
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'editor'];
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'editor'];
    }
    
    // Settings collection
    match /settings/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 5: Test Configuration

1. Run the app: `flutter run -d chrome`
2. Try logging in with: `admin@example.com` / `admin123`
3. Verify all features work correctly

## Troubleshooting

### Common Issues:
1. **Authentication errors**: Check if email/password auth is enabled
2. **Permission denied**: Verify Firestore/Storage rules (use test mode first)
3. **Missing dependencies**: Run `flutter pub get`
4. **Build errors**: Check Firebase configuration files
5. **Offline error**: Update security rules to allow all access for development

### Debug Mode:
- Use Firebase Console → Authentication → Users to verify user creation
- Check Firestore Database for data persistence
- Monitor Storage for file uploads

## Security Best Practices

1. **Never commit real API keys** to version control
2. **Use environment variables** for production
3. **Regularly review security rules**
4. **Enable Firebase App Check** for additional security
5. **Monitor usage** in Firebase Console
6. **Set up alerts** for unusual activity

## Support

For Firebase-specific issues:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase Support](https://firebase.google.com/support)

For Flutter-specific issues:
- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Community](https://flutter.dev/community) 