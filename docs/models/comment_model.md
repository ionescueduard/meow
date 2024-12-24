# CommentModel Documentation

## Overview
`CommentModel` represents a comment on a post. It contains information about the comment content, author, and associated post.

## File Location
`lib/models/comment_model.dart`

## Dependencies
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
```

## Class Definition

### Properties
```dart
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final List<String> likedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;
}
```

### Property Details
- `id`: Unique identifier for the comment
- `postId`: ID of the post being commented on
- `userId`: ID of the comment author
- `content`: Text content of the comment
- `likedBy`: List of user IDs who liked the comment
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp
- `metadata`: Additional comment metadata

### Constructor
```dart
CommentModel({
  required this.id,
  required this.postId,
  required this.userId,
  required this.content,
  List<String>? likedBy,
  required this.createdAt,
  required this.updatedAt,
  Map<String, dynamic>? metadata,
}) : likedBy = likedBy ?? [],
     metadata = metadata ?? {};
```

### Factory Constructors

#### From Map
```dart
factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
  return CommentModel(
    id: id,
    postId: map['postId'] as String,
    userId: map['userId'] as String,
    content: map['content'] as String,
    likedBy: List<String>.from(map['likedBy'] ?? []),
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
    'postId': postId,
    'userId': userId,
    'content': content,
    'likedBy': likedBy,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'metadata': metadata,
  };
}
```

#### Copy With
```dart
CommentModel copyWith({
  String? content,
  List<String>? likedBy,
  Map<String, dynamic>? metadata,
}) {
  return CommentModel(
    id: id,
    postId: postId,
    userId: userId,
    content: content ?? this.content,
    likedBy: likedBy ?? this.likedBy,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    metadata: metadata ?? this.metadata,
  );
}
```

#### Like/Unlike Methods
```dart
CommentModel like(String userId) {
  if (likedBy.contains(userId)) return this;
  return copyWith(likedBy: [...likedBy, userId]);
}

CommentModel unlike(String userId) {
  if (!likedBy.contains(userId)) return this;
  return copyWith(likedBy: likedBy.where((id) => id != userId).toList());
}

bool isLikedBy(String userId) => likedBy.contains(userId);
```

## Usage Examples

### Creating a New Comment
```dart
final comment = CommentModel(
  id: 'comment123',
  postId: 'post123',
  userId: 'user123',
  content: 'Great photo!',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Handling Likes
```dart
// Like a comment
final likedComment = comment.like('user456');

// Unlike a comment
final unlikedComment = comment.unlike('user456');

// Check if liked by user
final isLiked = comment.isLikedBy('user456');
```

### Updating Content
```dart
final updatedComment = comment.copyWith(
  content: 'Updated comment text',
);
```

### Converting to/from Firestore
```dart
// To Firestore
final data = comment.toMap();
await firestore
    .collection('posts')
    .doc(comment.postId)
    .collection('comments')
    .doc(comment.id)
    .set(data);

// From Firestore
final doc = await firestore
    .collection('posts')
    .doc(postId)
    .collection('comments')
    .doc(commentId)
    .get();
final comment = CommentModel.fromMap(doc.data()!, doc.id);
```

## Connected Components

### Used By
- FirestoreService
- PostCard
- PostCommentsScreen
- NotificationService

### Related Models
- PostModel (through parent-child relationship)
- UserModel (through authorship)

## Best Practices
1. Validate comment content
2. Handle empty content
3. Maintain like counts
4. Validate user permissions
5. Handle comment edits

## Security Considerations
1. Validate author permissions
2. Protect user interactions
3. Control editing rights
4. Handle deletion properly
5. Prevent spam 