# LoadingIndicator Documentation

## Overview
`LoadingIndicator` is a customizable widget that displays a loading animation with optional text. It provides a consistent loading experience across the app and supports different sizes and styles.

## File Location
`lib/widgets/loading_indicator.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
```

## Class Definition

### Properties
```dart
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool isOverlay;
  final bool showBackground;
  
  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 40.0,
    this.color,
    this.isOverlay = false,
    this.showBackground = true,
  }) : super(key: key);
}
```

### UI Components

#### Main Structure
```dart
Widget build(BuildContext context) {
  final indicator = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildSpinner(),
      if (message != null) _buildMessage(),
    ],
  );
  
  if (isOverlay) {
    return _buildOverlay(indicator);
  }
  
  return Center(child: indicator);
}
```

#### Spinner
```dart
Widget _buildSpinner() {
  return SizedBox(
    width: size,
    height: size,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? Theme.of(context).primaryColor,
      ),
      strokeWidth: size / 10,
    ),
  );
}
```

#### Message
```dart
Widget _buildMessage() {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Text(
      message!,
      style: TextStyle(
        fontSize: 16,
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
      ),
      textAlign: TextAlign.center,
    ),
  );
}
```

#### Overlay
```dart
Widget _buildOverlay(Widget child) {
  return Container(
    color: showBackground
        ? Colors.black.withOpacity(0.5)
        : Colors.transparent,
    child: Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: showBackground
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: child,
      ),
    ),
  );
}
```

## Usage Example

```dart
// Basic usage
const LoadingIndicator()

// With message
const LoadingIndicator(
  message: 'Loading...',
)

// Custom size and color
LoadingIndicator(
  size: 60.0,
  color: Colors.blue,
  message: 'Please wait',
)

// As overlay
const LoadingIndicator(
  isOverlay: true,
  message: 'Uploading...',
)

// Without background
const LoadingIndicator(
  isOverlay: true,
  showBackground: false,
)
```

## Features

### Display Options
1. Custom size
2. Custom color
3. Optional message
4. Overlay mode
5. Background toggle

### Visual Elements
1. Spinner animation
2. Message text
3. Background overlay
4. Container shadow
5. Border radius

### Customization
1. Size control
2. Color theming
3. Text styling
4. Layout options
5. Background opacity

## Connected Components

### Used By
- LoadingScreen
- AsyncButton
- ImageUploader
- DataFetcher
- FormSubmitter

### Dependencies
- MaterialApp (theming)
- CircularProgressIndicator
- Theme data
- Text styles

## State Management

### Local State
- Animation state
- Size calculations
- Color inheritance
- Text layout

### Global State
- Theme data
- Text direction
- Screen size
- Platform info

## Best Practices
1. Consistent sizing
2. Theme compliance
3. Message clarity
4. Performance optimization
5. Accessibility support

## Performance Considerations
1. Animation smoothness
2. Memory usage
3. Rebuild efficiency
4. Layout calculations
5. Overlay handling

## Error Handling
1. Size validation
2. Color fallbacks
3. Text overflow
4. Layout constraints
5. Theme access

## Security Considerations
1. Resource usage
2. Memory limits
3. Animation frames
4. Thread blocking
5. Context safety

## Customization Options
1. Size adjustment
2. Color selection
3. Message format
4. Background style
5. Animation speed

## Accessibility
1. Screen reader text
2. Animation rate
3. Color contrast
4. Touch targets
5. Message clarity

## Implementation Details

### Size Calculations
```dart
double get spinnerSize => size;
double get strokeWidth => size / 10;
double get messagePadding => 16.0;
```

### Color Management
```dart
Color getEffectiveColor(BuildContext context) {
  return color ?? Theme.of(context).primaryColor;
}
```

### Layout Logic
```dart
EdgeInsets getOverlayPadding() {
  return showBackground
      ? const EdgeInsets.all(24)
      : EdgeInsets.zero;
}
```

### Background Styling
```dart
BoxDecoration? getOverlayDecoration() {
  if (!showBackground) return null;
  
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
```

## Examples

### Loading Screen
```dart
Scaffold(
  body: LoadingIndicator(
    message: 'Loading data...',
    isOverlay: true,
  ),
)
```

### Form Submit Button
```dart
ElevatedButton(
  onPressed: isLoading ? null : _handleSubmit,
  child: isLoading
      ? const LoadingIndicator(
          size: 20,
          showBackground: false,
        )
      : const Text('Submit'),
)
```

### Image Upload
```dart
Stack(
  children: [
    Image.network(imageUrl),
    if (isUploading)
      LoadingIndicator(
        message: 'Uploading...',
        isOverlay: true,
        color: Colors.white,
      ),
  ],
)
``` 