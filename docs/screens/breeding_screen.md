# BreedingScreen Documentation

## Overview
`BreedingScreen` displays a list of cats available for breeding, with filtering options based on breed, location, and other criteria. It allows users to view cat profiles and initiate breeding requests.

## File Location
`lib/screens/breeding/breeding_screen.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/cat_model.dart';
import '../../services/firestore_service.dart';
import '../cat/cat_details_screen.dart';
```

## Class Definition

### State
```dart
class _BreedingScreenState extends State<BreedingScreen> {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedBreed;
  String? _selectedGender;
  double _maxDistance = 50.0;
  Position? _currentPosition;
  List<CatModel> _cats = [];
}
```

### Properties
- `_firestoreService`: Service for fetching and managing cat data
- `_searchController`: Controls search input
- `_selectedBreed`: Currently selected breed filter
- `_selectedGender`: Currently selected gender filter
- `_maxDistance`: Maximum distance for location-based search
- `_currentPosition`: User's current location
- `_cats`: List of filtered cats

### UI Components

#### App Bar
```dart
AppBar(
  title: const Text('Find Breeding Partners'),
  actions: [
    IconButton(
      icon: const Icon(Icons.filter_list),
      onPressed: _showFilterDialog,
    ),
  ],
)
```

#### Search Bar
```dart
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: 'Search by breed...',
    prefixIcon: const Icon(Icons.search),
    border: OutlineInputBorder(),
  ),
  onChanged: _onSearchChanged,
)
```

#### Filter Dialog
```dart
Future<void> _showFilterDialog() async {
  await showDialog(
    context: context,
    builder: (context) => FilterDialog(
      selectedBreed: _selectedBreed,
      selectedGender: _selectedGender,
      maxDistance: _maxDistance,
      onApplyFilters: _applyFilters,
    ),
  );
}
```

#### Cat List
```dart
StreamBuilder<List<CatModel>>(
  stream: _firestoreService.searchCats(
    breed: _selectedBreed,
    gender: _selectedGender,
    location: _currentPosition != null
        ? {
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude,
            'maxDistance': _maxDistance,
          }
        : null,
  ),
  builder: (context, snapshot) {
    if (snapshot.hasError) {
      return const Center(child: Text('Error loading cats'));
    }

    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final cats = snapshot.data!;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: cats.length,
      itemBuilder: (context, index) => CatCard(
        cat: cats[index],
        onTap: () => _navigateToCatDetails(cats[index]),
      ),
    );
  },
)
```

### Methods

#### Location Handling
```dart
Future<void> _getCurrentLocation() async {
  try {
    final position = await Geolocator.getCurrentPosition();
    setState(() => _currentPosition = position);
  } catch (e) {
    // Handle location error
  }
}

Future<void> _requestLocationPermission() async {
  final permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    await _getCurrentLocation();
  }
}
```

#### Filter Application
```dart
void _applyFilters({
  String? breed,
  String? gender,
  double? maxDistance,
}) {
  setState(() {
    _selectedBreed = breed;
    _selectedGender = gender;
    _maxDistance = maxDistance ?? _maxDistance;
  });
}
```

#### Navigation
```dart
void _navigateToCatDetails(CatModel cat) {
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
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const BreedingScreen();
  }
}
```

## Data Flow

### Cat Loading
1. Initial cats loaded through `StreamBuilder`
2. Filtered based on search criteria
3. Real-time updates through Firestore stream

### Filter Application
1. User selects filters
2. Filters applied to query
3. Results updated in real-time

## Connected Components

### Widgets
- CatCard (displays individual cats)
- FilterDialog (filter selection)
- LoadingIndicator (shows loading state)

### Screens
- CatDetailsScreen (view cat details)
- ChatScreen (initiate breeding discussion)

### Services
- FirestoreService (cat data management)
- GeolocatorService (location services)
- NotificationService (breeding requests)

## State Management

### Local State
- Filter selections
- Search query
- Location data
- Cat list

### Global State
- User location permissions
- Breeding requests
- Chat sessions

## Best Practices
1. Handle location permissions
2. Implement efficient filtering
3. Manage memory usage
4. Cache search results
5. Handle errors gracefully

## Performance Considerations
1. Lazy loading of images
2. Efficient filtering
3. Location updates
4. Memory management
5. Network optimization

## Error Handling
1. Location permission denied
2. Network errors
3. Search failures
4. Filter errors
5. Navigation errors

## Security Considerations
1. Validate location access
2. Protect user location
3. Secure breeding requests
4. Handle sensitive data
5. Rate limiting 