import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/chat_service.dart';
import 'services/notification_service.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

// Navigation service for global access
class NavigationService {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar(String message) {
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static Future<T?> navigateTo<T>(Widget screen) {
    return navigatorKey.currentState!.push<T>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  static void pop<T>([T? result]) {
    navigatorKey.currentState!.pop(result);
  }
}

// Firebase background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling background message: ${message.messageId}');
}

// Firebase initialization
Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configure Firebase Messaging
  final messaging = FirebaseMessaging.instance;
  
  // Request notification permissions
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  // Get FCM token
  final token = await messaging.getToken();
  print('FCM Token: $token');
  
  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      NavigationService.showSnackBar(message.notification!.title ?? 'New notification');
    }
  });
}

// Auth wrapper widget
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel?>(
      builder: (context, user, _) {
        if (user == null) {
          return const LoginScreen();
        }
        return const HomeScreen();
      },
    );
  }
}

// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      scaffoldMessengerKey: NavigationService.scaffoldKey,
    );
  }
}

// Main entry point
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<FirestoreService>(
          create: (context) => FirestoreService(
            context.read<NotificationService>(),
          ),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        Provider<ChatService>(
          create: (context) => ChatService(
            context.read<FirestoreService>(),
            context.read<NotificationService>(),
          ),
        ),
        StreamProvider<UserModel?>(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
      ],
      child: const MyApp(),
    ),
  );
}
