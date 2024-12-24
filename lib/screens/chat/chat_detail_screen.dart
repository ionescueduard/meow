import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/chat_message_model.dart';
import '../../models/chat_room_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../screens/cat/cat_details_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatRoomModel chatRoom;
  final UserModel otherUser;

  const ChatDetailScreen({
    super.key,
    required this.chatRoom,
    required this.otherUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    await context
        .read<ChatService>()
        .markMessagesAsRead(widget.chatRoom.id, currentUser.uid);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<ChatService>().sendMessage(
            roomId: widget.chatRoom.id,
            senderId: currentUser.uid,
            content: _messageController.text.trim(),
            type: MessageType.text,
          );
      _messageController.clear();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      await context.read<ChatService>().sendImageMessage(
            widget.chatRoom.id,
            currentUser.uid,
            File(pickedFile.path),
          );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImage(
          imageUrl: imageUrl,
          heroTag: imageUrl,
        ),
      ),
    );
  }

  Widget _buildImageMessage(String imageUrl) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl),
      child: Hero(
        tag: imageUrl,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 200,
            maxHeight: 200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(widget.otherUser.profileImageUrl),
      ),
      title: Text(widget.otherUser.username),
      subtitle: _buildOnlineStatus(),
    );
  }

  Widget _buildCatProfileCard(String catId) {
    return FutureBuilder<CatModel?>(
      future: _firestoreService.getCat(catId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final cat = snapshot.data!;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CatDetailsScreen(cat: cat),
            ),
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      cat.imageUrls.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${cat.breed} • ${_calculateAge(cat.birthDate)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (cat.isBreeding)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Available for Breeding',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.difference(birthDate);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return '$years year${years == 1 ? '' : 's'}';
    } else {
      return '$months month${months == 1 ? '' : 's'}';
    }
  }

  Widget _buildOnlineStatus() {
    return StreamBuilder<UserModel?>(
      stream: _firestoreService.getUserStream(widget.otherUser.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text(
            'Offline',
            style: TextStyle(color: Colors.grey),
          );
        }

        final isOnline = snapshot.data!.isOnline;
        return Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? Colors.green : Colors.grey,
              ),
            ),
            Text(
              isOnline ? 'Active now' : 'Offline',
              style: TextStyle(
                color: isOnline ? Colors.green : Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser.photoUrl != null
                  ? NetworkImage(widget.otherUser.photoUrl!)
                  : null,
              child: widget.otherUser.photoUrl == null
                  ? Text(widget.otherUser.displayName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.displayName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Active now', // TODO: Implement online status
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: context
                  .read<ChatService>()
                  .getChatMessages(widget.chatRoom.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.type == MessageType.image)
                              _buildImageMessage(message.content)
                            else if (message.type == MessageType.catProfile)
                              _buildCatProfileCard(message.content)
                            else
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isMe ? Colors.white : null,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              timeago.format(message.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: isMe
                                    ? Colors.white.withOpacity(0.7)
                                    : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate),
                    onPressed: _isLoading ? null : _pickAndSendImage,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 