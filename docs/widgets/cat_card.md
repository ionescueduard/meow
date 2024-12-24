# CatCard Documentation

## Overview
`CatCard` is a reusable widget that displays a cat's profile information in a card format. It shows the cat's image, name, breed, age, and other relevant information. The widget is designed to be used in various screens such as the breeding screen, profile screen, and search results.

## File Location
`lib/widgets/cat_card.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../models/cat_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../screens/cat/cat_details_screen.dart';
```

## Class Definition

### Properties
```dart
class CatCard extends StatelessWidget {
  final CatModel cat;
  final UserModel? owner;
  final VoidCallback? onTap;
  final bool showOwner;
  final bool showBreedingStatus;
  final bool isSelectable;
  final bool isSelected;
  
  const CatCard({
    Key? key,
    required this.cat,
    this.owner,
    this.onTap,
    this.showOwner = true,
    this.showBreedingStatus = false,
    this.isSelectable = false,
    this.isSelected = false,
  }) : super(key: key);
}
```

### UI Components

#### Main Structure
```dart
Card(
  clipBehavior: Clip.antiAlias,
  child: InkWell(
    onTap: onTap ?? () => _navigateToCatDetails(context),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImage(),
        _buildInfo(),
        if (showBreedingStatus) _buildBreedingStatus(),
        if (showOwner && owner != null) _buildOwnerInfo(),
      ],
    ),
  ),
)
```

#### Image Section
```dart
Widget _buildImage() {
  return Stack(
    children: [
      AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          cat.imageUrls.first,
          fit: BoxFit.cover,
        ),
      ),
      if (isSelectable)
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_circle,
              color: isSelected ? Colors.blue : Colors.transparent,
            ),
          ),
        ),
    ],
  );
}
```

#### Info Section
```dart
Widget _buildInfo() {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cat.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${cat.breed} • ${_calculateAge()}',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}
```

#### Breeding Status
```dart
Widget _buildBreedingStatus() {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
    decoration: BoxDecoration(
      color: cat.isBreeding ? Colors.green[100] : Colors.grey[100],
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      cat.isBreeding ? 'Available for Breeding' : 'Not Available',
      style: TextStyle(
        color: cat.isBreeding ? Colors.green[900] : Colors.grey[700],
        fontSize: 12,
      ),
    ),
  );
}
```

### Methods

#### Age Calculation
```dart
String _calculateAge() {
  final now = DateTime.now();
  final age = now.difference(cat.birthDate);
  final years = age.inDays ~/ 365;
  final months = (age.inDays % 365) ~/ 30;
  
  if (years > 0) {
    return '$years year${years == 1 ? '' : 's'}';
  } else {
    return '$months month${months == 1 ? '' : 's'}';
  }
}
```

#### Navigation
```dart
void _navigateToCatDetails(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CatDetailsScreen(cat: cat),
    ),
  );
}
```

## Usage Example

```dart
// Basic usage
CatCard(
  cat: catModel,
)

// With owner information
CatCard(
  cat: catModel,
  owner: ownerModel,
  showOwner: true,
)

// For breeding screen
CatCard(
  cat: catModel,
  showBreedingStatus: true,
)

// Selectable card
CatCard(
  cat: catModel,
  isSelectable: true,
  isSelected: true,
  onTap: () => print('Cat selected'),
)
```

## Features

### Display
1. Cat image
2. Basic information
3. Breeding status
4. Owner details
5. Selection state

### Interactions
1. Tap to view details
2. Selection toggle
3. Image preview
4. Owner profile
5. Breeding request

### Visual Elements
1. Hero animation
2. Status indicators
3. Selection markers
4. Loading states
5. Error placeholders

## Connected Components

### Models
- CatModel (cat data)
- UserModel (owner data)
- BreedingModel (status)

### Services
- FirestoreService (data)
- StorageService (images)
- BreedingService (status)

## State Management

### Local State
- Selection state
- Loading states
- Error states
- Animation states

### Global State
- Cat data
- Owner data
- Breeding status
- User permissions

## Best Practices
1. Handle loading states
2. Optimize images
3. Manage errors
4. Cache data
5. Handle permissions

## Performance Considerations
1. Image optimization
2. Memory management
3. State updates
4. Animation performance
5. Data caching

## Error Handling
1. Image loading
2. Data fetching
3. Navigation errors
4. Permission errors
5. State updates

## Security Considerations
1. Data access
2. Image security
3. Owner privacy
4. Breeding status
5. User permissions

## Customization Options
1. Show/hide elements
2. Layout options
3. Image display
4. Status indicators
5. Selection style

## Accessibility
1. Image descriptions
2. Status labels
3. Selection state
4. Touch targets
5. Color contrast 