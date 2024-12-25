import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider.value(value: notificationService),
      ],
      child: const MeowApp(),
    ),
  );
}

class MeowApp extends StatelessWidget {
  const MeowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meow - Cat Breeding App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: context.read<AuthService>().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            // Save FCM token when user is logged in
            final userId = snapshot.data!.uid;
            context.read<NotificationService>().saveToken(userId);
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
