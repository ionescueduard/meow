import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/chat_room_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/firestore_service.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please sign in to view chats'));
    }

    final chatService = context.read<ChatService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder<List<ChatRoomModel>>(
        stream: chatService.getUserChatRooms(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chatRooms = snapshot.data ?? [];
          if (chatRooms.isEmpty) {
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
                    'Start a conversation by visiting a cat profile\nor user profile!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final otherUserId = chatRoom.participantIds
                  .firstWhere((id) => id != currentUser.uid);

              return FutureBuilder<UserModel?>(
                future: context.read<FirestoreService>().getUser(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final otherUser = userSnapshot.data!;
                  final unreadCount = chatRoom.unreadCount[currentUser.uid] ?? 0;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: otherUser.photoUrl != null
                          ? NetworkImage(otherUser.photoUrl!)
                          : null,
                      child: otherUser.photoUrl == null
                          ? Text(otherUser.name[0].toUpperCase())
                          : null,
                    ),
                    title: Text(otherUser.name),
                    subtitle: chatRoom.lastMessageText != null
                        ? Text(
                            chatRoom.lastMessageText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  unreadCount > 0 ? FontWeight.bold : null,
                            ),
                          )
                        : const Text(
                            'No messages yet',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeago.format(chatRoom.lastMessageTime),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatRoom: chatRoom,
                            otherUser: otherUser,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 