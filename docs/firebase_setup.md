# Firebase Configuration Guide

## Firebase Console Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: "meow-app"
4. Enable Google Analytics (recommended)
5. Choose Analytics account or create new

### 2. Configure Authentication
1. Go to Authentication > Get Started
2. Enable the following sign-in methods:
   - Email/Password
   - Google Sign-In
   - Apple Sign-In (for iOS)
3. Configure OAuth consent screen
4. Add authorized domains

### 3. Set Up Cloud Firestore
1. Go to Firestore Database > Create Database
2. Choose production mode
3. Select database location (closest to target users)
4. Set up security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles are readable by anyone, writable by owner
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Cats are readable by anyone, writable by owner
    match /cats/{catId} {
      allow read: if true;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.id == resource.data.ownerId;
    }
    
    // Posts are readable by anyone, writable by author
    match /posts/{postId} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Comments are readable by anyone, writable by author
    match /comments/{commentId} {
      allow read: if true;
      allow write: if request.auth != null;
      allow delete: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == get(/databases/$(database)/documents/posts/$(resource.data.postId)).data.userId);
    }
    
    // Chat rooms are readable and writable by participants
    match /chatRooms/{roomId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
    }
    
    // Messages are readable and writable by chat room participants
    match /messages/{messageId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/chatRooms/$(resource.data.roomId)).data.participantIds;
    }
  }
}
```

### 4. Configure Cloud Storage
1. Go to Storage > Get Started
2. Choose production mode
3. Select storage location
4. Set up security rules:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Cat images
    match /cats/{catId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
        exists(/databases/$(database)/documents/cats/$(catId)) &&
        get(/databases/$(database)/documents/cats/$(catId)).data.ownerId == request.auth.uid;
    }
    
    // Post images
    match /posts/{postId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Chat images
    match /chats/{chatId}/{allPaths=**} {
      allow read: if request.auth != null && 
        exists(/databases/$(database)/documents/chatRooms/$(chatId)) &&
        request.auth.uid in get(/databases/$(database)/documents/chatRooms/$(chatId)).data.participantIds;
      allow write: if request.auth != null;
    }
  }
}
```

### 5. Set Up Cloud Messaging (Push Notifications)
1. Go to Project Settings > Cloud Messaging
2. Generate and download configuration files:
   - iOS: Upload APNs key
   - Android: Download google-services.json

### 6. Create Apps
1. Add iOS app:
   - Enter Bundle ID (com.yourdomain.meow)
   - Download GoogleService-Info.plist
   - Add to iOS project
2. Add Android app:
   - Enter package name
   - Download google-services.json
   - Add to Android project

## Flutter Project Configuration

### 1. Add Firebase Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.15.1
  firebase_auth: ^4.9.0
  cloud_firestore: ^4.9.1
  firebase_storage: ^11.2.6
  firebase_messaging: ^14.6.7
  firebase_analytics: ^10.4.5
```

### 2. Initialize Firebase
In `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

### 3. Platform-Specific Setup

#### iOS (ios/Runner/Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

#### Android (android/app/build.gradle)
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        multiDexEnabled true
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.2.2')
    implementation 'com.google.firebase:firebase-analytics-ktx'
    implementation 'com.google.firebase:firebase-messaging-ktx'
}
```

### 4. Configure Push Notifications

#### iOS (ios/Runner/AppDelegate.swift)
```swift
import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
    }
    
    application.registerForRemoteNotifications()
    Messaging.messaging().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
    </application>
</manifest>
```

## Firebase Indexes

### Create Composite Indexes
1. Go to Firestore Database > Indexes
2. Add the following composite indexes:

#### Posts Collection
- Fields: userId (Ascending), createdAt (Descending)
- Query scope: Collection

#### Comments Collection
- Fields: postId (Ascending), createdAt (Descending)
- Query scope: Collection

#### Cats Collection
- Fields: ownerId (Ascending), name (Ascending)
- Query scope: Collection
- Fields: breed (Ascending), isBreeding (Ascending), location (Ascending)
- Query scope: Collection

#### ChatRooms Collection
- Fields: participantIds (Array), lastMessageTime (Descending)
- Query scope: Collection

## Environment Variables
Create a `.env` file in the project root:
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
FIREBASE_MEASUREMENT_ID=your_measurement_id
```

## Security Best Practices
1. Enable App Check in Firebase Console
2. Set up proper authentication rules
3. Implement rate limiting
4. Enable email verification
5. Set up proper error logging
6. Configure backup and disaster recovery
7. Monitor usage and costs
8. Set up proper security rules for all services
9. Implement proper data validation
10. Use secure session management 