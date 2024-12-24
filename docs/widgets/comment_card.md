# CommentCard Documentation

## Overview
`CommentCard` is a widget that displays a comment on a post, including the author's information, comment text, timestamp, and interaction options. The widget is designed to be used in the post comments screen and supports various user interactions.

## File Location
`lib/widgets/comment_card.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../screens/profile/profile_screen.dart';
```

## Class Definition

### Properties
```dart
class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final UserModel author;
  final VoidCallback? onDelete;
  final VoidCallback? onReport;
  final bool showActions;
  
  const CommentCard({
    Key? key,
    required this.comment,
    required this.author,
    this.onDelete,
    this.onReport,
    this.showActions = true,
  }) : super(key: key);
}
```

### UI Components

#### Main Structure
```dart
Card(
  margin: const EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 4,
  ),
  child: Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 8),
        _buildContent(),
        if (showActions) _buildActions(),
      ],
    ),
  ),
)
```

#### Header
```dart
Widget _buildHeader() {
  return Row(
    children: [
      GestureDetector(
        onTap: () => _navigateToProfile(context),
        child: CircleAvatar(
          backgroundImage: NetworkImage(author.profileImageUrl),
          radius: 16,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author.username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatTimestamp(comment.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      if (showActions) _buildOptionsMenu(),
    ],
  );
}
```

#### Content
```dart
Widget _buildContent() {
  return Text(
    comment.text,
    style: const TextStyle(fontSize: 14),
  );
}
```

#### Actions
```dart
Widget _buildActions() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      TextButton.icon(
        icon: const Icon(Icons.reply),
        label: const Text('Reply'),
        onPressed: _handleReply,
      ),
      if (_isCurrentUserAuthor)
        TextButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
          onPressed: onDelete,
        ),
      if (!_isCurrentUserAuthor)
        TextButton.icon(
          icon: const Icon(Icons.flag_outlined),
          label: const Text('Report'),
          onPressed: onReport,
        ),
    ],
  );
}
```

### Methods

#### Navigation
```dart
void _navigateToProfile(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProfileScreen(userId: author.id),
    ),
  );
}
```

#### Timestamp Formatting
```dart
String _formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  
  if (difference.inDays > 7) {
    return DateFormat('MMM d').format(timestamp);
  } else if (difference.inDays > 0) {
    return '${difference.inDays}d';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m';
  } else {
    return 'now';
  }
}
```

## Usage Example

```dart
// Basic usage
CommentCard(
  comment: commentModel,
  author: authorModel,
)

// With callbacks
CommentCard(
  comment: commentModel,
  author: authorModel,
  onDelete: () => print('Comment deleted'),
  onReport: () => print('Comment reported'),
)

// Without actions
CommentCard(
  comment: commentModel,
  author: authorModel,
  showActions: false,
)
```

## Features

### Display
1. Author avatar
2. Author name
3. Comment text
4. Timestamp
5. Action buttons

### Interactions
1. Navigate to profile
2. Reply to comment
3. Delete comment
4. Report comment
5. Like comment

### Visual Elements
1. Avatar display
2. Timestamp format
3. Action icons
4. Loading states
5. Error states

## Connected Components

### Models
- CommentModel (comment data)
- UserModel (author data)
- PostModel (parent post)

### Services
- FirestoreService (data)
- AuthService (permissions)
- ReportService (moderation)

## State Management

### Local State
- Loading states
- Error states
- UI interactions
- Reply state

### Global State
- User session
- Comment data
- Author data
- Permissions

## Best Practices
1. Handle loading states
2. Manage permissions
3. Format timestamps
4. Cache user data
5. Handle errors

## Performance Considerations
1. Avatar caching
2. State updates
3. Data fetching
4. Memory usage
5. UI responsiveness

## Error Handling
1. Data loading
2. Action failures
3. Navigation errors
4. Permission errors
5. Network issues

## Security Considerations
1. User permissions
2. Content moderation
3. Report handling
4. Data access
5. Action validation

## Customization Options
1. Show/hide actions
2. Layout options
3. Timestamp format
4. Action buttons
5. Style theming

## Accessibility
1. Screen reader support
2. Action labels
3. Touch targets
4. Color contrast
5. Navigation hints 