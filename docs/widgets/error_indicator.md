# ErrorIndicator Documentation

## Overview
`ErrorIndicator` is a widget that displays error messages and provides retry functionality. It shows a consistent error UI across the app with customizable messages, icons, and actions.

## File Location
`lib/widgets/error_indicator.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
```

## Class Definition

### Properties
```dart
class ErrorIndicator extends StatelessWidget {
  final String message;
  final String? details;
  final IconData icon;
  final VoidCallback? onRetry;
  final bool showRetry;
  final Color? color;
  final double iconSize;
  
  const ErrorIndicator({
    Key? key,
    required this.message,
    this.details,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.showRetry = true,
    this.color,
    this.iconSize = 48.0,
  }) : super(key: key);
}
```

### UI Components

#### Main Structure
```dart
Widget build(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 16),
          _buildMessage(),
          if (details != null) _buildDetails(),
          if (showRetry && onRetry != null) _buildRetryButton(),
        ],
      ),
    ),
  );
}
```

#### Icon
```dart
Widget _buildIcon() {
  return Icon(
    icon,
    size: iconSize,
    color: color ?? Theme.of(context).colorScheme.error,
  );
}
```

#### Message
```dart
Widget _buildMessage() {
  return Text(
    message,
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
      color: color ?? Theme.of(context).colorScheme.error,
    ),
    textAlign: TextAlign.center,
  );
}
```

#### Details
```dart
Widget _buildDetails() {
  return Padding(
    padding: const EdgeInsets.only(
      top: 8,
      bottom: 16,
    ),
    child: Text(
      details!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    ),
  );
}
```

#### Retry Button
```dart
Widget _buildRetryButton() {
  return ElevatedButton.icon(
    onPressed: onRetry,
    icon: const Icon(Icons.refresh),
    label: const Text('Retry'),
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: color ?? Theme.of(context).colorScheme.error,
    ),
  );
}
```

## Usage Example

```dart
// Basic usage
const ErrorIndicator(
  message: 'Something went wrong',
)

// With retry callback
ErrorIndicator(
  message: 'Failed to load data',
  onRetry: () => print('Retrying...'),
)

// With details
ErrorIndicator(
  message: 'Network Error',
  details: 'Please check your internet connection',
  onRetry: _handleRetry,
)

// Custom styling
ErrorIndicator(
  message: 'Upload Failed',
  icon: Icons.cloud_off,
  color: Colors.orange,
  iconSize: 64,
  showRetry: false,
)
```

## Features

### Display Options
1. Custom message
2. Optional details
3. Custom icon
4. Color theming
5. Size control

### Visual Elements
1. Error icon
2. Message text
3. Details text
4. Retry button
5. Custom styling

### Interactions
1. Retry action
2. Button feedback
3. Touch ripples
4. Focus handling
5. Keyboard navigation

## Connected Components

### Used By
- ErrorScreen
- NetworkHandler
- DataFetcher
- FormValidator
- AsyncOperation

### Dependencies
- MaterialApp (theming)
- IconTheme
- TextTheme
- ButtonStyle

## State Management

### Local State
- Button state
- Text layout
- Icon animation
- Focus state

### Global State
- Theme data
- Error context
- Retry handler
- Screen size

## Best Practices
1. Clear messaging
2. Consistent styling
3. Helpful details
4. Action clarity
5. Error recovery

## Performance Considerations
1. Layout efficiency
2. Memory usage
3. Animation smoothness
4. Rebuild optimization
5. Resource loading

## Error Handling
1. Message formatting
2. Layout overflow
3. Callback safety
4. Theme fallbacks
5. Resource errors

## Security Considerations
1. Error details
2. Message sanitization
3. Action validation
4. Resource usage
5. Context safety

## Customization Options
1. Message style
2. Icon choice
3. Color scheme
4. Button style
5. Layout options

## Accessibility
1. Screen reader text
2. Focus navigation
3. Color contrast
4. Touch targets
5. Action labels

## Implementation Details

### Message Formatting
```dart
String getFormattedMessage() {
  return message.trim();
}
```

### Color Management
```dart
Color getEffectiveColor(BuildContext context) {
  return color ?? Theme.of(context).colorScheme.error;
}
```

### Layout Calculations
```dart
EdgeInsets getContentPadding() {
  return const EdgeInsets.all(16);
}
```

### Button Styling
```dart
ButtonStyle getRetryButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: getEffectiveColor(context),
  );
}
```

## Examples

### Network Error
```dart
ErrorIndicator(
  message: 'Network Error',
  details: 'Unable to connect to the server',
  icon: Icons.wifi_off,
  onRetry: _retryConnection,
)
```

### Form Validation
```dart
ErrorIndicator(
  message: 'Invalid Input',
  details: 'Please check the highlighted fields',
  icon: Icons.warning_amber,
  showRetry: false,
)
```

### Data Loading
```dart
ErrorIndicator(
  message: 'Failed to Load Data',
  details: error.toString(),
  onRetry: () => _loadData(),
)
``` 