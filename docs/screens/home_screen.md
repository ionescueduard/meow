# HomeScreen Documentation

## Overview
`HomeScreen` is the main navigation hub of the application. It manages the bottom navigation bar and displays the appropriate screen based on the selected tab.

## File Location
`lib/screens/home/home_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../feed/feed_screen.dart';
import '../breeding/breeding_screen.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/auth_service.dart';
```

## Class Definition

### State
```dart
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final List<Widget> _screens = [
    const FeedScreen(),
    const BreedingScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];
}
```

### Properties
- `_currentIndex`: Current selected tab index
- `_pageController`: Controls page transitions between tabs
- `_screens`: List of main screens in the app

### UI Components

#### Bottom Navigation Bar
```dart
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: _onTabTapped,
  type: BottomNavigationBarType.fixed,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Feed',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.pets),
      label: 'Breeding',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      label: 'Chat',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ],
)
```

#### Page View
```dart
PageView(
  controller: _pageController,
  onPageChanged: _onPageChanged,
  physics: const NeverScrollableScrollPhysics(),
  children: _screens,
)
```

### Methods

#### Tab Navigation
```dart
void _onTabTapped(int index) {
  _pageController.jumpToPage(index);
  setState(() => _currentIndex = index);
}

void _onPageChanged(int index) {
  setState(() => _currentIndex = index);
}
```

#### Lifecycle Methods
```dart
@override
void dispose() {
  _pageController.dispose();
  super.dispose();
}
```

## Usage Example

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthService.instance.currentUser != null
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
```

## Navigation Flow

### Tab Navigation
1. Feed Tab (index 0)
   - Displays `FeedScreen`
   - Shows posts from followed users and cats

2. Breeding Tab (index 1)
   - Displays `BreedingScreen`
   - Shows available cats for breeding

3. Chat Tab (index 2)
   - Displays `ChatScreen`
   - Shows list of active chats

4. Profile Tab (index 3)
   - Displays `ProfileScreen`
   - Shows user profile and settings

### Screen Transitions
- Uses `PageView` for smooth transitions between tabs
- Disables swipe gestures to prevent accidental navigation
- Maintains screen state when switching tabs

## Connected Components

### Screens
- FeedScreen
- BreedingScreen
- ChatScreen
- ProfileScreen

### Services
- AuthService (for user session management)
- NotificationService (for badge counts)

## State Management

### Local State
- Current tab index
- Page controller state

### Global State
- User authentication state
- Notification counts
- Unread message counts

## Best Practices
1. Maintain screen state when switching tabs
2. Handle deep links appropriately
3. Update notification badges
4. Handle back button navigation
5. Manage memory efficiently

## Performance Considerations
1. Lazy loading of tab screens
2. Efficient state management
3. Minimal rebuilds
4. Memory management
5. Navigation optimization

## Error Handling
1. Authentication state changes
2. Navigation errors
3. Screen loading failures
4. Deep link handling
5. Memory warnings

## Security Considerations
1. Check authentication state
2. Validate deep links
3. Handle session expiration
4. Protect sensitive data
5. Secure navigation 