# ChatRoomCard Documentation

## Overview
`ChatRoomCard` is a widget that displays a chat room preview in the chat list. It shows the other participant's information, last message, timestamp, and unread message count. The widget is designed to be used in the chat list screen.

## File Location
`lib/widgets/chat_room_card.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../screens/chat/chat_detail_screen.dart';
```

## Class Definition

### Properties
```dart
class ChatRoomCard extends StatelessWidget {
  final ChatRoomModel chatRoom;
  final UserModel otherUser;
  final VoidCallback? onTap;
  final bool showUnreadCount;
  
  const ChatRoomCard({
    Key? key,
    required this.chatRoom,
    required this.otherUser,
    this.onTap,
    this.showUnreadCount = true,
  }) : super(key: key);
}
```

### UI Components

#### Main Structure
```dart
ListTile(
  leading: _buildAvatar(),
  title: _buildTitle(),
  subtitle: _buildSubtitle(),
  trailing: _buildTrailing(),
  onTap: () => _handleTap(context),
)
```

#### Avatar
```dart
Widget _buildAvatar() {
  return Stack(
    children: [
      CircleAvatar(
        backgroundImage: NetworkImage(otherUser.profileImageUrl),
        radius: 24,
      ),
      if (otherUser.isOnline)
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
        ),
    ],
  );
}
```

#### Title and Subtitle
```dart
Widget _buildTitle() {
  return Row(
    children: [
      Expanded(
        child: Text(
          otherUser.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Text(
        _formatTimestamp(chatRoom.lastMessageTime),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}

Widget _buildSubtitle() {
  return Row(
    children: [
      Expanded(
        child: Text(
          chatRoom.lastMessageText ?? 'No messages yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ),
      if (showUnreadCount && chatRoom.unreadCount > 0)
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Text(
            chatRoom.unreadCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
    ],
  );
}
```

### Methods

#### Navigation
```dart
void _handleTap(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatDetailScreen(
        chatRoom: chatRoom,
        otherUser: otherUser,
      ),
    ),
  );
  onTap?.call();
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
    return DateFormat('E').format(timestamp);
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
ChatRoomCard(
  chatRoom: chatRoomModel,
  otherUser: otherUserModel,
)

// With callback
ChatRoomCard(
  chatRoom: chatRoomModel,
  otherUser: otherUserModel,
  onTap: () => print('Chat room opened'),
)

// Without unread count
ChatRoomCard(
  chatRoom: chatRoomModel,
  otherUser: otherUserModel,
  showUnreadCount: false,
)
```

## Features

### Display
1. User avatar
2. Online status
3. Last message
4. Timestamp
5. Unread count

### Interactions
1. Tap to open chat
2. Long press options
3. Swipe actions
4. Mark as read
5. Mute notifications

### Status Indicators
1. Online/offline
2. Typing status
3. Message status
4. Unread messages
5. Muted state

## Connected Components

### Models
- ChatRoomModel (room data)
- UserModel (participant data)
- MessageModel (last message)

### Services
- FirestoreService (data management)
- AuthService (user context)
- NotificationService (alerts)

## State Management

### Local State
- UI interactions
- Animation states
- Loading states
- Error states

### Global State
- User session
- Chat room data
- Message counts
- Online status

## Best Practices
1. Handle loading states
2. Manage subscriptions
3. Update timestamps
4. Cache user data
5. Handle errors

## Performance Considerations
1. Avatar caching
2. State updates
3. Subscription management
4. Memory usage
5. Animation performance

## Error Handling
1. Network errors
2. Data loading
3. Navigation errors
4. State updates
5. User permissions

## Security Considerations
1. Data access
2. User permissions
3. Content validation
4. Session management
5. Privacy settings

## Customization Options
1. Show/hide elements
2. Layout options
3. Status indicators
4. Interaction callbacks
5. Style theming

## Accessibility
1. Screen reader support
2. Navigation hints
3. Color contrast
4. Touch targets
5. Status announcements 