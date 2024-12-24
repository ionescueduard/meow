# EmptyStateIndicator Documentation

## Overview
`EmptyStateIndicator` is a widget that displays a message when no content is available. It provides a consistent empty state UI across the app with customizable messages, icons, and actions.

## File Location
`lib/widgets/empty_state_indicator.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
```

## Class Definition

### Properties
```dart
class EmptyStateIndicator extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final IconData icon;
  final VoidCallback? onAction;
  final Color? color;
  final double iconSize;
  final String? subtitle;
  
  const EmptyStateIndicator({
    Key? key,
    required this.message,
    this.actionLabel,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.color,
    this.iconSize = 64.0,
    this.subtitle,
  }) : super(key: key);
}
```

### UI Components

#### Main Structure
```dart
Widget build(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(height: 16),
          _buildMessage(),
          if (subtitle != null) _buildSubtitle(),
          if (actionLabel != null && onAction != null)
            _buildActionButton(),
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
    color: color ?? Colors.grey[400],
  );
}
```

#### Message
```dart
Widget _buildMessage() {
  return Text(
    message,
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
      color: Colors.grey[800],
    ),
    textAlign: TextAlign.center,
  );
}
```

#### Subtitle
```dart
Widget _buildSubtitle() {
  return Padding(
    padding: const EdgeInsets.only(
      top: 8,
      bottom: 16,
    ),
    child: Text(
      subtitle!,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    ),
  );
}
```

#### Action Button
```dart
Widget _buildActionButton() {
  return Padding(
    padding: const EdgeInsets.only(top: 16),
    child: ElevatedButton(
      onPressed: onAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
      child: Text(actionLabel!),
    ),
  );
}
```

## Usage Example

```dart
// Basic usage
const EmptyStateIndicator(
  message: 'No items found',
)

// With action
EmptyStateIndicator(
  message: 'No posts yet',
  actionLabel: 'Create Post',
  onAction: () => print('Creating post...'),
)

// With subtitle
EmptyStateIndicator(
  message: 'No messages',
  subtitle: 'Start a conversation with someone',
  icon: Icons.chat_bubble_outline,
)

// Custom styling
EmptyStateIndicator(
  message: 'No notifications',
  icon: Icons.notifications_none,
  color: Colors.blue,
  iconSize: 80,
)
```

## Features

### Display Options
1. Custom message
2. Optional subtitle
3. Custom icon
4. Color theming
5. Size control

### Visual Elements
1. Main icon
2. Message text
3. Subtitle text
4. Action button
5. Custom styling

### Interactions
1. Action button
2. Button feedback
3. Touch ripples
4. Focus handling
5. Keyboard navigation

## Connected Components

### Used By
- PostsList
- ChatList
- NotificationList
- SearchResults
- FavoritesList

### Dependencies
- MaterialApp (theming)
- IconTheme
- TextTheme
- ButtonStyle

## State Management

### Local State
- Button state
- Text layout
- Icon display
- Focus state

### Global State
- Theme data
- Screen context
- Action handler
- Layout size

## Best Practices
1. Clear messaging
2. Helpful guidance
3. Consistent styling
4. Action clarity
5. Visual balance

## Performance Considerations
1. Layout efficiency
2. Memory usage
3. Animation smoothness
4. Rebuild optimization
5. Resource loading

## Error Handling
1. Text overflow
2. Layout constraints
3. Callback safety
4. Theme fallbacks
5. Resource errors

## Security Considerations
1. Message content
2. Action validation
3. Resource usage
4. Context safety
5. Input sanitization

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
  return color ?? Theme.of(context).primaryColor;
}
```

### Layout Calculations
```dart
EdgeInsets getContentPadding() {
  return const EdgeInsets.all(24);
}
```

### Button Styling
```dart
ButtonStyle getActionButtonStyle(BuildContext context) {
  return ElevatedButton.styleFrom(
    backgroundColor: getEffectiveColor(context),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    ),
  );
}
```

## Examples

### Empty Posts List
```dart
EmptyStateIndicator(
  message: 'No Posts Yet',
  subtitle: 'Be the first to share something!',
  actionLabel: 'Create Post',
  icon: Icons.post_add,
  onAction: _createPost,
)
```

### Empty Chat List
```dart
EmptyStateIndicator(
  message: 'No Messages',
  subtitle: 'Start chatting with cat owners',
  icon: Icons.chat_bubble_outline,
  actionLabel: 'Find Users',
  onAction: _navigateToSearch,
)
```

### Search Results
```dart
EmptyStateIndicator(
  message: 'No Results Found',
  subtitle: 'Try different search terms',
  icon: Icons.search_off,
)
``` 