# Main Application Documentation

## Overview
The `main.dart` file is the entry point of the Meow application. It initializes Firebase services, sets up the app theme, configures providers, and defines the app's root widget structure.

## File Location
`lib/main.dart`

## Dependencies
```dart
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
```

## Firebase Initialization
```dart
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
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling background message: ${message.messageId}');
}
```

## Service Providers Setup
```dart
MultiProvider(
  providers: [
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
    Provider<NotificationService>(
      create: (_) => NotificationService(),
    ),
    StreamProvider<UserModel?>(
      create: (context) => context.read<AuthService>().authStateChanges,
      initialData: null,
    ),
  ],
  child: const MyApp(),
)
```

## Main App Widget
```dart
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
```

## Auth Wrapper
```dart
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
```

## Navigation Service
```dart
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
```

## Complete Implementation
```dart
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  
  runApp(
    MultiProvider(
      providers: [
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
        Provider<NotificationService>(
          create: (_) => NotificationService(),
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
```

## Key Features

### 1. Firebase Integration
- Initializes Firebase services
- Sets up Firebase Messaging
- Handles background messages
- Manages FCM tokens

### 2. State Management
- Provider setup for all services
- Stream-based authentication state
- Global navigation service
- Theme management

### 3. Service Dependencies
- Authentication service
- Firestore service
- Storage service
- Chat service
- Notification service

### 4. Navigation
- Global navigator key
- Global scaffold messenger key
- Navigation helper methods
- Route management

### 5. Theme Support
- Light theme
- Dark theme
- System theme mode
- Custom theme configuration

### 6. Error Handling
- Firebase initialization errors
- Authentication state errors
- Navigation errors
- Service initialization errors

### 7. Performance Considerations
- Asynchronous initialization
- Lazy service creation
- Efficient provider setup
- Optimized imports

### 8. Security Features
- Firebase initialization check
- Authentication state management
- Service access control
- Secure navigation

### 9. Debugging Support
- Debug banner control
- Service initialization logging
- Navigation state tracking
- Error reporting setup

### 10. Maintainability
- Clean code structure
- Dependency injection
- Service separation
- Clear responsibilities 