import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/chat_service.dart';
import '../profile/profile_screen.dart';
import '../post/post_comments_screen.dart';
import '../chat/chat_detail_screen.dart';
import '../breeding/breeding_request_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';

  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view notifications')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: context.read<NotificationService>().getNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet'),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: notification.senderPhotoUrl != null
                      ? NetworkImage(notification.senderPhotoUrl!)
                      : null,
                  child: notification.senderPhotoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(notification.message),
                subtitle: Text(
                  notification.createdAt.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () async {
                  // Handle notification tap based on type
                  if (!notification.isRead) {
                    context.read<NotificationService>().markAsRead(notification.id);
                  }

                  final firestoreService = context.read<FirestoreService>();

                  // Navigate based on notification type
                  switch (notification.type) {
                    case NotificationType.follow:
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userId: notification.senderId),
                        ),
                      );
                      break;
                    case NotificationType.like:
                    case NotificationType.comment:
                      if (notification.postId != null) {
                        final post = await firestoreService.getPost(notification.postId!);
                        final author = await firestoreService.getUser(post?.userId ?? '');
                        if (post != null && author != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostCommentsScreen(
                                post: post,
                                author: author,
                              ),
                            ),
                          );
                        }
                      }
                      break;
                    case NotificationType.breeding:
                      // Get the breeding request using the requestId stored in the notification
                      final requests = await firestoreService.getReceivedBreedingRequests(userId).first;
                      final request = requests.where(
                        (req) => req.requesterId == notification.senderId,
                      ).firstOrNull;
                      if (request != null && context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BreedingRequestDetailsScreen(
                              request: request,
                              isReceived: true,
                            ),
                          ),
                        );
                      }
                      break;
                    case NotificationType.message:
                      final chatService = context.read<ChatService>();
                      final otherUser = await firestoreService.getUser(notification.senderId);
                      if (otherUser != null && context.mounted) {
                        final chatRoom = await chatService.getChatRoom(
                          participantIds: [userId, notification.senderId],
                        );
                        if (chatRoom != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                chatRoom: chatRoom,
                                otherUser: otherUser,
                              ),
                            ),
                          );
                        }
                      }
                      break;
                  }
                },
                tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.1),
              );
            },
          );
        },
      ),
    );
  }
} 