# PostCommentsScreen Documentation

## Overview
`PostCommentsScreen` displays comments for a specific post and allows users to add new comments. It includes real-time updates, user interactions, and comment management features.

## File Location
`lib/screens/post/post_comments_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
```

## Class Definition

### State
```dart
class _PostCommentsScreenState extends State<PostCommentsScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final AuthService _authService = AuthService.instance;
  final NotificationService _notificationService = NotificationService.instance;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<CommentModel> _comments = [];
  UserModel? _currentUser;
}
```

### Properties
- `_firestoreService`: Service for managing comment data
- `_authService`: Service for user authentication
- `_notificationService`: Service for comment notifications
- `_commentController`: Controls comment input
- `_scrollController`: Controls comment list scrolling
- `_isLoading`: Loading state indicator
- `_comments`: List of comments
- `_currentUser`: Current user data

### UI Components

#### App Bar
```dart
AppBar(
  title: const Text('Comments'),
  actions: [
    if (widget.post.userId == _authService.currentUser!.id)
      IconButton(
        icon: const Icon(Icons.delete_sweep),
        onPressed: _showDeleteAllDialog,
      ),
  ],
)
```

#### Comment List
```dart
StreamBuilder<List<CommentModel>>(
  stream: _firestoreService.getPostComments(widget.post.id),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Center(child: Text('Error loading comments'));
    }

    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final comments = snapshot.data!;
    return ListView.builder(
      controller: _scrollController,
      itemCount: comments.length,
      itemBuilder: (context, index) => CommentTile(
        comment: comments[index],
        onDelete: _canDeleteComment(comments[index])
            ? () => _deleteComment(comments[index])
            : null,
      ),
    );
  },
)
```

#### Comment Input
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8.0),
  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,
    border: Border(top: BorderSide(color: Colors.grey.shade300)),
  ),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            hintText: 'Add a comment...',
            border: InputBorder.none,
          ),
          maxLines: null,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.send),
        onPressed: _submitComment,
      ),
    ],
  ),
)
```

### Methods

#### Comment Management
```dart
Future<void> _submitComment() async {
  final text = _commentController.text.trim();
  if (text.isEmpty) return;

  setState(() => _isLoading = true);
  try {
    final comment = CommentModel(
      postId: widget.post.id,
      userId: _authService.currentUser!.id,
      text: text,
      createdAt: DateTime.now(),
    );

    await _firestoreService.addComment(comment);
    await _notificationService.sendCommentNotification(
      widget.post.userId,
      widget.post.id,
      text,
    );

    _commentController.clear();
    _scrollToBottom();
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}

Future<void> _deleteComment(CommentModel comment) async {
  setState(() => _isLoading = true);
  try {
    await _firestoreService.deleteComment(comment.id);
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### UI Helpers
```dart
void _scrollToBottom() {
  if (_scrollController.hasClients) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

bool _canDeleteComment(CommentModel comment) {
  final currentUserId = _authService.currentUser!.id;
  return comment.userId == currentUserId || widget.post.userId == currentUserId;
}
```

## Usage Example

```dart
class PostCard extends StatelessWidget {
  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.comment),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PostCommentsScreen(post: post),
        ),
      ),
    );
  }
}
```

## Data Flow

### Comment Loading
1. Initial comments loaded through `StreamBuilder`
2. Real-time updates for new comments
3. Comment deletion updates

### Comment Submission
1. Text input validation
2. Comment creation
3. Notification sending
4. UI update

## Connected Components

### Widgets
- CommentTile (displays comments)
- LoadingIndicator (loading states)
- DeleteDialog (comment deletion)
- UserAvatar (comment author)

### Screens
- PostScreen (parent post)
- UserProfileScreen (comment authors)

### Services
- FirestoreService (comment management)
- AuthService (user context)
- NotificationService (comment alerts)

## State Management

### Local State
- Comment input
- Loading states
- Scroll position
- Selected comments

### Global State
- User session
- Comment data
- Notification state

## Best Practices
1. Handle real-time updates
2. Manage notifications
3. Validate inputs
4. Cache comment data
5. Handle errors gracefully

## Performance Considerations
1. Comment pagination
2. Efficient updates
3. Scroll optimization
4. Memory management
5. Network optimization

## Error Handling
1. Input validation errors
2. Network errors
3. Permission errors
4. Navigation errors
5. Notification errors

## Security Considerations
1. Validate comment access
2. Protect user data
3. Handle permissions
4. Secure notifications
5. Rate limiting 