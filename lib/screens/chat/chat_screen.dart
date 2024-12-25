import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
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

    final chatService = Provider.of<ChatService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatService.getUserChats(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final chats = snapshot.data ?? [];
        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No conversations yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start chatting with cat owners\nto discuss breeding opportunities!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return FutureBuilder<UserModel?>(
              future: firestoreService.getUser(chat['otherUserId'] as String),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final otherUser = userSnapshot.data!;
                final isLastMessageMine =
                    chat['lastSenderId'] as String == currentUser.uid;

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
                  subtitle: Row(
                    children: [
                      if (isLastMessageMine)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.done_all,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          chat['lastMessage'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    timeago.format(
                      DateTime.parse(chat['lastMessageTime'] as String),
                      allowFromNow: true,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          otherUser: otherUser,
                          chatId: chat['chatId'] as String,
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
    );
  }
} 