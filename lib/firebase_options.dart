import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Add other platforms if needed
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyB50bnDdfDyHYSxkTNI2pY8cUKX0la0n5Y",
    authDomain: "meow-def7d.firebaseapp.com",
    projectId: "meow-def7d",
    storageBucket: "meow-def7d.firebasestorage.app",
    messagingSenderId: "60616018891",
    appId: "1:60616018891:web:27a0f8df126d49beaf044e",
    measurementId: "G-CPS2MX7444"
  );
} 