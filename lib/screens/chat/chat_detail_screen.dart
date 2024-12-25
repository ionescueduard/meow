import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/storage_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final UserModel otherUser;
  final String chatId;

  const ChatDetailScreen({
    super.key,
    required this.otherUser,
    required this.chatId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<ChatService>().sendMessage(
            senderId: currentUser.uid,
            receiverId: widget.otherUser.id,
            content: message,
          );

      _messageController.clear();
      _scrollToBottom();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendImage() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final storageService = context.read<StorageService>();
      final chatService = context.read<ChatService>();

      // Upload image
      final imageUrl = await storageService.uploadFile(
        File(image.path),
        storageService.getStoragePath(currentUser.uid, 'chat'),
      );

      // Send message with image
      await chatService.sendMessage(
        senderId: currentUser.uid,
        receiverId: widget.otherUser.id,
        content: '📷 Image',
        mediaUrl: imageUrl,
      );

      _scrollToBottom();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view messages')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser.photoUrl != null
                  ? NetworkImage(widget.otherUser.photoUrl!)
                  : null,
              child: widget.otherUser.photoUrl == null
                  ? Text(widget.otherUser.name[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUser.name),
                if (widget.otherUser.location != null)
                  Text(
                    widget.otherUser.location!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: context
                  .read<ChatService>()
                  .getMessages(currentUser.uid, widget.otherUser.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.mediaUrl != null)
                              GestureDetector(
                                onTap: () {
                                  // TODO: Show full-screen image
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    message.mediaUrl!,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
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

          // Message input
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: _isLoading ? null : _sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 