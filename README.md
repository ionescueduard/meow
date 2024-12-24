# Meow - Cat Breeding App

A Flutter application for cat breeders and enthusiasts to connect, share, and manage their cats.

## Features

- User authentication (email and Google Sign-in)
- Cat profile management
- Social feed with photos and updates
- Breeding section for available cats
- Real-time chat between users
- Push notifications

## Prerequisites

- Flutter SDK (^3.6.0)
- Firebase project setup
- iOS/Android development environment

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/meow.git
cd meow
```

2. Install dependencies:
```bash
flutter pub get
```

3. Firebase Setup:
   - Create a new Firebase project
   - Add iOS and Android apps in Firebase console
   - Download and add the configuration files:
     - iOS: `GoogleService-Info.plist`
     - Android: `google-services.json`
   - Enable Authentication methods (Email/Password and Google Sign-in)
   - Set up Cloud Firestore
   - Set up Firebase Storage
   - Set up Firebase Cloud Messaging

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Business logic and Firebase services
└── widgets/        # Reusable UI components
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
