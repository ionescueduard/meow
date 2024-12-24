# EditPostScreen Documentation

## Overview
`EditPostScreen` provides a form interface for creating new posts or editing existing ones. It allows users to write content, upload images, tag cats, and manage post visibility.

## File Location
`lib/screens/post/edit_post_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../models/cat_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
```

## Class Definition

### State
```dart
class _EditPostScreenState extends State<EditPostScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  final AuthService _authService = AuthService.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  List<String> _imageUrls = [];
  List<String> _selectedCatIds = [];
  bool _isPublic = true;
  bool _isLoading = false;
  List<CatModel> _userCats = [];
}
```

### Properties
- `_firestoreService`: Service for managing post data
- `_storageService`: Service for managing image uploads
- `_authService`: Service for user authentication
- `_formKey`: Form validation key
- `_contentController`: Controls post content input
- `_imageUrls`: List of post image URLs
- `_selectedCatIds`: IDs of tagged cats
- `_isPublic`: Post visibility status
- `_isLoading`: Loading state indicator
- `_userCats`: List of user's cats for tagging

### UI Components

#### App Bar
```dart
AppBar(
  title: Text(widget.post == null ? 'New Post' : 'Edit Post'),
  actions: [
    IconButton(
      icon: const Icon(Icons.check),
      onPressed: _isLoading ? null : _savePost,
    ),
  ],
)
```

#### Form
```dart
Form(
  key: _formKey,
  child: ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _buildImageSection(),
      const SizedBox(height: 16),
      _buildContentField(),
      const SizedBox(height: 16),
      _buildCatSelector(),
      const SizedBox(height: 16),
      _buildVisibilityToggle(),
    ],
  ),
)
```

#### Image Section
```dart
Widget _buildImageSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Photos', style: Theme.of(context).textTheme.subtitle1),
      const SizedBox(height: 8),
      SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _imageUrls.length + 1,
          itemBuilder: (context, index) {
            if (index == _imageUrls.length) {
              return _buildAddPhotoButton();
            }
            return _buildPhotoCard(_imageUrls[index]);
          },
        ),
      ),
    ],
  );
}
```

### Methods

#### Form Fields
```dart
Widget _buildContentField() {
  return TextFormField(
    controller: _contentController,
    maxLines: 5,
    decoration: const InputDecoration(
      labelText: 'What\'s on your mind?',
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter some content';
      }
      return null;
    },
  );
}

Widget _buildCatSelector() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Tag Cats', style: Theme.of(context).textTheme.subtitle1),
      Wrap(
        spacing: 8,
        children: _userCats.map((cat) => ChoiceChip(
          label: Text(cat.name),
          selected: _selectedCatIds.contains(cat.id),
          onSelected: (selected) => _toggleCatSelection(cat.id),
        )).toList(),
      ),
    ],
  );
}
```

#### Image Handling
```dart
Future<void> _pickImage() async {
  setState(() => _isLoading = true);
  try {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final url = await _storageService.uploadPostImage(image);
      setState(() => _imageUrls.add(url));
    }
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}

Future<void> _removeImage(String url) async {
  setState(() => _isLoading = true);
  try {
    await _storageService.deleteImage(url);
    setState(() => _imageUrls.remove(url));
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}
```

#### Save Functionality
```dart
Future<void> _savePost() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);
  try {
    final post = PostModel(
      id: widget.post?.id,
      userId: _authService.currentUser!.id,
      content: _contentController.text,
      imageUrls: _imageUrls,
      catIds: _selectedCatIds,
      isPublic: _isPublic,
      createdAt: DateTime.now(),
      likes: [],
      commentCount: 0,
    );

    if (widget.post == null) {
      await _firestoreService.addPost(post);
    } else {
      await _firestoreService.updatePost(post);
    }

    Navigator.pop(context);
  } catch (e) {
    // Handle error
  } finally {
    setState(() => _isLoading = false);
  }
}
```

## Usage Example

```dart
class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditPostScreen()),
      ),
      child: const Icon(Icons.add),
    );
  }
}
```

## Data Flow

### Form Management
1. Input validation
2. Image uploads
3. Cat selection
4. Data persistence

### Image Handling
1. Image selection
2. Upload to storage
3. URL management
4. Deletion handling

## Connected Components

### Widgets
- ImagePicker (photo selection)
- CatSelector (cat tagging)
- VisibilityToggle (privacy settings)
- LoadingIndicator (loading states)

### Screens
- FeedScreen (post list)
- PostDetailScreen (view post)

### Services
- FirestoreService (data management)
- StorageService (image handling)
- AuthService (user context)

## State Management

### Local State
- Form inputs
- Image list
- Selected cats
- Loading states

### Global State
- User session
- Post data
- Storage uploads

## Best Practices
1. Validate inputs thoroughly
2. Handle image uploads efficiently
3. Manage loading states
4. Cache form data
5. Handle errors gracefully

## Performance Considerations
1. Image optimization
2. Form validation
3. Storage uploads
4. Memory management
5. Network optimization

## Error Handling
1. Form validation errors
2. Image upload failures
3. Network errors
4. Storage errors
5. Navigation errors

## Security Considerations
1. Validate file uploads
2. Protect post data
3. Handle permissions
4. Secure form submission
5. Rate limiting 