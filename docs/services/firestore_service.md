# FirestoreService Documentation

## Overview
`FirestoreService` is the core service that handles all interactions with Firebase Firestore database. It manages data operations for users, cats, posts, comments, breeding requests, and social interactions.

## File Location
`lib/services/firestore_service.dart`

## Dependencies
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/cat_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import 'notification_service.dart';
import 'package:geolocator/geolocator.dart';
```

## Main Components

### 1. Service Structure
```dart
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService;

  FirestoreService(this._notificationService);
}
```

### 2. Key Features

#### User Management
```dart
Future<void> saveUser(UserModel user)
Future<UserModel?> getUser(String userId)
Stream<UserModel?> getUserStream(String userId)
```
Features:
- User creation and updates
- User data retrieval
- Real-time user data streaming

#### Cat Management
```dart
Future<void> saveCat(CatModel cat)
Future<void> deleteCat(String catId)
Stream<List<CatModel>> getUserCats(String userId)
Future<CatModel?> getCat(String catId)
Stream<List<CatModel>> searchCats({...})
```
Features:
- Cat CRUD operations
- Cat search with filters
- Location-based filtering
- Breeding availability filtering

#### Post Management
```dart
Future<void> savePost(PostModel post)
Future<void> deletePost(String postId)
Stream<List<PostModel>> getFeedPosts()
Stream<List<PostModel>> getUserPosts(String userId)
Stream<List<PostModel>> getCatPosts(String catId)
```
Features:
- Post creation and deletion
- Feed generation
- User-specific posts
- Cat-specific posts

#### Comment System
```dart
Future<void> addComment(CommentModel comment)
Stream<List<CommentModel>> getPostComments(String postId)
Future<void> deleteComment(String commentId)
```
Features:
- Comment creation and deletion
- Comment retrieval by post
- Notification integration

#### Social Features
```dart
Future<void> followUser(String userId, String followerId)
Future<void> unfollowUser(String userId, String followerId)
Stream<bool> isFollowing(String userId, String followerId)
Stream<List<UserModel>> getFollowers(String userId)
Stream<List<UserModel>> getFollowing(String userId)
```
Features:
- Follow/unfollow functionality
- Follower/following lists
- Real-time relationship status

#### Breeding System
```dart
Future<void> sendBreedingRequest({...})
Stream<List<Map<String, dynamic>>> getBreedingRequests(String userId)
Future<void> updateBreedingRequestStatus(String requestId, String status)
```
Features:
- Breeding request creation
- Request status management
- Request filtering and retrieval
- Notification integration

### 3. Implementation Details

#### Location-Based Search
```dart
Stream<List<CatModel>> searchCats({
  String? breed,
  String? gender,
  Map<String, dynamic>? location,
}) {
  // Implementation details for location-based search
}
```

#### Batch Operations
```dart
// Example of batch operation in followUser
final batch = _db.batch();
batch.set(...);
batch.set(...);
await batch.commit();
```

### 4. Error Handling
- Null safety throughout
- Optional chaining
- Try-catch blocks where needed
- Proper error propagation

### 5. Performance Considerations
- Efficient queries
- Batch operations
- Index usage
- Query limiting
- Stream management

### 6. Connected Components

#### Models
- UserModel
- CatModel
- PostModel
- CommentModel

#### Services
- NotificationService
- AuthService (indirectly)

### 7. Best Practices
- Use of transactions for atomic operations
- Proper data validation
- Efficient query construction
- Stream cleanup
- Security rules compliance

### 8. Future Improvements
- Caching layer
- Offline support
- Pagination
- Enhanced search capabilities
- Data analytics integration

## Usage Examples

### User Operations
```dart
// Save user
await firestoreService.saveUser(userModel);

// Get user stream
final userStream = firestoreService.getUserStream(userId);
```

### Cat Operations
```dart
// Save cat
await firestoreService.saveCat(catModel);

// Search cats
final catsStream = firestoreService.searchCats(
  breed: 'Persian',
  gender: 'Female',
  location: {
    'latitude': 37.7749,
    'longitude': -122.4194,
    'maxDistance': 50,
  },
);
```

### Social Operations
```dart
// Follow user
await firestoreService.followUser(userId, followerId);

// Check following status
final isFollowingStream = firestoreService.isFollowing(userId, followerId);
``` 