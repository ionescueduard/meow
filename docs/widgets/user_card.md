# UserCard Documentation

## Overview
`UserCard` is a widget that displays a user's profile information in a card format. It shows the user's avatar, username, bio, and follow status. The widget is designed to be used in search results, follower/following lists, and user suggestions.

## File Location
`lib/widgets/user_card.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../screens/profile/profile_screen.dart';
```

## Class Definition

### Properties
```dart
class UserCard extends StatelessWidget {
  final UserModel user;
  final bool showFollowButton;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;
  final VoidCallback? onTap;
  final bool isFollowing;
  
  const UserCard({
    Key? key,
    required this.user,
    this.showFollowButton = true,
    this.onFollow,
    this.onUnfollow,
    this.onTap,
    this.isFollowing = false,
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
  child: InkWell(
    onTap: onTap ?? () => _navigateToProfile(context),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: _buildUserInfo(),
          ),
          if (showFollowButton && !_isCurrentUser)
            _buildFollowButton(),
        ],
      ),
    ),
  ),
)
```

#### Avatar
```dart
Widget _buildAvatar() {
  return CircleAvatar(
    radius: 24,
    backgroundImage: NetworkImage(user.profileImageUrl),
  );
}
```

#### User Info
```dart
Widget _buildUserInfo() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        user.username,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      if (user.bio != null && user.bio!.isNotEmpty)
        Text(
          user.bio!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      Row(
        children: [
          Text(
            '${user.followersCount} followers',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${user.catsCount} cats',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    ],
  );
}
```

#### Follow Button
```dart
Widget _buildFollowButton() {
  return TextButton(
    onPressed: isFollowing ? onUnfollow : onFollow,
    style: TextButton.styleFrom(
      backgroundColor: isFollowing ? Colors.grey[200] : Colors.blue,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    ),
    child: Text(
      isFollowing ? 'Following' : 'Follow',
      style: TextStyle(
        color: isFollowing ? Colors.black87 : Colors.white,
        fontSize: 14,
      ),
    ),
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
      builder: (_) => ProfileScreen(userId: user.id),
    ),
  );
}
```

## Usage Example

```dart
// Basic usage
UserCard(
  user: userModel,
)

// With follow button and callbacks
UserCard(
  user: userModel,
  showFollowButton: true,
  isFollowing: true,
  onFollow: () => print('User followed'),
  onUnfollow: () => print('User unfollowed'),
)

// Without follow button
UserCard(
  user: userModel,
  showFollowButton: false,
)

// With custom tap handler
UserCard(
  user: userModel,
  onTap: () => print('User card tapped'),
)
```

## Features

### Display
1. User avatar
2. Username
3. Bio text
4. Followers count
5. Cats count

### Interactions
1. Follow/unfollow
2. Navigate to profile
3. Custom tap action
4. Loading states
5. Error handling

### Visual Elements
1. Avatar display
2. Follow button
3. Text layout
4. Loading indicators
5. Error states

## Connected Components

### Models
- UserModel (user data)
- CatModel (cats count)
- FollowModel (follow status)

### Services
- FirestoreService (data)
- AuthService (permissions)
- StorageService (images)

## State Management

### Local State
- Loading states
- Error states
- UI interactions
- Follow status

### Global State
- User session
- Follow data
- Profile data
- Permissions

## Best Practices
1. Handle loading states
2. Manage permissions
3. Cache user data
4. Handle errors
5. Validate actions

## Performance Considerations
1. Avatar caching
2. Data prefetching
3. State updates
4. Memory usage
5. UI responsiveness

## Error Handling
1. Image loading
2. Data fetching
3. Action failures
4. Permission errors
5. Network issues

## Security Considerations
1. User permissions
2. Data access
3. Follow validation
4. Image security
5. Profile privacy

## Customization Options
1. Show/hide elements
2. Layout options
3. Button styles
4. Text display
5. Avatar size

## Accessibility
1. Screen reader support
2. Action labels
3. Touch targets
4. Color contrast
5. Navigation hints 