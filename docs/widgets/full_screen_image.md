# FullScreenImage Documentation

## Overview
`FullScreenImage` is a widget that displays an image in full-screen mode with zooming and panning capabilities. It supports both network and local images, and includes a hero animation for smooth transitions.

## File Location
`lib/widgets/full_screen_image.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
```

## Class Definition

### Properties
```dart
class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final BoxFit fit;
  final double minScale;
  final double maxScale;
  final bool enableRotation;
  final Color backgroundColor;
  
  const FullScreenImage({
    Key? key,
    required this.imageUrl,
    this.heroTag,
    this.fit = BoxFit.contain,
    this.minScale = PhotoViewComputedScale.contained,
    this.maxScale = PhotoViewComputedScale.covered * 2,
    this.enableRotation = false,
    this.backgroundColor = Colors.black,
  }) : super(key: key);
}
```

### UI Components

#### Main Structure
```dart
Scaffold(
  backgroundColor: backgroundColor,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => Navigator.pop(context),
    ),
  ),
  body: PhotoView(
    imageProvider: NetworkImage(imageUrl),
    heroAttributes: heroTag != null
        ? PhotoViewHeroAttributes(tag: heroTag!)
        : null,
    minScale: minScale,
    maxScale: maxScale,
    enableRotation: enableRotation,
    backgroundDecoration: BoxDecoration(color: backgroundColor),
    loadingBuilder: (context, event) => _buildLoadingIndicator(event),
    errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
  ),
)
```

#### Loading Indicator
```dart
Widget _buildLoadingIndicator(ImageChunkEvent? loadingProgress) {
  if (loadingProgress == null) return const SizedBox.shrink();
  
  return Center(
    child: CircularProgressIndicator(
      value: loadingProgress.expectedTotalBytes != null
          ? loadingProgress.cumulativeBytesLoaded /
              loadingProgress.expectedTotalBytes!
          : null,
    ),
  );
}
```

#### Error Widget
```dart
Widget _buildErrorWidget() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.error_outline, color: Colors.red, size: 48),
        SizedBox(height: 16),
        Text(
          'Failed to load image',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}
```

## Usage Example

```dart
// Basic usage
FullScreenImage(
  imageUrl: 'https://example.com/image.jpg',
)

// With hero animation
FullScreenImage(
  imageUrl: 'https://example.com/image.jpg',
  heroTag: 'unique_image_tag',
)

// With custom settings
FullScreenImage(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.cover,
  minScale: PhotoViewComputedScale.contained * 0.8,
  maxScale: PhotoViewComputedScale.covered * 3,
  enableRotation: true,
  backgroundColor: Colors.grey[900]!,
)
```

## Features

### Image Viewing
1. Pinch to zoom
2. Double-tap to zoom
3. Pan to move
4. Optional rotation
5. Smooth scaling

### Transitions
1. Hero animation support
2. Smooth entry/exit
3. Background fade
4. Gesture-based dismissal

### Loading States
1. Progress indicator
2. Error handling
3. Placeholder support
4. Network status handling

## Connected Components

### Dependencies
- PhotoView (image viewing functionality)
- CachedNetworkImage (optional image caching)

### Used By
- CatDetailsScreen (cat photos)
- PostScreen (post images)
- ChatDetailScreen (shared images)

## State Management

### Local State
- Loading progress
- Scale factor
- Rotation angle
- Pan position

### Lifecycle
1. Image loading
2. Transition animation
3. User interactions
4. Cleanup

## Best Practices
1. Handle loading states
2. Provide error feedback
3. Support hero animations
4. Optimize memory usage
5. Handle gestures properly

## Performance Considerations
1. Image caching
2. Memory management
3. Gesture optimization
4. Transition smoothness
5. Loading optimization

## Error Handling
1. Network errors
2. Invalid URLs
3. Memory limitations
4. Loading timeouts
5. Gesture conflicts

## Security Considerations
1. URL validation
2. Content verification
3. Memory limits
4. Network security
5. Resource cleanup

## Customization Options
1. Background color
2. Scale limits
3. Fit mode
4. Rotation support
5. Loading indicators

## Accessibility
1. Gesture controls
2. Scale limits
3. Rotation limits
4. Error messages
5. Loading feedback 