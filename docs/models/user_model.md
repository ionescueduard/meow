# UserModel Documentation

## Overview
`UserModel` represents a user in the application. It contains all user-related information including profile data, preferences, and authentication details.

## File Location
`lib/models/user_model.dart`

## Dependencies
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
```

## Class Definition

### Properties
```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? bio;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isOnline;
  final List<String> fcmTokens;
  final Map<String, dynamic> settings;
}
```

### Property Details
- `id`: Unique identifier for the user (Firebase UID)
- `name`: User's display name
- `email`: User's email address
- `photoUrl`: Optional URL to user's profile photo
- `bio`: Optional user biography or description
- `createdAt`: Timestamp of account creation
- `lastActive`: Timestamp of last user activity
- `isOnline`: Current online status
- `fcmTokens`: List of Firebase Cloud Messaging tokens for notifications
- `settings`: User preferences and settings

### Constructor
```dart
UserModel({
  required this.id,
  required this.name,
  required this.email,
  this.photoUrl,
  this.bio,
  required this.createdAt,
  required this.lastActive,
  this.isOnline = false,
  List<String>? fcmTokens,
  Map<String, dynamic>? settings,
}) : fcmTokens = fcmTokens ?? [],
     settings = settings ?? {};
```

### Factory Constructors

#### From Map
```dart
factory UserModel.fromMap(Map<String, dynamic> map, String id) {
  return UserModel(
    id: id,
    name: map['name'] as String,
    email: map['email'] as String,
    photoUrl: map['photoUrl'] as String?,
    bio: map['bio'] as String?,
    createdAt: (map['createdAt'] as Timestamp).toDate(),
    lastActive: (map['lastActive'] as Timestamp).toDate(),
    isOnline: map['isOnline'] as bool? ?? false,
    fcmTokens: List<String>.from(map['fcmTokens'] ?? []),
    settings: Map<String, dynamic>.from(map['settings'] ?? {}),
  );
}
```

#### From Firebase User
```dart
factory UserModel.fromFirebaseUser(User user) {
  return UserModel(
    id: user.uid,
    name: user.displayName ?? 'User',
    email: user.email!,
    photoUrl: user.photoURL,
    createdAt: DateTime.now(),
    lastActive: DateTime.now(),
  );
}
```

### Methods

#### To Map
```dart
Map<String, dynamic> toMap() {
  return {
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'bio': bio,
    'createdAt': Timestamp.fromDate(createdAt),
    'lastActive': Timestamp.fromDate(lastActive),
    'isOnline': isOnline,
    'fcmTokens': fcmTokens,
    'settings': settings,
  };
}
```

#### Copy With
```dart
UserModel copyWith({
  String? name,
  String? photoUrl,
  String? bio,
  DateTime? lastActive,
  bool? isOnline,
  List<String>? fcmTokens,
  Map<String, dynamic>? settings,
}) {
  return UserModel(
    id: id,
    name: name ?? this.name,
    email: email,
    photoUrl: photoUrl ?? this.photoUrl,
    bio: bio ?? this.bio,
    createdAt: createdAt,
    lastActive: lastActive ?? this.lastActive,
    isOnline: isOnline ?? this.isOnline,
    fcmTokens: fcmTokens ?? this.fcmTokens,
    settings: settings ?? this.settings,
  );
}
```

## Usage Examples

### Creating a New User
```dart
final user = UserModel(
  id: 'user123',
  name: 'John Doe',
  email: 'john@example.com',
  createdAt: DateTime.now(),
  lastActive: DateTime.now(),
);
```

### Converting to/from Firestore
```dart
// To Firestore
final data = user.toMap();
await firestore.collection('users').doc(user.id).set(data);

// From Firestore
final doc = await firestore.collection('users').doc(userId).get();
final user = UserModel.fromMap(doc.data()!, doc.id);
```

### Updating User Data
```dart
final updatedUser = user.copyWith(
  name: 'John Smith',
  bio: 'Cat lover and photographer',
  isOnline: true,
);
```

## Connected Components

### Used By
- AuthService
- FirestoreService
- ChatService
- NotificationService

### Related Models
- CatModel (through ownership)
- PostModel (through authorship)
- ChatRoomModel (through participation)
- CommentModel (through authorship)

## Best Practices
1. Always validate email format
2. Handle missing optional fields gracefully
3. Keep FCM tokens list updated
4. Manage online status properly
5. Sanitize user input for name and bio

## Security Considerations
1. Never store sensitive data
2. Validate all input data
3. Control access to user data
4. Protect FCM tokens
5. Handle user deletion properly 