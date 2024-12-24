import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

enum NotificationType {
  chat,
  like,
  comment,
  breeding,
  follow,
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirestoreService _firestoreService;
  final StreamController<RemoteMessage> _messageStreamController =
      StreamController.broadcast();

  NotificationService(this._firestoreService);

  Stream<RemoteMessage> get onMessageStream => _messageStreamController.stream;

  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Initialize local notifications
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Get FCM token
      final token = await _messaging.getToken();
      print('FCM Token: $token'); // For debugging
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _messageStreamController.add(message);

    // Show local notification
    final notification = message.notification;
    if (notification != null) {
      await _showLocalNotification(
        id: message.hashCode,
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: json.encode(message.data),
      );
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!) as Map<String, dynamic>;
      final type = NotificationType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => NotificationType.chat,
      );

      // Get the global navigator key from the app
      final context = navigatorKey.currentContext;
      if (context == null) return;

      switch (type) {
        case NotificationType.chat:
          final roomId = data['roomId'] as String;
          Navigator.pushNamed(
            context,
            '/chat/detail',
            arguments: roomId,
          );
          break;

        case NotificationType.like:
        case NotificationType.comment:
          final postId = data['postId'] as String;
          Navigator.pushNamed(
            context,
            '/post/detail',
            arguments: postId,
          );
          break;

        case NotificationType.breeding:
          final catId = data['catId'] as String;
          Navigator.pushNamed(
            context,
            '/cat/detail',
            arguments: catId,
          );
          break;

        case NotificationType.follow:
          final followerId = data['followerId'] as String;
          Navigator.pushNamed(
            context,
            '/profile',
            arguments: followerId,
          );
          break;
      }
    }
  }

  // Subscribe to topics
  Future<void> subscribeToUserTopics(String userId) async {
    await _messaging.subscribeToTopic('user_$userId');
  }

  Future<void> unsubscribeFromUserTopics(String userId) async {
    await _messaging.unsubscribeFromTopic('user_$userId');
  }

  // Send notifications
  Future<void> sendChatNotification({
    required String userId,
    required ChatMessageModel message,
    required UserModel sender,
  }) async {
    final data = {
      'type': NotificationType.chat.toString(),
      'roomId': message.roomId,
      'messageId': message.id,
      'senderId': sender.id,
      'senderName': sender.displayName,
      'content': message.content,
      'timestamp': message.timestamp.toIso8601String(),
    };

    await _sendNotification(
      topic: 'user_$userId',
      title: sender.displayName,
      body: message.type == MessageType.image
          ? '📷 Sent a photo'
          : message.type == MessageType.catProfile
              ? '🐱 Shared a cat profile'
              : message.content,
      data: data,
    );
  }

  Future<void> sendLikeNotification({
    required String userId,
    required String postId,
    required UserModel liker,
  }) async {
    final data = {
      'type': NotificationType.like.toString(),
      'postId': postId,
      'likerId': liker.id,
      'likerName': liker.displayName,
    };

    await _sendNotification(
      topic: 'user_$userId',
      title: 'New Like',
      body: '${liker.displayName} liked your post',
      data: data,
    );
  }

  Future<void> sendCommentNotification({
    required String userId,
    required String postId,
    required String commentId,
    required UserModel commenter,
    required String commentText,
  }) async {
    final data = {
      'type': NotificationType.comment.toString(),
      'postId': postId,
      'commentId': commentId,
      'commenterId': commenter.id,
      'commenterName': commenter.displayName,
      'commentText': commentText,
    };

    await _sendNotification(
      topic: 'user_$userId',
      title: 'New Comment',
      body: '${commenter.displayName} commented: $commentText',
      data: data,
    );
  }

  Future<void> sendBreedingRequestNotification({
    required String userId,
    required String catId,
    required UserModel requester,
  }) async {
    final data = {
      'type': NotificationType.breeding.toString(),
      'catId': catId,
      'requesterId': requester.id,
      'requesterName': requester.displayName,
    };

    await _sendNotification(
      topic: 'user_$userId',
      title: 'New Breeding Request',
      body: '${requester.displayName} is interested in breeding with your cat',
      data: data,
    );
  }

  Future<void> sendFollowNotification({
    required String userId,
    required UserModel follower,
  }) async {
    final data = {
      'type': NotificationType.follow.toString(),
      'followerId': follower.id,
      'followerName': follower.displayName,
    };

    await _sendNotification(
      topic: 'user_$userId',
      title: 'New Follower',
      body: '${follower.displayName} started following you',
      data: data,
    );
  }

  Future<void> _sendNotification({
    required String topic,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // Note: In a production app, you would send this to your server
    // which would then use Firebase Admin SDK or FCM API to send the notification
    print('Sending notification to topic: $topic');
    print('Title: $title');
    print('Body: $body');
    print('Data: $data');
  }
}

// This needs to be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling background message: ${message.messageId}');
} 