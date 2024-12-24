# ChatScreen Documentation

## Overview
`ChatScreen` displays a list of active chat rooms and recent conversations. It allows users to view their chat history, start new conversations, and manage their chat notifications.

## File Location
`lib/screens/chat/chat_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../../models/chat_room_model.dart';
import '../../models/user_model.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import 'chat_detail_screen.dart';
```

## Class Definition

### State
```dart
class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService.instance;
  final AuthService _authService = AuthService.instance;
  final TextEditingController _searchController = TextEditingController();
  List<ChatRoomModel> _filteredRooms = [];
  bool _isSearching = false;
}
```

### Properties
- `_chatService`: Service for managing chat functionality
- `_authService`: Service for user authentication
- `_searchController`: Controls search input
- `_filteredRooms`: List of filtered chat rooms
- `_isSearching`: Search state indicator

### UI Components

#### App Bar
```dart
AppBar(
  title: _isSearching
      ? TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search chats...',
            border: InputBorder.none,
          ),
          onChanged: _filterChats,
        )
      : const Text('Chats'),
  actions: [
    IconButton(
      icon: Icon(_isSearching ? Icons.close : Icons.search),
      onPressed: _toggleSearch,
    ),
  ],
)
```

#### Chat List
```dart
StreamBuilder<List<ChatRoomModel>>(
  stream: _chatService.getUserChatRooms(_authService.currentUser!.id),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Center(child: Text('Error loading chats'));
    }

    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final rooms = _isSearching ? _filteredRooms : snapshot.data!;
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) => ChatRoomTile(
        room: rooms[index],
        onTap: () => _navigateToChatDetail(rooms[index]),
      ),
    );
  },
)
```

#### Chat Room Tile
```dart
class ChatRoomTile extends StatelessWidget {
  final ChatRoomModel room;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(room.participantPhotoUrl),
      ),
      title: Text(room.participantName),
      subtitle: Text(
        room.lastMessage ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(room.lastMessageTime),
            style: TextStyle(fontSize: 12),
          ),
          if (room.unreadCount > 0)
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${room.unreadCount}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
```

### Methods

#### Search Handling
```dart
void _toggleSearch() {
  setState(() {
    _isSearching = !_isSearching;
    if (!_isSearching) {
      _searchController.clear();
      _filteredRooms.clear();
    }
  });
}

void _filterChats(String query) {
  if (query.isEmpty) {
    setState(() => _filteredRooms.clear());
    return;
  }

  final allRooms = _chatService.getUserChatRooms(_authService.currentUser!.id);
  setState(() {
    _filteredRooms = allRooms
        .where((room) =>
            room.participantName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  });
}
```

#### Navigation
```dart
void _navigateToChatDetail(ChatRoomModel room) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatDetailScreen(chatRoom: room),
    ),
  );
}
```

## Usage Example

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ChatScreen();
  }
}
```

## Data Flow

### Chat Room Loading
1. Initial rooms loaded through `StreamBuilder`
2. Filtered based on search query
3. Real-time updates through Firestore stream

### Chat Room Updates
1. New messages update last message
2. Unread count updates
3. Typing indicators
4. Online status updates

## Connected Components

### Widgets
- ChatRoomTile (displays chat room)
- OnlineIndicator (shows online status)
- UnreadBadge (shows unread count)

### Screens
- ChatDetailScreen (individual chat)
- UserProfileScreen (view participant profile)

### Services
- ChatService (chat functionality)
- AuthService (user authentication)
- NotificationService (message notifications)

## State Management

### Local State
- Search state
- Filtered rooms
- UI state

### Global State
- User authentication
- Chat notifications
- Online status

## Best Practices
1. Handle message updates
2. Manage unread counts
3. Update typing status
4. Cache chat data
5. Handle errors gracefully

## Performance Considerations
1. Efficient chat updates
2. Message pagination
3. Image caching
4. Memory management
5. Network optimization

## Error Handling
1. Network errors
2. Message failures
3. Search errors
4. Navigation errors
5. Authentication errors

## Security Considerations
1. Validate chat access
2. Protect messages
3. Handle user blocking
4. Secure media sharing
5. Rate limiting 