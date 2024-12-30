import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission for notifications
    await _messaging.requestPermission();

    // Initialize local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initializationSettings);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      await _localNotifications.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }

  Future<void> subscribeToUserTopics(String userId) async {
    await _messaging.subscribeToTopic('user_$userId');
  }

  Future<void> unsubscribeFromUserTopics(String userId) async {
    await _messaging.unsubscribeFromTopic('user_$userId');
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> markAsRead(String notificationId) async {
    // Get the current user ID
    final userId = _messaging.app.options.androidClientId;
    if (userId == null) return;

    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> createNotification({
    required String userId,
    required String senderId,
    String? senderPhotoUrl,
    required String message,
    required NotificationType type,
    String? postId,
  }) async {
    final notification = NotificationModel(
      id: '', // Will be set by Firestore
      senderId: senderId,
      senderPhotoUrl: senderPhotoUrl,
      message: message,
      type: type,
      createdAt: DateTime.now(),
      postId: postId,
    );

    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification.toMap());
  }

  Future<void> _sendPushNotification({
    required String topic,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    // In a production app, this would be handled by your backend
    print('Sending push notification to topic: $topic');
    print('Title: $title');
    print('Body: $body');
    print('Data: $data');
  }

  Future<void> sendChatNotification({
    required String userId,
    required ChatMessageModel message,
    required UserModel sender,
  }) async {
    // Create in-app notification
    await createNotification(
      userId: userId,
      senderId: sender.id,
      senderPhotoUrl: sender.photoUrl,
      message: '${sender.name} sent you a message',
      type: NotificationType.message,
    );

    // Send push notification
    await _sendPushNotification(
      topic: 'user_$userId',
      title: sender.name,
      body: message.type == MessageType.image
          ? '📷 Sent a photo'
          : message.type == MessageType.catProfile
              ? '🐱 Shared a cat profile'
              : message.content,
      data: {
        'type': 'message',
        'senderId': sender.id,
        'messageId': message.id,
      },
    );
  }

  Future<void> sendLikeNotification({
    required String userId,
    required String postId,
    required UserModel liker,
  }) async {
    await createNotification(
      userId: userId,
      senderId: liker.id,
      senderPhotoUrl: liker.photoUrl,
      message: '${liker.name} liked your post',
      type: NotificationType.like,
      postId: postId,
    );

    await _sendPushNotification(
      topic: 'user_$userId',
      title: 'New Like',
      body: '${liker.name} liked your post',
      data: {
        'type': 'like',
        'postId': postId,
        'likerId': liker.id,
      },
    );
  }

  Future<void> sendCommentNotification({
    required String userId,
    required String postId,
    required String commentId,
    required UserModel commenter,
    required String commentText,
  }) async {
    await createNotification(
      userId: userId,
      senderId: commenter.id,
      senderPhotoUrl: commenter.photoUrl,
      message: '${commenter.name} commented: $commentText',
      type: NotificationType.comment,
      postId: postId,
    );

    await _sendPushNotification(
      topic: 'user_$userId',
      title: 'New Comment',
      body: '${commenter.name} commented on your post',
      data: {
        'type': 'comment',
        'postId': postId,
        'commentId': commentId,
        'commenterId': commenter.id,
      },
    );
  }

  Future<void> sendCommentLikeNotification({
    required String userId,
    required String postId,
    required String commentId,
    required UserModel liker,
  }) async {
    await createNotification(
      userId: userId,
      senderId: liker.id,
      senderPhotoUrl: liker.photoUrl,
      message: '${liker.name} liked your comment',
      type: NotificationType.like,
      postId: postId,
    );

    await _sendPushNotification(
      topic: 'user_$userId',
      title: 'New Like',
      body: '${liker.name} liked your comment',
      data: {
        'type': 'comment_like',
        'postId': postId,
        'commentId': commentId,
        'likerId': liker.id,
      },
    );
  }

  Future<void> sendFollowNotification({
    required String userId,
    required UserModel follower,
  }) async {
    await createNotification(
      userId: userId,
      senderId: follower.id,
      senderPhotoUrl: follower.photoUrl,
      message: '${follower.name} started following you',
      type: NotificationType.follow,
    );

    await _sendPushNotification(
      topic: 'user_$userId',
      title: 'New Follower',
      body: '${follower.name} started following you',
      data: {
        'type': 'follow',
        'followerId': follower.id,
      },
    );
  }

  Future<void> sendBreedingRequestNotification({
    required String userId,
    required String catId,
    required UserModel requester,
  }) async {
    await createNotification(
      userId: userId,
      senderId: requester.id,
      senderPhotoUrl: requester.photoUrl,
      message: '${requester.name} is interested in breeding with your cat',
      type: NotificationType.message, // Using message type for breeding requests
    );

    await _sendPushNotification(
      topic: 'user_$userId',
      title: 'New Breeding Request',
      body: '${requester.name} is interested in breeding with your cat',
      data: {
        'type': 'breeding',
        'catId': catId,
        'requesterId': requester.id,
      },
    );
  }
} 