# PostCard Documentation

## Overview
`PostCard` is a reusable widget that displays a social media post in the app. It includes the post content, images, user information, and interactive elements like likes and comments. The widget is designed to be used in feed screens and user profiles.

## File Location
`lib/widgets/post_card.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../screens/post/post_comments_screen.dart';
import './full_screen_image.dart';
```

## Class Definition

### Properties
```dart
class PostCard extends StatefulWidget {
  final PostModel post;
  final UserModel author;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool showActions;
  final bool isDetailView;
  
  const PostCard({
    Key? key,
    required this.post,
    required this.author,
    this.onLike,
    this.onComment,
    this.onShare,
    this.showActions = true,
    this.isDetailView = false,
  }) : super(key: key);
}
```

### State
```dart
class _PostCardState extends State<PostCard> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final AuthService _authService = AuthService.instance;
  bool _isLiked = false;
  bool _isLoading = false;
  List<String> _catNames = [];
}
```

### UI Components

#### Main Structure
```dart
Card(
  margin: const EdgeInsets.all(8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(),
      if (widget.post.imageUrls.isNotEmpty) _buildImageGallery(),
      _buildContent(),
      if (widget.showActions) _buildActions(),
      _buildFooter(),
    ],
  ),
)
```

#### Header
```dart
Widget _buildHeader() {
  return ListTile(
    leading: CircleAvatar(
      backgroundImage: NetworkImage(widget.author.profileImageUrl),
    ),
    title: Text(widget.author.username),
    subtitle: Text(
      _formatTimestamp(widget.post.createdAt),
    ),
    trailing: _buildOptionsMenu(),
  );
}
```

#### Image Gallery
```dart
Widget _buildImageGallery() {
  return SizedBox(
    height: 300,
    child: PageView.builder(
      itemCount: widget.post.imageUrls.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _showFullScreenImage(index),
        child: Image.network(
          widget.post.imageUrls[index],
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}
```

#### Actions
```dart
Widget _buildActions() {
  return Row(
    children: [
      IconButton(
        icon: Icon(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          color: _isLiked ? Colors.red : null,
        ),
        onPressed: _handleLike,
      ),
      IconButton(
        icon: const Icon(Icons.comment_outlined),
        onPressed: _navigateToComments,
      ),
      IconButton(
        icon: const Icon(Icons.share_outlined),
        onPressed: _handleShare,
      ),
    ],
  );
}
```

### Methods

#### Like Handling
```dart
Future<void> _handleLike() async {
  if (_isLoading) return;
  
  setState(() => _isLoading = true);
  try {
    await _firestoreService.togglePostLike(
      widget.post.id,
      _authService.currentUser!.id,
    );
    setState(() => _isLiked = !_isLiked);
    widget.onLike?.call();
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### Navigation
```dart
void _navigateToComments() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PostCommentsScreen(post: widget.post),
    ),
  );
}

void _showFullScreenImage(int index) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FullScreenImage(
        imageUrl: widget.post.imageUrls[index],
        heroTag: '${widget.post.id}_$index',
      ),
    ),
  );
}
```

#### Options Menu
```dart
Widget _buildOptionsMenu() {
  return PopupMenuButton<String>(
    onSelected: _handleMenuOption,
    itemBuilder: (context) => [
      if (_isCurrentUserAuthor)
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit Post'),
        ),
      if (_isCurrentUserAuthor)
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete Post'),
        ),
      const PopupMenuItem(
        value: 'report',
        child: Text('Report Post'),
      ),
    ],
  );
}
```

## Usage Example

```dart
// Basic usage
PostCard(
  post: postModel,
  author: authorModel,
)

// With callbacks
PostCard(
  post: postModel,
  author: authorModel,
  onLike: () => print('Post liked'),
  onComment: () => print('Comment added'),
  onShare: () => print('Post shared'),
)

// Detail view
PostCard(
  post: postModel,
  author: authorModel,
  isDetailView: true,
  showActions: false,
)
```

## Features

### Post Display
1. User information
2. Post content
3. Image gallery
4. Timestamp
5. Associated cats

### Interactions
1. Like/unlike
2. Comment
3. Share
4. Report
5. Edit/delete

### Navigation
1. Full-screen images
2. Comments screen
3. User profile
4. Cat profiles

## Connected Components

### Models
- PostModel (post data)
- UserModel (author data)
- CatModel (referenced cats)

### Services
- FirestoreService (data management)
- AuthService (user context)
- StorageService (images)

## State Management

### Local State
- Like status
- Loading states
- UI interactions
- Image gallery state

### Global State
- User session
- Post data
- Like counts
- Comment counts

## Best Practices
1. Handle loading states
2. Manage permissions
3. Optimize images
4. Handle errors
5. Validate actions

## Performance Considerations
1. Image optimization
2. Lazy loading
3. State updates
4. Animation smoothness
5. Memory management

## Error Handling
1. Network errors
2. Permission errors
3. Image loading
4. Action failures
5. Navigation errors

## Security Considerations
1. User permissions
2. Content validation
3. Action verification
4. Data access
5. Report handling

## Customization Options
1. Show/hide actions
2. Layout options
3. Image display
4. Interaction callbacks
5. Menu options

## Accessibility
1. Image descriptions
2. Action labels
3. Content scaling
4. Color contrast
5. Navigation support 