import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission for notifications
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Initialize local notifications
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
          _handleNotificationTap(details);
        },
      );

      // Handle incoming messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final ios = message.notification?.apple;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            channelDescription: 'Default notification channel',
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            subtitle: ios?.subtitle,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle notification tap when app is in background
    if (message.data['type'] == 'chat') {
      // Navigate to chat screen
    } else if (message.data['type'] == 'breeding') {
      // Navigate to breeding request screen
    }
  }

  void _handleNotificationTap(NotificationResponse details) {
    // Handle notification tap when app is in foreground
    if (details.payload != null) {
      // Parse payload and navigate accordingly
    }
  }

  Future<void> saveToken(String userId) async {
    // Retrieve the FCM token for the device
    final token = await _messaging.getToken();
    
    // Check if the token is not null
    if (token != null) {
      // Save the token to Firestore under the user's document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tokens')
          .doc('fcm')
          .set({
        'token': token, // The FCM token
        'updatedAt': DateTime.now().toIso8601String(), // Current timestamp
        'platform': Platform.operatingSystem, // Platform information
      });
    }
  }

  Future<void> removeToken(String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tokens')
        .doc('fcm')
        .delete();
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final tokenDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tokens')
        .doc('fcm')
        .get();

    if (tokenDoc.exists) {
      final token = tokenDoc.data()?['token'] as String?;
      if (token != null) {
        // In a production app, you would send this to your server
        // to handle the FCM notification dispatch
        print('Would send notification to token: $token');
        print('Title: $title');
        print('Body: $body');
        print('Type: $type');
        print('Data: $data');
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}