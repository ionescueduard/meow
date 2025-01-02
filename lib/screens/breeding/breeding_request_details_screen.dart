import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/breeding_request_model.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../models/chat_room_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/chat_service.dart';
import '../cat/cat_details_screen.dart';
import '../chat/chat_detail_screen.dart';
import '../profile/profile_screen.dart';

class BreedingRequestDetailsScreen extends StatelessWidget {
  final BreedingRequest request;
  final bool isReceived;

  const BreedingRequestDetailsScreen({
    super.key,
    required this.request,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return const Scaffold();

    // Mark request as seen if it's received and not seen yet
    if (isReceived && !request.seen) {
      firestoreService.markBreedingRequestAsSeen(request.id);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breeding Request Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Container
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<UserModel?>(
                future: firestoreService.getUser(
                  isReceived ? request.requesterId : request.receiverId,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final user = snapshot.data!;
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(userId: user.id),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(user.name[0].toUpperCase())
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isReceived ? 'Requester' : 'Owner',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  Text(
                                    request.status.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(request.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (user.location != null)
                                Text(
                                  user.location!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Cats Container
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cats',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<CatModel?>(
                          future: firestoreService.getCat(
                            isReceived ? request.requesterCatId : request.catId,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final cat = snapshot.data!;
                            return _buildCatCard(context, cat, 'My Cat');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FutureBuilder<CatModel?>(
                          future: firestoreService.getCat(
                            isReceived ? request.catId : request.requesterCatId,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final cat = snapshot.data!;
                            return _buildCatCard(
                              context,
                              cat,
                              isReceived ? "Requester's Cat" : "Owner's Cat",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Message Container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Message',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (request.status == 'accepted')
                        FilledButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('Start Chat'),
                          onPressed: () async {
                            final otherUserId = isReceived
                                ? request.requesterId
                                : request.receiverId;
                            final otherUser = await firestoreService.getUser(otherUserId);
                            if (otherUser == null || !context.mounted) return;

                            final chatRoom = await context.read<ChatService>().getChatRoom(
                              participantIds: [currentUser.uid, otherUserId],
                            );

                            if (chatRoom != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    chatRoom: chatRoom,
                                    otherUser: otherUser,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(request.message),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions Section
            if (request.status == 'pending' && isReceived)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Decline Request'),
                            content: const Text(
                              'Are you sure you want to decline this breeding request?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Decline',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          await firestoreService.updateBreedingRequestStatus(
                            request.id,
                            'rejected',
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Accept Request'),
                            content: const Text(
                              'Are you sure you want to accept this breeding request?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Accept'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          await firestoreService.updateBreedingRequestStatus(
                            request.id,
                            'accepted',
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatCard(BuildContext context, CatModel cat, String label) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CatDetailsScreen(cat: cat),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              CircleAvatar(
                radius: 40,
                backgroundImage: cat.photoUrls.isNotEmpty
                    ? NetworkImage(cat.photoUrls.first)
                    : null,
                child: cat.photoUrls.isEmpty
                    ? const Icon(Icons.pets, size: 40)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                cat.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(cat.breed.toString().split('.').last),
              Text(
                cat.breedingStatus.toString().split('.').last,
                style: TextStyle(
                  color: cat.breedingStatus == BreedingStatus.available
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 