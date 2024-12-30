import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../../services/auth_service.dart';

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
                onTap: () {
                  // Handle notification tap based on type
                  if (!notification.isRead) {
                    context.read<NotificationService>().markAsRead(notification.id);
                  }
                  // Navigate based on notification type
                  switch (notification.type) {
                    case NotificationType.follow:
                      Navigator.pushNamed(
                        context,
                        '/profile',
                        arguments: notification.senderId,
                      );
                      break;
                    case NotificationType.like:
                    case NotificationType.comment:
                      Navigator.pushNamed(
                        context,
                        '/post',
                        arguments: notification.postId,
                      );
                      break;
                    case NotificationType.message:
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: notification.senderId,
                      );
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