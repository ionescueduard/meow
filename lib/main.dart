import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/chat_service.dart';
import 'services/notification_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        Provider<NotificationService>(
          create: (context) => NotificationService(
            context.read<FirestoreService>(),
          ),
        ),
        Provider<FirestoreService>(
          create: (context) => FirestoreService(
            context.read<NotificationService>(),
          ),
        ),
        Provider<ChatService>(
          create: (context) => ChatService(
            context.read<StorageService>(),
            context.read<NotificationService>(),
          ),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(
            context.read<FirestoreService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Meow',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: FutureBuilder(
          future: _initializeApp(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<User?>(
              stream: context.read<AuthService>().authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  return const HomeScreen();
                }

                return const LoginScreen();
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _initializeApp(BuildContext context) async {
    // Initialize notification service
    await context.read<NotificationService>().initialize();

    // Subscribe to user-specific notifications when signed in
    context.read<AuthService>().authStateChanges.listen((user) {
      final notificationService = context.read<NotificationService>();
      if (user != null) {
        notificationService.subscribeToUserTopics(user.uid);
      } else {
        // Unsubscribe from previous user's topics if any
        final previousUser = context.read<AuthService>().currentUser;
        if (previousUser != null) {
          notificationService.unsubscribeFromUserTopics(previousUser.uid);
        }
      }
    });
  }
}
