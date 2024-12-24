# ChatRoomModel Documentation

## Overview
`ChatRoomModel` represents a chat room in the application. It contains information about the participants, messages, and chat room status.

## File Location
`lib/models/chat_room_model.dart`

## Dependencies
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
```

## Class Definition

### Properties
```dart
class ChatRoomModel {
  final String id;
  final List<String> participantIds;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCount;
  final Map<String, bool> typing;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;
}
```

### Property Details
- `id`: Unique identifier for the chat room
- `participantIds`: List of participant user IDs
- `lastMessage`: Content of the last message
- `lastMessageSenderId`: ID of the last message sender
- `lastMessageTime`: Timestamp of the last message
- `unreadCount`: Map of user IDs to their unread message counts
- `typing`: Map of user IDs to their typing status
- `createdAt`: Creation timestamp
- `metadata`: Additional chat room metadata

### Constructor
```dart
ChatRoomModel({
  required this.id,
  required this.participantIds,
  this.lastMessage,
  this.lastMessageSenderId,
  required this.lastMessageTime,
  Map<String, int>? unreadCount,
  Map<String, bool>? typing,
  required this.createdAt,
  Map<String, dynamic>? metadata,
}) : unreadCount = unreadCount ?? {},
     typing = typing ?? {},
     metadata = metadata ?? {};
```

### Factory Constructors

#### From Map
```dart
factory ChatRoomModel.fromMap(Map<String, dynamic> map, String id) {
  return ChatRoomModel(
    id: id,
    participantIds: List<String>.from(map['participantIds']),
    lastMessage: map['lastMessage'] as String?,
    lastMessageSenderId: map['lastMessageSenderId'] as String?,
    lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
    unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    typing: Map<String, bool>.from(map['typing'] ?? {}),
    createdAt: (map['createdAt'] as Timestamp).toDate(),
    metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
  );
}
```

### Methods

#### To Map
```dart
Map<String, dynamic> toMap() {
  return {
    'participantIds': participantIds,
    'lastMessage': lastMessage,
    'lastMessageSenderId': lastMessageSenderId,
    'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    'unreadCount': unreadCount,
    'typing': typing,
    'createdAt': Timestamp.fromDate(createdAt),
    'metadata': metadata,
  };
}
```

#### Copy With
```dart
ChatRoomModel copyWith({
  List<String>? participantIds,
  String? lastMessage,
  String? lastMessageSenderId,
  DateTime? lastMessageTime,
  Map<String, int>? unreadCount,
  Map<String, bool>? typing,
  Map<String, dynamic>? metadata,
}) {
  return ChatRoomModel(
    id: id,
    participantIds: participantIds ?? this.participantIds,
    lastMessage: lastMessage ?? this.lastMessage,
    lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
    lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    unreadCount: unreadCount ?? this.unreadCount,
    typing: typing ?? this.typing,
    createdAt: createdAt,
    metadata: metadata ?? this.metadata,
  );
}
```

#### Utility Methods
```dart
bool hasParticipant(String userId) => participantIds.contains(userId);

int getUnreadCount(String userId) => unreadCount[userId] ?? 0;

bool isTyping(String userId) => typing[userId] ?? false;

ChatRoomModel updateTypingStatus(String userId, bool isTyping) {
  final newTyping = Map<String, bool>.from(typing);
  newTyping[userId] = isTyping;
  return copyWith(typing: newTyping);
}

ChatRoomModel incrementUnreadCount(String userId) {
  final newUnreadCount = Map<String, int>.from(unreadCount);
  newUnreadCount[userId] = (newUnreadCount[userId] ?? 0) + 1;
  return copyWith(unreadCount: newUnreadCount);
}

ChatRoomModel resetUnreadCount(String userId) {
  final newUnreadCount = Map<String, int>.from(unreadCount);
  newUnreadCount[userId] = 0;
  return copyWith(unreadCount: newUnreadCount);
}
```

## Usage Examples

### Creating a New Chat Room
```dart
final chatRoom = ChatRoomModel(
  id: 'room123',
  participantIds: ['user1', 'user2'],
  lastMessageTime: DateTime.now(),
  createdAt: DateTime.now(),
);
```

### Updating Last Message
```dart
final updatedRoom = chatRoom.copyWith(
  lastMessage: 'Hello!',
  lastMessageSenderId: 'user1',
  lastMessageTime: DateTime.now(),
);
```

### Managing Typing Status
```dart
// Set user as typing
final roomWithTyping = chatRoom.updateTypingStatus('user1', true);

// Check if user is typing
final isUserTyping = chatRoom.isTyping('user1');
```

### Managing Unread Counts
```dart
// Increment unread count for user
final roomWithUnread = chatRoom.incrementUnreadCount('user2');

// Reset unread count for user
final roomWithReset = chatRoom.resetUnreadCount('user2');
```

## Connected Components

### Used By
- ChatService
- ChatScreen
- ChatDetailScreen
- NotificationService

### Related Models
- UserModel (through participation)
- ChatMessageModel (through parent-child relationship)

## Best Practices
1. Validate participant IDs
2. Handle typing timeouts
3. Maintain unread counts accurately
4. Clean up typing status
5. Handle participant changes

## Security Considerations
1. Validate participant access
2. Protect chat history
3. Handle participant removal
4. Secure metadata
5. Control room creation 