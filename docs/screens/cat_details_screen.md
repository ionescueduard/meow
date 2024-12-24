# CatDetailsScreen Documentation

## Overview
`CatDetailsScreen` displays detailed information about a specific cat, including photos, profile information, health records, and breeding status. It also provides options for editing the cat's profile and initiating breeding requests.

## File Location
`lib/screens/cat/cat_details_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../widgets/full_screen_image.dart';
import '../chat/chat_detail_screen.dart';
```

## Class Definition

### State
```dart
class _CatDetailsScreenState extends State<CatDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final AuthService _authService = AuthService.instance;
  final ChatService _chatService = ChatService.instance;
  bool _isLoading = false;
  UserModel? _owner;
  List<String> _imageUrls = [];
  bool _isCurrentUserOwner = false;
}
```

### Properties
- `_firestoreService`: Service for managing cat data
- `_authService`: Service for user authentication
- `_chatService`: Service for chat functionality
- `_isLoading`: Loading state indicator
- `_owner`: Cat owner's user data
- `_imageUrls`: List of cat photo URLs
- `_isCurrentUserOwner`: Ownership status flag

### UI Components

#### App Bar
```dart
AppBar(
  title: Text(widget.cat.name),
  actions: [
    if (_isCurrentUserOwner)
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: _navigateToEdit,
      ),
    IconButton(
      icon: const Icon(Icons.share),
      onPressed: _shareCatProfile,
    ),
  ],
)
```

#### Image Gallery
```dart
SizedBox(
  height: 300,
  child: PageView.builder(
    itemCount: _imageUrls.length,
    itemBuilder: (context, index) => GestureDetector(
      onTap: () => _showFullScreenImage(_imageUrls[index]),
      child: Hero(
        tag: _imageUrls[index],
        child: Image.network(
          _imageUrls[index],
          fit: BoxFit.cover,
        ),
      ),
    ),
  ),
)
```

#### Profile Information
```dart
Card(
  margin: const EdgeInsets.all(8),
  child: Padding(
    padding: const EdgeInsets.all(16),
    children: [
      _buildInfoRow('Breed', widget.cat.breed),
      _buildInfoRow('Age', _calculateAge()),
      _buildInfoRow('Gender', widget.cat.gender),
      _buildInfoRow('Breeding Status', 
        widget.cat.isBreeding ? 'Available' : 'Not Available'),
      if (widget.cat.description != null)
        _buildInfoRow('Description', widget.cat.description!),
    ],
  ),
)
```

### Methods

#### Navigation
```dart
void _navigateToEdit() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditCatScreen(cat: widget.cat),
    ),
  );
}

void _showFullScreenImage(String imageUrl) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FullScreenImage(imageUrl: imageUrl),
    ),
  );
}
```

#### Chat Initiation
```dart
Future<void> _startChat() async {
  setState(() => _isLoading = true);
  try {
    final chatRoom = await _chatService.createOrGetChatRoom(
      _authService.currentUser!.id,
      widget.cat.ownerId,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(chatRoom: chatRoom),
      ),
    );
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### Data Loading
```dart
Future<void> _loadOwnerData() async {
  setState(() => _isLoading = true);
  try {
    _owner = await _firestoreService.getUser(widget.cat.ownerId);
    _isCurrentUserOwner = widget.cat.ownerId == _authService.currentUser!.id;
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}

String _calculateAge() {
  final now = DateTime.now();
  final age = now.difference(widget.cat.birthDate);
  final years = age.inDays ~/ 365;
  final months = (age.inDays % 365) ~/ 30;
  
  if (years > 0) {
    return '$years year${years == 1 ? '' : 's'}';
  } else {
    return '$months month${months == 1 ? '' : 's'}';
  }
}
```

## Usage Example

```dart
class CatCard extends StatelessWidget {
  final CatModel cat;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CatDetailsScreen(cat: cat),
        ),
      ),
      child: Card(
        // Cat card UI
      ),
    );
  }
}
```

## Data Flow

### Profile Loading
1. Initial cat data passed through constructor
2. Owner data loaded on mount
3. Images loaded progressively

### User Interactions
1. View full-screen images
2. Edit profile (if owner)
3. Initiate chat
4. Share profile

## Connected Components

### Widgets
- ImageGallery (photo display)
- FullScreenImage (image viewer)
- InfoRow (profile details)
- ActionButtons (user interactions)

### Screens
- EditCatScreen (profile editing)
- ChatDetailScreen (breeding discussions)
- UserProfileScreen (owner profile)

### Services
- FirestoreService (cat data)
- AuthService (user context)
- ChatService (messaging)
- StorageService (images)

## State Management

### Local State
- Loading states
- Image gallery state
- Owner data
- UI interactions

### Global State
- User session
- Cat data
- Chat rooms

## Best Practices
1. Load images efficiently
2. Handle permissions
3. Manage loading states
4. Cache profile data
5. Handle errors gracefully

## Performance Considerations
1. Image optimization
2. Data caching
3. Progressive loading
4. Memory management
5. Network optimization

## Error Handling
1. Image loading errors
2. Data fetch failures
3. Permission errors
4. Navigation errors
5. Chat initiation errors

## Security Considerations
1. Validate data access
2. Protect owner info
3. Handle permissions
4. Secure chat creation
5. Rate limiting 