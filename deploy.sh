#!/bin/bash

echo "🚀 Starting deployment process..."

# Build the Flutter web app
echo "📦 Building Flutter web app..."
flutter build web --release

# Deploy to Firebase Hosting
echo "🌐 Deploying to Firebase Hosting..."
firebase deploy --only hosting

echo "✅ Deployment complete!"
echo "🌍 Your app is live at: https://adminpanel-new-2024.web.app" 