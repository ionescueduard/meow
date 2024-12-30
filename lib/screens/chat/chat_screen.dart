import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/chat_room_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/firestore_service.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Map<String, ValueNotifier<bool>> _hoverStates = {};

  @override
  void dispose() {
    for (var notifier in _hoverStates.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  ValueNotifier<bool> _getHoverNotifier(String id) {
    return _hoverStates.putIfAbsent(id, () => ValueNotifier(false));
  }

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

                  return Dismissible(
                    key: Key(chatRoom.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Conversation'),
                          content: const Text(
                            'Are you sure you want to delete this conversation?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      chatService.deleteChatRoom(chatRoom.id);
                    },
                    child: MouseRegion(
                      onEnter: (_) => _getHoverNotifier(chatRoom.id).value = true,
                      onExit: (_) => _getHoverNotifier(chatRoom.id).value = false,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
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
                        child: Container(
                          color: Colors.transparent,
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _getHoverNotifier(chatRoom.id),
                            builder: (context, isHovered, _) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      right: isHovered ? 48.0 : 0,
                                    ),
                                    child: ListTile(
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
                                                fontWeight: unreadCount > 0
                                                    ? FontWeight.bold
                                                    : null,
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
                                                color:
                                                    Theme.of(context).colorScheme.primary,
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
                                    ),
                                  ),
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    right: isHovered ? 8.0 : -40.0,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Conversation'),
                                              content: const Text(
                                                'Are you sure you want to delete this conversation?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, true),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirmed == true) {
                                            chatService.deleteChatRoom(chatRoom.id);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
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