# PostModel Documentation

## Overview
`PostModel` represents a post in the application. It contains information about the post content, associated media, author details, and social interactions like likes and comments.

## File Location
`lib/models/post_model.dart`

## Dependencies
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
```

## Class Definition

### Properties
```dart
class PostModel {
  final String id;
  final String userId;
  final String content;
  final List<String> mediaUrls;
  final List<String> catIds;
  final List<String> likedBy;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
}
```

### Property Details
- `id`: Unique identifier for the post
- `userId`: Author's user ID
- `content`: Text content of the post
- `mediaUrls`: List of media (images/videos) URLs
- `catIds`: List of referenced cat IDs
- `likedBy`: List of user IDs who liked the post
- `commentCount`: Number of comments on the post
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp
- `metadata`: Additional post metadata

### Constructor
```dart
PostModel({
  required this.id,
  required this.userId,
  required this.content,
  List<String>? mediaUrls,
  List<String>? catIds,
  List<String>? likedBy,
  this.commentCount = 0,
  required this.createdAt,
  required this.updatedAt,
  Map<String, dynamic>? metadata,
}) : mediaUrls = mediaUrls ?? [],
     catIds = catIds ?? [],
     likedBy = likedBy ?? [],
     metadata = metadata ?? {};
```

### Factory Constructors

#### From Map
```dart
factory PostModel.fromMap(Map<String, dynamic> map, String id) {
  return PostModel(
    id: id,
    userId: map['userId'] as String,
    content: map['content'] as String,
    mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
    catIds: List<String>.from(map['catIds'] ?? []),
    likedBy: List<String>.from(map['likedBy'] ?? []),
    commentCount: map['commentCount'] as int? ?? 0,
    createdAt: (map['createdAt'] as Timestamp).toDate(),
    updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
  );
}
```

### Methods

#### To Map
```dart
Map<String, dynamic> toMap() {
  return {
    'userId': userId,
    'content': content,
    'mediaUrls': mediaUrls,
    'catIds': catIds,
    'likedBy': likedBy,
    'commentCount': commentCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'metadata': metadata,
  };
}
```

#### Copy With
```dart
PostModel copyWith({
  String? content,
  List<String>? mediaUrls,
  List<String>? catIds,
  List<String>? likedBy,
  int? commentCount,
  Map<String, dynamic>? metadata,
}) {
  return PostModel(
    id: id,
    userId: userId,
    content: content ?? this.content,
    mediaUrls: mediaUrls ?? this.mediaUrls,
    catIds: catIds ?? this.catIds,
    likedBy: likedBy ?? this.likedBy,
    commentCount: commentCount ?? this.commentCount,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    metadata: metadata ?? this.metadata,
  );
}
```

#### Like/Unlike Methods
```dart
PostModel like(String userId) {
  if (likedBy.contains(userId)) return this;
  return copyWith(likedBy: [...likedBy, userId]);
}

PostModel unlike(String userId) {
  if (!likedBy.contains(userId)) return this;
  return copyWith(likedBy: likedBy.where((id) => id != userId).toList());
}
```

## Usage Examples

### Creating a New Post
```dart
final post = PostModel(
  id: 'post123',
  userId: 'user123',
  content: 'Check out my cat!',
  mediaUrls: ['image_url1', 'image_url2'],
  catIds: ['cat123'],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Handling Likes
```dart
// Like a post
final likedPost = post.like('user456');

// Unlike a post
final unlikedPost = post.unlike('user456');
```

### Updating Comment Count
```dart
final updatedPost = post.copyWith(
  commentCount: post.commentCount + 1,
);
```

### Adding Media
```dart
final updatedPost = post.copyWith(
  mediaUrls: [...post.mediaUrls, 'new_image_url'],
);
```

## Connected Components

### Used By
- FirestoreService
- FeedScreen
- PostCard
- PostDetailsScreen

### Related Models
- UserModel (through authorship)
- CatModel (through references)
- CommentModel (through parent-child relationship)

## Best Practices
1. Validate content length
2. Handle media URLs properly
3. Maintain comment count accuracy
4. Validate cat references
5. Handle metadata carefully

## Security Considerations
1. Validate author permissions
2. Protect user interactions
3. Secure media access
4. Control editing rights
5. Handle deletion properly 