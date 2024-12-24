# ProfileScreen Documentation

## Overview
`ProfileScreen` displays the user's profile information, their cats, and posts. It allows users to edit their profile, manage their cats, and view their activity history.

## File Location
`lib/screens/profile/profile_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/cat_model.dart';
import '../../models/post_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../cat/edit_cat_screen.dart';
import '../cat/cat_details_screen.dart';
```

## Class Definition

### State
```dart
class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  final ScrollController _scrollController = ScrollController();
  bool _isEditing = false;
  bool _isLoading = false;
  UserModel? _user;
  List<CatModel> _cats = [];
  List<PostModel> _posts = [];
}
```

### Properties
- `_authService`: Service for user authentication
- `_firestoreService`: Service for data management
- `_storageService`: Service for file storage
- `_scrollController`: Controls profile scrolling
- `_isEditing`: Profile editing state
- `_isLoading`: Loading state indicator
- `_user`: Current user data
- `_cats`: User's cats
- `_posts`: User's posts

### UI Components

#### App Bar
```dart
AppBar(
  title: Text(_user?.displayName ?? 'Profile'),
  actions: [
    IconButton(
      icon: Icon(_isEditing ? Icons.done : Icons.edit),
      onPressed: _toggleEditMode,
    ),
    IconButton(
      icon: const Icon(Icons.settings),
      onPressed: _navigateToSettings,
    ),
  ],
)
```

#### Profile Header
```dart
Container(
  padding: const EdgeInsets.all(16),
  child: Column(
    children: [
      CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(_user?.photoUrl ?? ''),
      ),
      const SizedBox(height: 16),
      Text(
        _user?.displayName ?? '',
        style: Theme.of(context).textTheme.headline6,
      ),
      Text(
        _user?.bio ?? '',
        textAlign: TextAlign.center,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatColumn('Cats', _cats.length),
          _buildStatColumn('Posts', _posts.length),
          _buildStatColumn('Followers', _user?.followerCount ?? 0),
          _buildStatColumn('Following', _user?.followingCount ?? 0),
        ],
      ),
    ],
  ),
)
```

#### Cat Grid
```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
  ),
  itemCount: _cats.length + 1,
  itemBuilder: (context, index) {
    if (index == _cats.length) {
      return _buildAddCatCard();
    }
    return CatCard(
      cat: _cats[index],
      onTap: () => _navigateToCatDetails(_cats[index]),
    );
  },
)
```

#### Post Grid
```dart
GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 2,
    mainAxisSpacing: 2,
  ),
  itemCount: _posts.length,
  itemBuilder: (context, index) => PostThumbnail(
    post: _posts[index],
    onTap: () => _navigateToPost(_posts[index]),
  ),
)
```

### Methods

#### Profile Management
```dart
Future<void> _toggleEditMode() async {
  if (_isEditing) {
    await _saveProfile();
  }
  setState(() => _isEditing = !_isEditing);
}

Future<void> _saveProfile() async {
  setState(() => _isLoading = true);
  try {
    await _firestoreService.updateUser(_user!);
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### Navigation
```dart
void _navigateToAddCat() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EditCatScreen()),
  );
}

void _navigateToCatDetails(CatModel cat) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => CatDetailsScreen(cat: cat)),
  );
}

void _navigateToSettings() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SettingsScreen()),
  );
}
```

#### Data Loading
```dart
Future<void> _loadUserData() async {
  setState(() => _isLoading = true);
  try {
    final userId = _authService.currentUser!.id;
    _user = await _firestoreService.getUser(userId);
    _cats = await _firestoreService.getUserCats(userId);
    _posts = await _firestoreService.getUserPosts(userId);
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}
```

## Usage Example

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
```

## Data Flow

### Profile Loading
1. Initial data loaded on screen mount
2. Real-time updates through Firestore streams
3. Profile edits saved to backend

### Content Management
1. Add/remove cats
2. Create/edit posts
3. Update profile information
4. Manage followers/following

## Connected Components

### Widgets
- CatCard (displays cat profiles)
- PostThumbnail (displays post previews)
- EditableField (profile editing)
- ImagePicker (profile photo)

### Screens
- EditCatScreen (add/edit cats)
- CatDetailsScreen (view cat details)
- SettingsScreen (app settings)
- PostScreen (view full posts)

### Services
- AuthService (user authentication)
- FirestoreService (data management)
- StorageService (file storage)
- NotificationService (activity updates)

## State Management

### Local State
- Edit mode
- Loading states
- Form data
- Scroll position

### Global State
- User session
- Profile data
- Content lists
- Notification state

## Best Practices
1. Handle image uploads efficiently
2. Validate form inputs
3. Manage loading states
4. Cache profile data
5. Handle errors gracefully

## Performance Considerations
1. Lazy loading of images
2. Efficient grid rendering
3. Optimized data queries
4. Memory management
5. Network optimization

## Error Handling
1. Image upload failures
2. Network errors
3. Validation errors
4. Navigation errors
5. Authentication errors

## Security Considerations
1. Validate file uploads
2. Protect user data
3. Handle permissions
4. Secure profile edits
5. Rate limiting 