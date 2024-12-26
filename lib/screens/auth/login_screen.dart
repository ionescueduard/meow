import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as tmpAuth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import '../../services/firestore_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    //_autoLogin();
  }

  void _autoLogin() async {
    try {
      await tmpAuth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'ionescueduardrobert@gmail.com',
        password: '123123',
      );
    } catch (e) {
      print('Auto login failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(),
        GoogleProvider(
          clientId: '', // You'll need to add your Google Client ID here
        ),
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) async {
          final firestoreService = context.read<FirestoreService>();
          final user = state.user;
          
          if (user != null) {
            // Check if user profile exists
            final userProfile = await firestoreService.getUser(user.uid);
            
            if (mounted) {
              if (userProfile == null) {
                // New user - redirect to profile setup
                Navigator.pushReplacementNamed(context, '/profile-setup');
              } else {
                // Existing user - redirect to home
                Navigator.pushReplacementNamed(context, '/home');
              }
            }
          }
        }),
      ],
      headerBuilder: (context, constraints, shrinkOffset) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset('assets/images/logo.png'),
          ),
        );
      },
      subtitleBuilder: (context, action) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: action == AuthAction.signIn
              ? const Text('Welcome to Meow, please sign in!')
              : const Text('Welcome to Meow, please sign up!'),
        );
      },
      footerBuilder: (context, action) {
        return const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            'By signing in, you agree to our terms and conditions.',
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }
}