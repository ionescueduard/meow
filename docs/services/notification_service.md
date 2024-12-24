# NotificationService Documentation

## Overview
`NotificationService` manages push notifications using Firebase Cloud Messaging (FCM). It handles notification delivery, token management, and different types of notifications for various app events like chat messages, likes, comments, and breeding requests.

## File Location
`lib/services/notification_service.dart`

## Dependencies
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
```

## Main Components

### 1. Service Structure
```dart
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirestoreService _firestoreService;

  NotificationService(this._firestoreService);
}
```

### 2. Key Features

#### Notification Setup
```dart
Future<void> initialize()
Future<void> requestPermission()
Future<String?> getToken()
```
Features:
- FCM initialization
- Permission handling
- Token management
- Channel setup

#### Notification Types
```dart
Future<void> sendChatNotification(...)
Future<void> sendLikeNotification(...)
Future<void> sendCommentNotification(...)
Future<void> sendBreedingRequestNotification(...)
Future<void> sendFollowNotification(...)
```
Features:
- Chat message notifications
- Social interaction notifications
- Breeding request notifications
- Follow notifications

#### Local Notifications
```dart
Future<void> showLocalNotification({
  required String title,
  required String body,
  String? payload,
})
```
Features:
- Local notification display
- Custom sound support
- Action handling
- Payload support

### 3. Implementation Details

#### FCM Setup
```dart
Future<void> initialize() async {
  // Request permission
  await requestPermission();
  
  // Get FCM token
  final token = await getToken();
  
  // Configure message handling
  FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
}
```

#### Message Handling
```dart
Future<void> _handleForegroundMessage(RemoteMessage message)
Future<void> _handleBackgroundMessage(RemoteMessage message)
Future<void> _handleMessageOpenedApp(RemoteMessage message)
```

### 4. Notification Types

#### Chat Notifications
```dart
Future<void> sendChatNotification({
  required String userId,
  required String senderId,
  required String message,
  required String chatRoomId,
})
```

#### Like Notifications
```dart
Future<void> sendLikeNotification({
  required String userId,
  required String postId,
  required UserModel liker,
})
```

#### Comment Notifications
```dart
Future<void> sendCommentNotification({
  required String userId,
  required String postId,
  required String commentId,
  required UserModel commenter,
  required String commentText,
})
```

#### Breeding Request Notifications
```dart
Future<void> sendBreedingRequestNotification({
  required String userId,
  required String catId,
  required UserModel requester,
})
```

### 5. Error Handling
- Permission denied scenarios
- Token refresh failures
- Message delivery failures
- Network errors
- Invalid payload handling

### 6. Security Considerations
- Token security
- Permission management
- Data encryption
- User privacy
- Rate limiting

### 7. Connected Components

#### Services
- FirestoreService
  - User token storage
  - Notification history

#### Models
- UserModel
  - Notification preferences
  - Token storage

### 8. Best Practices
- Token refresh handling
- Battery optimization
- Payload size management
- Priority handling
- Channel organization

### 9. Future Improvements
- Rich notifications
- Notification grouping
- Custom sound support
- Action buttons
- Notification history

## Usage Examples

### Service Initialization
```dart
// Initialize service
await notificationService.initialize();

// Request permissions
await notificationService.requestPermission();
```

### Sending Notifications
```dart
// Send chat notification
await notificationService.sendChatNotification(
  userId: recipientId,
  senderId: currentUserId,
  message: 'Hello!',
  chatRoomId: roomId,
);

// Send like notification
await notificationService.sendLikeNotification(
  userId: postOwnerId,
  postId: postId,
  liker: currentUser,
);
```

### Local Notifications
```dart
// Show local notification
await notificationService.showLocalNotification(
  title: 'New Message',
  body: 'You have a new message',
  payload: 'chat_room_id:123',
);
```

### Token Management
```dart
// Get FCM token
final token = await notificationService.getToken();

// Save token
await notificationService.saveToken(userId, token);
``` 