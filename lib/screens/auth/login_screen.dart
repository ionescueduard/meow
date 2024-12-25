import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as tmpAuth;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _autoLogin();
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
      headerBuilder: (context, constraints, shrinkOffset) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset('assets/images/logo.png'), // Make sure logo.png exists in assets/images/
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