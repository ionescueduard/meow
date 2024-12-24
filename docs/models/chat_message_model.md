# ChatMessageModel Documentation

## Overview
`ChatMessageModel` represents a message within a chat room. It contains information about the message content, sender, type, and status.

## File Location
`lib/models/chat_message_model.dart`

## Dependencies
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
```

## Class Definition

### Enums
```dart
enum MessageType {
  text,
  image,
  video,
  catProfile,
  system,
}
```

### Properties
```dart
class ChatMessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, DateTime> readBy;
  final String? referencedCatId;
  final Map<String, dynamic> metadata;
}
```

### Property Details
- `id`: Unique identifier for the message
- `roomId`: ID of the chat room containing this message
- `senderId`: ID of the message sender
- `content`: Message content (text or media URL)
- `type`: Type of message (text/image/video/catProfile/system)
- `timestamp`: Message creation timestamp
- `readBy`: Map of user IDs to their read timestamps
- `referencedCatId`: Optional ID of a referenced cat profile
- `metadata`: Additional message metadata

### Constructor
```dart
ChatMessageModel({
  required this.id,
  required this.roomId,
  required this.senderId,
  required this.content,
  required this.type,
  required this.timestamp,
  Map<String, DateTime>? readBy,
  this.referencedCatId,
  Map<String, dynamic>? metadata,
}) : readBy = readBy ?? {},
     metadata = metadata ?? {};
```

### Factory Constructors

#### From Map
```dart
factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
  return ChatMessageModel(
    id: id,
    roomId: map['roomId'] as String,
    senderId: map['senderId'] as String,
    content: map['content'] as String,
    type: MessageType.values.firstWhere(
      (e) => e.toString() == map['type'],
      orElse: () => MessageType.text,
    ),
    timestamp: (map['timestamp'] as Timestamp).toDate(),
    readBy: (map['readBy'] as Map<String, dynamic>?)?.map(
      (k, v) => MapEntry(k, (v as Timestamp).toDate()),
    ) ?? {},
    referencedCatId: map['referencedCatId'] as String?,
    metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
  );
}
```

### Methods

#### To Map
```dart
Map<String, dynamic> toMap() {
  return {
    'roomId': roomId,
    'senderId': senderId,
    'content': content,
    'type': type.toString(),
    'timestamp': Timestamp.fromDate(timestamp),
    'readBy': readBy.map((k, v) => MapEntry(k, Timestamp.fromDate(v))),
    'referencedCatId': referencedCatId,
    'metadata': metadata,
  };
}
```

#### Copy With
```dart
ChatMessageModel copyWith({
  String? content,
  MessageType? type,
  Map<String, DateTime>? readBy,
  String? referencedCatId,
  Map<String, dynamic>? metadata,
}) {
  return ChatMessageModel(
    id: id,
    roomId: roomId,
    senderId: senderId,
    content: content ?? this.content,
    type: type ?? this.type,
    timestamp: timestamp,
    readBy: readBy ?? this.readBy,
    referencedCatId: referencedCatId ?? this.referencedCatId,
    metadata: metadata ?? this.metadata,
  );
}
```

#### Utility Methods
```dart
bool isReadBy(String userId) => readBy.containsKey(userId);

DateTime? getReadTime(String userId) => readBy[userId];

ChatMessageModel markAsRead(String userId) {
  final newReadBy = Map<String, DateTime>.from(readBy);
  newReadBy[userId] = DateTime.now();
  return copyWith(readBy: newReadBy);
}

bool get isTextMessage => type == MessageType.text;
bool get isImageMessage => type == MessageType.image;
bool get isVideoMessage => type == MessageType.video;
bool get isCatProfileMessage => type == MessageType.catProfile;
bool get isSystemMessage => type == MessageType.system;
```

## Usage Examples

### Creating a New Message
```dart
final message = ChatMessageModel(
  id: 'msg123',
  roomId: 'room123',
  senderId: 'user123',
  content: 'Hello!',
  type: MessageType.text,
  timestamp: DateTime.now(),
);
```

### Creating a Media Message
```dart
final imageMessage = ChatMessageModel(
  id: 'msg124',
  roomId: 'room123',
  senderId: 'user123',
  content: 'image_url',
  type: MessageType.image,
  timestamp: DateTime.now(),
);
```

### Sharing a Cat Profile
```dart
final catProfileMessage = ChatMessageModel(
  id: 'msg125',
  roomId: 'room123',
  senderId: 'user123',
  content: 'Check out my cat!',
  type: MessageType.catProfile,
  timestamp: DateTime.now(),
  referencedCatId: 'cat123',
);
```

### Managing Read Status
```dart
// Mark message as read
final readMessage = message.markAsRead('user456');

// Check if message is read
final isRead = message.isReadBy('user456');

// Get read timestamp
final readTime = message.getReadTime('user456');
```

## Connected Components

### Used By
- ChatService
- ChatDetailScreen
- ChatRoomModel
- NotificationService

### Related Models
- ChatRoomModel (through parent-child relationship)
- UserModel (through sender)
- CatModel (through references)

## Best Practices
1. Validate message content
2. Handle media URLs properly
3. Maintain read status accurately
4. Validate message types
5. Handle system messages appropriately

## Security Considerations
1. Validate sender permissions
2. Protect message content
3. Secure media access
4. Control message editing
5. Handle message deletion 