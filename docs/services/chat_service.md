# ChatService Documentation

## Overview
`ChatService` manages real-time chat functionality using Firebase Firestore. It handles chat rooms, messages, typing indicators, read receipts, and message notifications.

## File Location
`lib/services/chat_service.dart`

## Dependencies
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart';
import 'notification_service.dart';
```

## Main Components

### 1. Service Structure
```dart
class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService;

  ChatService(this._notificationService);
}
```

### 2. Key Features

#### Chat Room Management
```dart
Future<ChatRoomModel> createChatRoom(List<String> userIds)
Stream<List<ChatRoomModel>> getUserChatRooms(String userId)
Future<void> deleteChatRoom(String roomId)
```
Features:
- Chat room creation
- Room listing
- Room deletion
- Participant management

#### Message Management
```dart
Future<void> sendMessage(ChatMessageModel message)
Stream<List<ChatMessageModel>> getRoomMessages(String roomId)
Future<void> deleteMessage(String messageId, String roomId)
Future<void> updateMessage(ChatMessageModel message)
```
Features:
- Message sending
- Real-time message streaming
- Message deletion
- Message editing
- Media message support

#### Typing Indicators
```dart
Future<void> setTypingStatus(String roomId, String userId, bool isTyping)
Stream<Map<String, bool>> getTypingStatuses(String roomId)
```
Features:
- Real-time typing status
- Multiple user support
- Status cleanup

#### Read Receipts
```dart
Future<void> markAsRead(String roomId, String userId)
Stream<Map<String, DateTime>> getReadReceipts(String roomId)
```
Features:
- Message read status
- Last read timestamp
- Unread count tracking

### 3. Implementation Details

#### Chat Room Creation
```dart
Future<ChatRoomModel> createChatRoom(List<String> userIds) async {
  final room = ChatRoomModel(
    id: _db.collection('chatRooms').doc().id,
    participantIds: userIds,
    createdAt: DateTime.now(),
    lastMessage: null,
    lastMessageTime: DateTime.now(),
  );
  
  await _db.collection('chatRooms').doc(room.id).set(room.toMap());
  return room;
}
```

#### Message Handling
```dart
Future<void> sendMessage(ChatMessageModel message) async {
  final batch = _db.batch();
  
  // Save message
  batch.set(
    _db.collection('chatRooms/${message.roomId}/messages').doc(message.id),
    message.toMap(),
  );
  
  // Update room's last message
  batch.update(
    _db.collection('chatRooms').doc(message.roomId),
    {
      'lastMessage': message.content,
      'lastMessageTime': message.timestamp,
      'lastMessageSenderId': message.senderId,
    },
  );
  
  await batch.commit();
  
  // Send notification
  await _notificationService.sendChatNotification(...);
}
```

### 4. Error Handling
- Network errors
- Permission errors
- Invalid room/message IDs
- Participant validation
- Media upload failures

### 5. Performance Considerations
- Message pagination
- Media optimization
- Batch operations
- Query optimization
- Cache management

### 6. Connected Components

#### Models
- ChatRoomModel
- ChatMessageModel
- UserModel

#### Services
- NotificationService
- StorageService (for media)

### 7. Best Practices
- Message validation
- Media size limits
- Participant limits
- Status cleanup
- Cache management

### 8. Future Improvements
- Message reactions
- Message threading
- Voice messages
- Video calls
- Message search

## Usage Examples

### Chat Room Operations
```dart
// Create chat room
final room = await chatService.createChatRoom(['user1', 'user2']);

// Get user's chat rooms
final roomsStream = chatService.getUserChatRooms(userId);
```

### Message Operations
```dart
// Send message
await chatService.sendMessage(ChatMessageModel(
  roomId: roomId,
  senderId: currentUserId,
  content: 'Hello!',
  type: MessageType.text,
));

// Get room messages
final messagesStream = chatService.getRoomMessages(roomId);
```

### Typing Status
```dart
// Set typing status
await chatService.setTypingStatus(roomId, userId, true);

// Listen to typing statuses
final typingStream = chatService.getTypingStatuses(roomId);
```

### Read Receipts
```dart
// Mark as read
await chatService.markAsRead(roomId, userId);

// Get read receipts
final receiptsStream = chatService.getReadReceipts(roomId);
``` 