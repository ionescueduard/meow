# EditCatScreen Documentation

## Overview
`EditCatScreen` provides a form interface for adding new cats or editing existing cat profiles. It allows users to input cat details, upload photos, and manage health records.

## File Location
`lib/screens/cat/edit_cat_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../../models/cat_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
```

## Class Definition

### State
```dart
class _EditCatScreenState extends State<EditCatScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;
  final AuthService _authService = AuthService.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedGender;
  bool _isBreeding = false;
  List<String> _imageUrls = [];
  bool _isLoading = false;
}
```

### Properties
- `_firestoreService`: Service for managing cat data
- `_storageService`: Service for managing image uploads
- `_authService`: Service for user authentication
- `_formKey`: Form validation key
- `_nameController`: Controls cat name input
- `_breedController`: Controls breed input
- `_descriptionController`: Controls description input
- `_birthDate`: Cat's birth date
- `_selectedGender`: Selected gender
- `_isBreeding`: Breeding availability status
- `_imageUrls`: List of cat photo URLs
- `_isLoading`: Loading state indicator

### UI Components

#### App Bar
```dart
AppBar(
  title: Text(widget.cat == null ? 'Add Cat' : 'Edit Cat'),
  actions: [
    IconButton(
      icon: const Icon(Icons.check),
      onPressed: _isLoading ? null : _saveCat,
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
      _buildNameField(),
      const SizedBox(height: 16),
      _buildBreedField(),
      const SizedBox(height: 16),
      _buildBirthDateField(),
      const SizedBox(height: 16),
      _buildGenderField(),
      const SizedBox(height: 16),
      _buildBreedingSwitch(),
      const SizedBox(height: 16),
      _buildDescriptionField(),
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
Widget _buildNameField() {
  return TextFormField(
    controller: _nameController,
    decoration: const InputDecoration(
      labelText: 'Name',
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a name';
      }
      return null;
    },
  );
}

Widget _buildBreedField() {
  return TextFormField(
    controller: _breedController,
    decoration: const InputDecoration(
      labelText: 'Breed',
      border: OutlineInputBorder(),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a breed';
      }
      return null;
    },
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
      final url = await _storageService.uploadCatImage(image);
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
Future<void> _saveCat() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);
  try {
    final cat = CatModel(
      id: widget.cat?.id,
      ownerId: _authService.currentUser!.id,
      name: _nameController.text,
      breed: _breedController.text,
      birthDate: _birthDate!,
      gender: _selectedGender!,
      isBreeding: _isBreeding,
      description: _descriptionController.text,
      imageUrls: _imageUrls,
    );

    if (widget.cat == null) {
      await _firestoreService.addCat(cat);
    } else {
      await _firestoreService.updateCat(cat);
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
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditCatScreen()),
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
3. Data persistence
4. Navigation flow

### Image Handling
1. Image selection
2. Upload to storage
3. URL management
4. Deletion handling

## Connected Components

### Widgets
- ImagePicker (photo selection)
- DatePicker (birth date)
- GenderSelector (gender selection)
- LoadingIndicator (loading states)

### Screens
- ProfileScreen (cat list)
- CatDetailsScreen (view cat)

### Services
- FirestoreService (data management)
- StorageService (image handling)
- AuthService (user context)

## State Management

### Local State
- Form inputs
- Image list
- Loading states
- Validation state

### Global State
- User session
- Cat data
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
2. Protect cat data
3. Handle permissions
4. Secure form submission
5. Rate limiting 