# FeedScreen Documentation

## Overview
`FeedScreen` displays a scrollable feed of posts from users and cats that the current user follows. It includes functionality for creating new posts, liking, commenting, and sharing.

## File Location
`lib/screens/feed/feed_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/post_card.dart';
import '../post/edit_post_screen.dart';
```

## Class Definition

### State
```dart
class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService.instance;
  bool _isLoading = false;
  List<PostModel> _posts = [];
}
```

### Properties
- `_scrollController`: Controls feed scrolling and pagination
- `_firestoreService`: Service for fetching and managing posts
- `_isLoading`: Loading state indicator
- `_posts`: List of posts in the feed

### UI Components

#### App Bar
```dart
AppBar(
  title: const Text('Feed'),
  actions: [
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: _navigateToCreatePost,
    ),
  ],
)
```

#### Feed List
```dart
StreamBuilder<List<PostModel>>(
  stream: _firestoreService.getFeedPosts(),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Center(child: Text('Error loading feed'));
    }

    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final posts = snapshot.data!;
    return ListView.builder(
      controller: _scrollController,
      itemCount: posts.length,
      itemBuilder: (context, index) => PostCard(post: posts[index]),
    );
  },
)
```

### Methods

#### Navigation
```dart
void _navigateToCreatePost() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EditPostScreen()),
  );
}
```

#### Scroll Handling
```dart
void _onScroll() {
  if (_scrollController.position.pixels ==
      _scrollController.position.maxScrollExtent) {
    _loadMorePosts();
  }
}

Future<void> _loadMorePosts() async {
  if (_isLoading) return;

  setState(() => _isLoading = true);
  try {
    final newPosts = await _firestoreService.getMorePosts();
    setState(() {
      _posts.addAll(newPosts);
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
  }
}
```

#### Lifecycle Methods
```dart
@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
}

@override
void dispose() {
  _scrollController.dispose();
  super.dispose();
}
```

## Usage Example

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const FeedScreen();
  }
}
```

## Data Flow

### Post Loading
1. Initial posts loaded through `StreamBuilder`
2. Additional posts loaded on scroll
3. Real-time updates through Firestore stream

### Post Interactions
1. Like/Unlike posts
2. Add comments
3. Share posts
4. Navigate to post details

## Connected Components

### Widgets
- PostCard (displays individual posts)
- LoadingIndicator (shows loading state)
- ErrorDisplay (shows error messages)

### Screens
- EditPostScreen (create/edit posts)
- PostCommentsScreen (view/add comments)
- CatDetailsScreen (view cat profiles)

### Services
- FirestoreService (post data management)
- AuthService (user authentication)
- NotificationService (interaction notifications)

## State Management

### Local State
- Scroll position
- Loading state
- Post list

### Global State
- User authentication
- Post interactions
- Notification state

## Best Practices
1. Implement efficient pagination
2. Handle loading states
3. Manage memory usage
4. Cache post data
5. Handle errors gracefully

## Performance Considerations
1. Lazy loading of images
2. Post list virtualization
3. Efficient post updates
4. Memory management
5. Network optimization

## Error Handling
1. Network errors
2. Loading failures
3. Post interaction errors
4. Navigation errors
5. Authentication errors

## Security Considerations
1. Validate post access
2. Protect user data
3. Handle sensitive content
4. Secure interactions
5. Rate limiting 