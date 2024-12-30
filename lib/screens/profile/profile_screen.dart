import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meow/models/chat_room_model.dart';
import 'package:meow/screens/chat/chat_detail_screen.dart';
import 'package:meow/services/chat_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../screens/cat/edit_cat_screen.dart';
import '../../screens/cat/cat_details_screen.dart';
import 'followers_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // null means current user's profile

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Widget _buildFollowCount(BuildContext context, String label, int count, UserModel user, int initialTab) {
    return GestureDetector(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FollowersScreen(
            user: user,
            initialTab: initialTab,
          ),
        ),
      ),
    );
  }

  void _navigateToAddCat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditCatScreen(),
      ),
    );
  }

  void _navigateToCatDetails(BuildContext context, CatModel cat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatDetailsScreen(cat: cat),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please sign in to view profile'));
    }

    final firestoreService = context.read<FirestoreService>();
    final storageService = context.read<StorageService>();
    final userId = widget.userId ?? currentUser.uid;
    final isProfileOfCurrentUser = currentUser.uid == userId;

    return StreamBuilder<UserModel?>(
      stream: firestoreService.getUserStream(userId),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return Center(child: Text('Error: ${userSnapshot.error}'));
        }

        final user = userSnapshot.data;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        if (!_isEditing) {
          _nameController.text = user.name;
          _locationController.text = user.location ?? '';
          _bioController.text = user.bio ?? '';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(user.name),
          ), 
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Row(
                  children: [
                    // Profile Picture Section
                    Stack(
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
                        if (isProfileOfCurrentUser)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                onPressed: () async {
                                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                                  if (pickedFile == null) return;

                                  setState(() => _isLoading = true);
                                  try {
                                    // Upload new photo
                                    final photoUrl = await storageService.uploadUserProfilePhoto(pickedFile, user.id);

                                    // Delete old photo if exists
                                    if (user.photoUrl != null) {
                                      await storageService.deleteFile(user.photoUrl!);
                                    }

                                    // Update user profile
                                    await firestoreService.saveUser(user.copyWith(photoUrl: photoUrl));
                                  } finally {
                                    setState(() => _isLoading = false);
                                  }
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Followers and Following Counts Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StreamBuilder<List<UserModel>>(
                              stream: firestoreService.getFollowers(user.id),
                              builder: (context, snapshot) {
                                final followers = snapshot.data ?? [];
                                return _buildFollowCount(context, 'Followers', followers.length, user, 0);
                              },
                            ),
                            StreamBuilder<List<UserModel>>(
                              stream: firestoreService.getFollowing(user.id),
                              builder: (context, snapshot) {
                                final following = snapshot.data ?? [];
                                return _buildFollowCount(context, 'Following', following.length, user, 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Profile info
                if (_isEditing)
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(user.name),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bioController,
                          decoration: const InputDecoration(
                            labelText: 'Bio',
                            prefixIcon: Icon(Icons.info),
                          ),
                          maxLines: 2,
                          maxLength: 100,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => setState(() => _isEditing = false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _isLoading ? null : () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => _isLoading = true);

                                try {
                                  final updatedUser = user.copyWith(
                                    location: _locationController.text.trim(),
                                    bio: _bioController.text.trim(),
                                  );

                                  await firestoreService.saveUser(updatedUser);
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                    _isEditing = false;
                                  });
                                }
                              },
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (user.location != null)
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(user.location!),
                        ),
                      if (user.bio != null)
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: Text(user.bio!),
                        ),
                      if (isProfileOfCurrentUser)
                        Center(
                          child: TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            onPressed: () => setState(() => _isEditing = true),
                          ),
                        ),
                    ],
                  ),

                  // Follow button
                  if (!isProfileOfCurrentUser)
                    StreamBuilder<bool>(
                      stream: firestoreService.isFollowing(user.id, currentUser.uid),
                      builder: (context, snapshot) {
                        final isFollowing = snapshot.data ?? false;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing ? Colors.grey[200] : null,
                                foregroundColor: isFollowing ? Colors.black : null,
                              ),
                              child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                              onPressed: () {
                                if (isFollowing) {
                                  firestoreService.unfollowUser(user.id, currentUser.uid);
                                } else {
                                  firestoreService.followUser(user.id, currentUser.uid);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.chat),
                              label: const Text('Message'),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<ChatRoomModel?>(
                                    future: context.read<ChatService>().getChatRoom(participantIds: [currentUser.uid, user.id]),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else if (!snapshot.hasData || snapshot.data == null) {
                                        return Text('No chat room found.');
                                      } else {
                                        return ChatDetailScreen(
                                          chatRoom: snapshot.data!,
                                          otherUser: user,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  
                  const SizedBox(height: 24),

                // TODO: add 2 or 3 pages here: Cats, Posts(images), Posts(text)
                // Cats section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cats',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (isProfileOfCurrentUser)
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Cat'),
                        onPressed: () => _navigateToAddCat(context),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cats grid
                StreamBuilder<List<CatModel>>(
                  stream: firestoreService.getUserCats(user.id),
                  builder: (context, catsSnapshot) {
                    if (catsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final cats = catsSnapshot.data ?? [];
                    if (cats.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            const Icon(Icons.pets, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No cats added yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add your first cat to get started!',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                            onTap: () => _navigateToCatDetails(context, cat),
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
                                      Text(cat.breed.toString().split(".").last),
                                      Text(
                                        cat.breedingStatus.toString().split(".").last,
                                        style: TextStyle(color: cat.breedingStatus == BreedingStatus.available ? Colors.green : Colors.red),
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
          )
        );
      },
    );
  }
} 