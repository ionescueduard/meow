# CatModel Documentation

## Overview
`CatModel` represents a cat in the application. It contains comprehensive information about a cat including its basic details, health records, breeding information, and media content.

## File Location
`lib/models/cat_model.dart`

## Dependencies
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
```

## Class Definition

### Properties
```dart
class CatModel {
  final String id;
  final String userId;
  final String name;
  final String breed;
  final String gender;
  final DateTime birthDate;
  final String description;
  final List<String> photoUrls;
  final bool availableForBreeding;
  final GeoFirePoint? location;
  final List<HealthRecord> healthRecords;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> breedingPreferences;
}
```

### Property Details
- `id`: Unique identifier for the cat
- `userId`: Owner's user ID
- `name`: Cat's name
- `breed`: Cat's breed
- `gender`: Cat's gender (enum: male/female)
- `birthDate`: Cat's date of birth
- `description`: Detailed description of the cat
- `photoUrls`: List of photo URLs
- `availableForBreeding`: Whether the cat is available for breeding
- `location`: Geographic location (for breeding search)
- `healthRecords`: List of health records
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp
- `breedingPreferences`: Breeding-related preferences

### Nested Classes

#### HealthRecord
```dart
class HealthRecord {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? documentUrl;
  final String type;
}
```

### Constructor
```dart
CatModel({
  required this.id,
  required this.userId,
  required this.name,
  required this.breed,
  required this.gender,
  required this.birthDate,
  required this.description,
  required this.photoUrls,
  this.availableForBreeding = false,
  this.location,
  List<HealthRecord>? healthRecords,
  required this.createdAt,
  required this.updatedAt,
  Map<String, dynamic>? breedingPreferences,
}) : healthRecords = healthRecords ?? [],
     breedingPreferences = breedingPreferences ?? {};
```

### Factory Constructors

#### From Map
```dart
factory CatModel.fromMap(Map<String, dynamic> map, String id) {
  return CatModel(
    id: id,
    userId: map['userId'] as String,
    name: map['name'] as String,
    breed: map['breed'] as String,
    gender: map['gender'] as String,
    birthDate: (map['birthDate'] as Timestamp).toDate(),
    description: map['description'] as String,
    photoUrls: List<String>.from(map['photoUrls']),
    availableForBreeding: map['availableForBreeding'] as bool? ?? false,
    location: map['location'] != null
        ? GeoFirePoint(
            map['location']['geopoint'].latitude,
            map['location']['geopoint'].longitude,
          )
        : null,
    healthRecords: (map['healthRecords'] as List?)
        ?.map((e) => HealthRecord.fromMap(e as Map<String, dynamic>))
        .toList() ?? [],
    createdAt: (map['createdAt'] as Timestamp).toDate(),
    updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    breedingPreferences: Map<String, dynamic>.from(
      map['breedingPreferences'] ?? {},
    ),
  );
}
```

### Methods

#### To Map
```dart
Map<String, dynamic> toMap() {
  return {
    'userId': userId,
    'name': name,
    'breed': breed,
    'gender': gender,
    'birthDate': Timestamp.fromDate(birthDate),
    'description': description,
    'photoUrls': photoUrls,
    'availableForBreeding': availableForBreeding,
    'location': location?.data,
    'healthRecords': healthRecords.map((e) => e.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'breedingPreferences': breedingPreferences,
  };
}
```

#### Copy With
```dart
CatModel copyWith({
  String? name,
  String? description,
  List<String>? photoUrls,
  bool? availableForBreeding,
  GeoFirePoint? location,
  List<HealthRecord>? healthRecords,
  Map<String, dynamic>? breedingPreferences,
}) {
  return CatModel(
    id: id,
    userId: userId,
    name: name ?? this.name,
    breed: breed,
    gender: gender,
    birthDate: birthDate,
    description: description ?? this.description,
    photoUrls: photoUrls ?? this.photoUrls,
    availableForBreeding: availableForBreeding ?? this.availableForBreeding,
    location: location ?? this.location,
    healthRecords: healthRecords ?? this.healthRecords,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
    breedingPreferences: breedingPreferences ?? this.breedingPreferences,
  );
}
```

## Usage Examples

### Creating a New Cat
```dart
final cat = CatModel(
  id: 'cat123',
  userId: 'user123',
  name: 'Whiskers',
  breed: 'Persian',
  gender: 'Female',
  birthDate: DateTime(2020, 5, 15),
  description: 'Friendly Persian cat',
  photoUrls: ['url1', 'url2'],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);
```

### Adding Health Records
```dart
final healthRecord = HealthRecord(
  id: 'record123',
  title: 'Annual Checkup',
  description: 'Regular health checkup',
  date: DateTime.now(),
  type: 'checkup',
);

final updatedCat = cat.copyWith(
  healthRecords: [...cat.healthRecords, healthRecord],
);
```

### Setting Location
```dart
final location = GeoFirePoint(37.7749, -122.4194);
final updatedCat = cat.copyWith(location: location);
```

## Connected Components

### Used By
- FirestoreService
- BreedingScreen
- CatDetailsScreen
- EditCatScreen

### Related Models
- UserModel (through ownership)
- PostModel (through references)
- BreedingRequestModel (through participation)

## Best Practices
1. Validate all required fields
2. Handle location data carefully
3. Maintain photo URLs properly
4. Keep health records organized
5. Validate breeding preferences

## Security Considerations
1. Validate owner permissions
2. Protect location data
3. Secure health records
4. Control breeding access
5. Handle media securely 