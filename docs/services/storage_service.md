# StorageService Documentation

## Overview
`StorageService` manages file storage operations using Firebase Storage. It handles uploading, downloading, and managing media files such as images, videos, and other documents.

## File Location
`lib/services/storage_service.dart`

## Dependencies
```dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
```

## Main Components

### 1. Service Structure
```dart
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final uuid = const Uuid();

  StorageService();
}
```

### 2. Key Features

#### Image Upload
```dart
Future<String> uploadImage(File file, String folder)
Future<List<String>> uploadImages(List<File> files, String folder)
Future<String> uploadProfileImage(File file, String userId)
```
Features:
- Single image upload
- Multiple image upload
- Profile image handling
- Progress tracking
- Compression options

#### File Management
```dart
Future<void> deleteFile(String url)
Future<void> deleteFiles(List<String> urls)
Future<String> getDownloadUrl(String path)
```
Features:
- File deletion
- Batch deletion
- URL generation
- File metadata

#### Media Processing
```dart
Future<File?> compressImage(File file)
Future<List<File>> processImages(List<File> files)
Future<String> generateThumbnail(File videoFile)
```
Features:
- Image compression
- Thumbnail generation
- Format conversion
- Quality optimization

### 3. Implementation Details

#### Image Upload Process
```dart
Future<String> uploadImage(File file, String folder) async {
  final fileName = '${uuid.v4()}${path.extension(file.path)}';
  final ref = _storage.ref().child('$folder/$fileName');
  
  // Optional compression
  final compressedFile = await compressImage(file);
  
  // Upload with metadata
  final metadata = SettableMetadata(
    contentType: 'image/${path.extension(file.path).substring(1)}',
    customMetadata: {'uploaded': DateTime.now().toIso8601String()},
  );
  
  final uploadTask = ref.putFile(compressedFile ?? file, metadata);
  
  // Track progress
  uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
    final progress = snapshot.bytesTransferred / snapshot.totalBytes;
    // Update UI with progress
  });
  
  // Get download URL
  final snapshot = await uploadTask;
  return await snapshot.ref.getDownloadURL();
}
```

#### File Deletion
```dart
Future<void> deleteFile(String url) async {
  try {
    final ref = _storage.refFromURL(url);
    await ref.delete();
  } catch (e) {
    // Handle errors
  }
}
```

### 4. Error Handling
- Upload failures
- Network errors
- Invalid files
- Storage quota exceeded
- Permission errors

### 5. Performance Considerations
- Image compression
- Batch operations
- Progress tracking
- Cache management
- Parallel uploads

### 6. Connected Components

#### Services
- FirestoreService (indirectly)
- ChatService (for media messages)

#### Used By
- Profile image upload
- Cat photo upload
- Chat media sharing
- Post attachments

### 7. Best Practices
- File size limits
- Format validation
- Metadata management
- Error recovery
- Cache cleanup

### 8. Future Improvements
- Video processing
- Advanced compression
- CDN integration
- Backup strategy
- File versioning

## Usage Examples

### Image Upload
```dart
// Upload single image
final url = await storageService.uploadImage(
  imageFile,
  'cat_photos',
);

// Upload multiple images
final urls = await storageService.uploadImages(
  imageFiles,
  'post_photos',
);
```

### Profile Image
```dart
// Upload profile image
final url = await storageService.uploadProfileImage(
  imageFile,
  userId,
);
```

### File Management
```dart
// Delete file
await storageService.deleteFile(fileUrl);

// Get download URL
final url = await storageService.getDownloadUrl(filePath);
```

### Media Processing
```dart
// Compress image
final compressedFile = await storageService.compressImage(imageFile);

// Generate video thumbnail
final thumbnailUrl = await storageService.generateThumbnail(videoFile);
```

### Progress Tracking
```dart
storageService.uploadProgress.listen((progress) {
  // Update UI with upload progress
  print('Upload progress: ${progress * 100}%');
});
``` 