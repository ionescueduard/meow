import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meow/models/user_model.dart';
import 'package:meow/services/chat_service.dart';
import 'package:meow/services/firestore_service.dart';
import 'package:meow/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  final prefs = await SharedPreferences.getInstance();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<NotificationService>(create: (context) => NotificationService()),
        Provider<FirestoreService>(create: (context) => FirestoreService(context.read<NotificationService>())),
        Provider<ChatService>(create: (context) => ChatService(context.read<StorageService>(), context.read<NotificationService>())),
        ChangeNotifierProvider<AuthService>(create: (context) => AuthService()),
      ],
      child: MeowApp(),
    )
  );
}

class MeowApp extends StatelessWidget {
  const MeowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Meow - Cat Breeding App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => _buildAuthWrapper(context),
            '/profile-setup': (context) => const ProfileSetupScreen(),
            '/home': (context) => const HomeScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/notifications': (context) => const NotificationsScreen(),
          },
        );
      },
    );
  }

  Widget _buildAuthWrapper(BuildContext context) {
    return FutureBuilder(
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
              return FutureBuilder<UserModel?>(
                future: context.read<FirestoreService>().getUser(snapshot.data!.uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (userSnapshot.data == null) {
                    return const ProfileSetupScreen();
                  }

                  return const HomeScreen();
                },
              );
            }

            return const LoginScreen();
          },
        );
      },
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