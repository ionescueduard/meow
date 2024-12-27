import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/cat_model.dart';
import '../../models/chat_room_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/chat_service.dart';
import '../chat/chat_detail_screen.dart';
import '../cat/cat_details_screen.dart';

class UserProfileScreen extends StatelessWidget {
  final UserModel user;

  const UserProfileScreen({super.key, required this.user});

  Future<void> _startChat(BuildContext context) async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    // Check if chat room already exists
    final chatService = context.read<ChatService>();
    final existingRoom = await chatService.findExistingChatRoom([currentUser.uid, user.id]);

    if (context.mounted) {
      if (existingRoom != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chatRoom: existingRoom,
              otherUser: user,
            ),
          ),
        );
      } else {
        // Create new chat room
        final newRoom = await chatService.createChatRoom([currentUser.uid, user.id]);
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                chatRoom: newRoom,
                otherUser: user,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    final isCurrentUser = currentUser?.uid == user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
        actions: [
          if (!isCurrentUser)
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () => _startChat(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (user.location != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.location!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  if (user.bio != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Cats section
            Text(
              'Cats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Cats grid
            StreamBuilder<List<CatModel>>(
              stream: context.read<FirestoreService>().getUserCats(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cats = snapshot.data ?? [];
                if (cats.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Icons.pets, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No cats yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: cats.length,
                  itemBuilder: (context, index) {
                    final cat = cats[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CatDetailsScreen(cat: cat),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: cat.photoUrls.isNotEmpty
                                  ? Image.network(
                                      cat.photoUrls.first,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(
                                          Icons.pets,
                                          size: 64,
                                        ),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cat.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
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
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 