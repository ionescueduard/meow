# AuthService Documentation

## Overview
`AuthService` manages user authentication using Firebase Authentication. It handles user sign-in, sign-up, and session management, providing a secure way to authenticate users and manage their sessions.

## File Location
`lib/services/auth_service.dart`

## Dependencies
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';
```

## Main Components

### 1. Service Structure
```dart
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService;

  AuthService(this._firestoreService);
}
```

### 2. Key Features

#### User Authentication
```dart
Future<UserModel?> signInWithEmail(String email, String password)
Future<UserModel?> signUpWithEmail(String email, String password, String name)
Future<UserModel?> signInWithGoogle()
Future<void> signOut()
```
Features:
- Email/password authentication
- Google Sign-In integration
- Secure sign-out
- Session management

#### User State Management
```dart
Stream<User?> get authStateChanges => _auth.authStateChanges();
User? get currentUser => _auth.currentUser;
```
Features:
- Real-time auth state monitoring
- Current user access
- Session persistence

#### Password Management
```dart
Future<void> resetPassword(String email)
Future<void> updatePassword(String newPassword)
```
Features:
- Password reset functionality
- Password update capability
- Security validations

### 3. Implementation Details

#### Email Sign In
```dart
Future<UserModel?> signInWithEmail(String email, String password) async {
  try {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Additional implementation details
  } catch (e) {
    // Error handling
  }
}
```

#### Google Sign In
```dart
Future<UserModel?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    // Additional implementation details
  } catch (e) {
    // Error handling
  }
}
```

### 4. Error Handling
- Firebase Auth exceptions
- Google Sign-In errors
- Network errors
- Validation errors
- User feedback

### 5. Security Considerations
- Secure credential management
- Token handling
- Session timeout
- Auth state persistence
- Secure password reset

### 6. Connected Components

#### Services
- FirestoreService
  - User data storage
  - Profile management

#### Models
- UserModel
  - User data structure
  - Auth state representation

### 7. Best Practices
- Proper error handling
- Secure credential management
- Auth state monitoring
- User data validation
- Session management

### 8. Future Improvements
- Additional auth providers
- Enhanced security features
- Biometric authentication
- Two-factor authentication
- Session management improvements

## Usage Examples

### Email Authentication
```dart
// Sign up
final user = await authService.signUpWithEmail(
  'user@example.com',
  'password123',
  'John Doe'
);

// Sign in
final user = await authService.signInWithEmail(
  'user@example.com',
  'password123'
);
```

### Google Authentication
```dart
// Sign in with Google
final user = await authService.signInWithGoogle();
```

### Password Management
```dart
// Reset password
await authService.resetPassword('user@example.com');

// Update password
await authService.updatePassword('newPassword123');
```

### Auth State Monitoring
```dart
// Listen to auth state changes
authService.authStateChanges.listen((User? user) {
  if (user != null) {
    // User is signed in
  } else {
    // User is signed out
  }
});
``` 