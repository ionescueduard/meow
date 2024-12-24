# ChatDetailScreen Documentation

## Overview
`ChatDetailScreen` displays an individual chat conversation between two users. It shows the message history, allows sending text messages and images, and displays typing indicators and online status.

## File Location
`lib/screens/chat/chat_detail_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../../models/chat_room_model.dart';
import '../../models/chat_message_model.dart';
import '../../models/cat_model.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/full_screen_image.dart';
```

## Class Definition

### State
```dart
class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService.instance;
  final AuthService _authService = AuthService.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isAttaching = false;
  List<ChatMessageModel> _messages = [];
  Timer? _typingTimer;
}
```

### Properties
- `_chatService`: Service for managing chat functionality
- `_authService`: Service for user authentication
- `_messageController`: Controls message input
- `_scrollController`: Controls message list scrolling
- `_isTyping`: Typing indicator state
- `_isAttaching`: File attachment state
- `_messages`: List of chat messages
- `_typingTimer`: Timer for typing indicator

### UI Components

#### App Bar
```dart
AppBar(
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(widget.chatRoom.participantName),
      if (_isTyping)
        Text(
          'typing...',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
    ],
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.info_outline),
      onPressed: _showChatInfo,
    ),
  ],
)
```

#### Message List
```dart
StreamBuilder<List<ChatMessageModel>>(
  stream: _chatService.getChatMessages(widget.chatRoom.id),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Center(child: Text('Error loading messages'));
    }

    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final messages = snapshot.data!;
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) => MessageBubble(
        message: messages[index],
        isMe: messages[index].senderId == _authService.currentUser!.id,
      ),
    );
  },
)
```

#### Message Input
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8.0),
  child: Row(
    children: [
      IconButton(
        icon: const Icon(Icons.attach_file),
        onPressed: _showAttachmentOptions,
      ),
      Expanded(
        child: TextField(
          controller: _messageController,
          decoration: InputDecoration(
            hintText: 'Type a message...',
            border: InputBorder.none,
          ),
          onChanged: _onTypingChanged,
        ),
      ),
      IconButton(
        icon: const Icon(Icons.send),
        onPressed: _sendMessage,
      ),
    ],
  ),
)
```

### Methods

#### Message Handling
```dart
Future<void> _sendMessage() async {
  final text = _messageController.text.trim();
  if (text.isEmpty) return;

  final message = ChatMessageModel(
    roomId: widget.chatRoom.id,
    senderId: _authService.currentUser!.id,
    content: text,
    timestamp: DateTime.now(),
    type: MessageType.text,
  );

  try {
    await _chatService.sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  } catch (e) {
    // Handle error
  }
}

void _onTypingChanged(String text) {
  _typingTimer?.cancel();
  if (!_isTyping) {
    setState(() => _isTyping = true);
    _chatService.setTypingStatus(widget.chatRoom.id, true);
  }

  _typingTimer = Timer(const Duration(seconds: 2), () {
    setState(() => _isTyping = false);
    _chatService.setTypingStatus(widget.chatRoom.id, false);
  });
}
```

#### File Handling
```dart
Future<void> _showAttachmentOptions() async {
  setState(() => _isAttaching = true);
  try {
    final result = await showModalBottomSheet(
      context: context,
      builder: (context) => AttachmentOptionsSheet(),
    );

    if (result != null) {
      await _handleAttachment(result);
    }
  } finally {
    setState(() => _isAttaching = false);
  }
}

Future<void> _handleAttachment(AttachmentType type) async {
  switch (type) {
    case AttachmentType.image:
      await _pickAndSendImage();
      break;
    case AttachmentType.cat:
      await _pickAndSendCat();
      break;
  }
}
```

#### Navigation
```dart
void _showChatInfo() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatInfoScreen(chatRoom: widget.chatRoom),
    ),
  );
}

void _showFullScreenImage(String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FullScreenImage(imageUrl: imageUrl),
    ),
  );
}
```

## Usage Example

```dart
class ChatScreen extends StatelessWidget {
  final ChatRoomModel chatRoom;

  @override
  Widget build(BuildContext context) {
    return ChatDetailScreen(chatRoom: chatRoom);
  }
}
```

## Data Flow

### Message Loading
1. Initial messages loaded through `StreamBuilder`
2. Real-time updates for new messages
3. Typing indicators and online status

### Message Sending
1. Text input validation
2. Message creation
3. Send to backend
4. Real-time update in UI

## Connected Components

### Widgets
- MessageBubble (displays messages)
- AttachmentOptionsSheet (file options)
- FullScreenImage (image viewer)
- TypingIndicator (shows typing status)

### Screens
- ChatInfoScreen (chat details)
- CatDetailsScreen (shared cat profiles)
- ImageViewer (full-screen images)

### Services
- ChatService (message management)
- AuthService (user authentication)
- StorageService (file handling)
- NotificationService (message alerts)

## State Management

### Local State
- Message input
- Typing status
- Attachment state
- Scroll position

### Global State
- Chat room data
- User online status
- Message notifications
- Media uploads

## Best Practices
1. Handle message updates efficiently
2. Manage typing indicators
3. Optimize media uploads
4. Cache message history
5. Handle errors gracefully

## Performance Considerations
1. Message pagination
2. Image optimization
3. Typing debounce
4. Memory management
5. Network optimization

## Error Handling
1. Message send failures
2. Media upload errors
3. Network issues
4. Navigation errors
5. Authentication errors

## Security Considerations
1. Validate message access
2. Protect media files
3. Handle user blocking
4. Secure file uploads
5. Rate limiting 