# BreedingRequestCard Documentation

## Overview
`BreedingRequestCard` is a widget that displays a breeding request, including information about both cats involved, the request status, and action buttons. The widget is designed to be used in the breeding requests screen and supports various user interactions.

## File Location
`lib/widgets/breeding_request_card.dart`

## Dependencies
```dart
import 'package:flutter/material.dart';
import '../models/breeding_request_model.dart';
import '../models/cat_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/cat/cat_details_screen.dart';
```

## Class Definition

### Properties
```dart
class BreedingRequestCard extends StatelessWidget {
  final BreedingRequestModel request;
  final CatModel requestedCat;
  final CatModel proposedCat;
  final UserModel requester;
  final UserModel owner;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;
  
  const BreedingRequestCard({
    Key? key,
    required this.request,
    required this.requestedCat,
    required this.proposedCat,
    required this.requester,
    required this.owner,
    this.onAccept,
    this.onDecline,
    this.onCancel,
  }) : super(key: key);
}
```

### UI Components

#### Main Structure
```dart
Card(
  margin: const EdgeInsets.all(8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildHeader(),
      _buildCatsInfo(),
      _buildStatus(),
      if (_showActions) _buildActions(),
    ],
  ),
)
```

#### Header
```dart
Widget _buildHeader() {
  return ListTile(
    leading: CircleAvatar(
      backgroundImage: NetworkImage(requester.profileImageUrl),
    ),
    title: Text(
      '${requester.username} wants to breed with your cat',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Text(
      _formatTimestamp(request.createdAt),
      style: TextStyle(
        color: Colors.grey[600],
      ),
    ),
  );
}
```

#### Cats Information
```dart
Widget _buildCatsInfo() {
  return Row(
    children: [
      Expanded(
        child: _buildCatCard(
          requestedCat,
          'Requested Cat',
        ),
      ),
      const Icon(Icons.compare_arrows),
      Expanded(
        child: _buildCatCard(
          proposedCat,
          'Proposed Cat',
        ),
      ),
    ],
  );
}

Widget _buildCatCard(CatModel cat, String label) {
  return GestureDetector(
    onTap: () => _navigateToCatDetails(context, cat),
    child: Card(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              cat.imageUrls.first,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  cat.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${cat.breed} • ${_calculateAge(cat.birthDate)}',
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
```

#### Status and Actions
```dart
Widget _buildStatus() {
  return Container(
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        Icon(
          _getStatusIcon(),
          color: _getStatusColor(),
        ),
        const SizedBox(width: 8),
        Text(
          _getStatusText(),
          style: TextStyle(
            color: _getStatusColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _buildActions() {
  return ButtonBar(
    children: [
      TextButton(
        onPressed: () => _startChat(context),
        child: const Text('Message'),
      ),
      if (request.status == BreedingRequestStatus.pending)
        ..._buildPendingActions(),
      if (request.status == BreedingRequestStatus.accepted)
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
    ],
  );
}
```

### Methods

#### Navigation
```dart
void _navigateToCatDetails(BuildContext context, CatModel cat) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CatDetailsScreen(cat: cat),
    ),
  );
}

Future<void> _startChat(BuildContext context) async {
  final chatRoom = await FirestoreService.instance.createOrGetChatRoom(
    requester.id,
    owner.id,
  );
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatDetailScreen(chatRoom: chatRoom),
    ),
  );
}
```

#### Status Helpers
```dart
IconData _getStatusIcon() {
  switch (request.status) {
    case BreedingRequestStatus.pending:
      return Icons.schedule;
    case BreedingRequestStatus.accepted:
      return Icons.check_circle;
    case BreedingRequestStatus.declined:
      return Icons.cancel;
    case BreedingRequestStatus.completed:
      return Icons.done_all;
  }
}

Color _getStatusColor() {
  switch (request.status) {
    case BreedingRequestStatus.pending:
      return Colors.orange;
    case BreedingRequestStatus.accepted:
      return Colors.green;
    case BreedingRequestStatus.declined:
      return Colors.red;
    case BreedingRequestStatus.completed:
      return Colors.blue;
  }
}
```

## Usage Example

```dart
// Basic usage
BreedingRequestCard(
  request: requestModel,
  requestedCat: requestedCatModel,
  proposedCat: proposedCatModel,
  requester: requesterModel,
  owner: ownerModel,
)

// With callbacks
BreedingRequestCard(
  request: requestModel,
  requestedCat: requestedCatModel,
  proposedCat: proposedCatModel,
  requester: requesterModel,
  owner: ownerModel,
  onAccept: () => print('Request accepted'),
  onDecline: () => print('Request declined'),
  onCancel: () => print('Request cancelled'),
)
```

## Features

### Display
1. User information
2. Cat profiles
3. Request status
4. Timestamps
5. Action buttons

### Interactions
1. View cat details
2. Start chat
3. Accept request
4. Decline request
5. Cancel request

### Visual Elements
1. Status indicators
2. Cat images
3. User avatars
4. Action buttons
5. Loading states

## Connected Components

### Models
- BreedingRequestModel (request data)
- CatModel (cat data)
- UserModel (user data)
- ChatRoomModel (messaging)

### Services
- FirestoreService (data)
- AuthService (permissions)
- ChatService (messaging)

## State Management

### Local State
- Loading states
- Error states
- UI interactions
- Action states

### Global State
- User session
- Request data
- Cat data
- Chat data

## Best Practices
1. Handle loading states
2. Manage permissions
3. Validate actions
4. Cache data
5. Handle errors

## Performance Considerations
1. Image optimization
2. Data caching
3. State updates
4. Memory usage
5. UI responsiveness

## Error Handling
1. Data loading
2. Action failures
3. Navigation errors
4. Permission errors
5. Network issues

## Security Considerations
1. User permissions
2. Data access
3. Action validation
4. Chat security
5. Image security

## Customization Options
1. Layout options
2. Status display
3. Action buttons
4. Image display
5. Style theming

## Accessibility
1. Screen reader support
2. Action labels
3. Status descriptions
4. Touch targets
5. Color contrast 