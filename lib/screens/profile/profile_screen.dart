import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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

  Future<void> _updateProfile(UserModel user) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
      );

      await context.read<FirestoreService>().saveUser(updatedUser);
      setState(() => _isEditing = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfilePhoto(UserModel user) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final storageService = context.read<StorageService>();
      final firestoreService = context.read<FirestoreService>();

      // Upload new photo
      final photoUrl = await storageService.uploadUserProfilePhoto(
        File(image.path),
        user.id,
      );

      // Delete old photo if exists
      if (user.photoUrl != null) {
        await storageService.deleteFile(user.photoUrl!);
      }

      // Update user profile
      final updatedUser = user.copyWith(photoUrl: photoUrl);
      await firestoreService.saveUser(updatedUser);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please sign in to view profile'));
    }

    return StreamBuilder<UserModel?>(
      stream: context
          .read<FirestoreService>()
          .getUserStream(currentUser.uid), // TODO: Add this method to FirestoreService
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

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Center(
                child: Stack(
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: () => _updateProfilePhoto(user),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile info
              if (_isEditing)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
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
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _isEditing = false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () => _updateProfile(user),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => setState(() => _isEditing = true),
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
                  ],
                ),

              const Divider(height: 32),

              // Cats section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Cats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Cat'),
                    onPressed: () {
                      // TODO: Navigate to add cat screen
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cats grid
              StreamBuilder<List<CatModel>>(
                stream: context
                    .read<FirestoreService>()
                    .getUserCats(user.id),
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
                          onTap: () {
                            // TODO: Navigate to cat details screen
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
                                        child: const Icon(
                                          Icons.pets,
                                          size: 64,
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
                                    Text(cat.breed),
                                    Text(
                                      cat.breedingStatus ==
                                              BreedingStatus.available
                                          ? 'Available for breeding'
                                          : 'Not available',
                                      style: TextStyle(
                                        color: cat.breedingStatus ==
                                                BreedingStatus.available
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
        );
      },
    );
  }
} 