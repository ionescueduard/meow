import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/full_screen_image.dart';
import '../profile/profile_screen.dart';
import 'edit_cat_screen.dart';

class CatDetailsScreen extends StatelessWidget {
  final CatModel cat;

  const CatDetailsScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUser = context.read<AuthService>().currentUser;
    final isOwner = currentUser?.uid == cat.ownerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(cat.name),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCatScreen(cat: cat),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos Container
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              height: 300,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => cat.photoUrls.isNotEmpty
                              ? FullScreenImage(
                                  imageUrls: cat.photoUrls,
                                  initialIndex: 0,
                                )
                              : Scaffold(
                                  appBar: AppBar(),
                                  body: Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(
                                        Icons.pets,
                                        size: 120,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                          ),
                        );
                      },
                      child: cat.photoUrls.isNotEmpty
                        ? PageView.builder(
                            itemCount: cat.photoUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                cat.photoUrls[index],
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            width: double.infinity,
                            child: const Center(
                              child: Icon(
                                Icons.pets,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      cat.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Basic Info Container
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Owner info
                  Expanded(
                    child: FutureBuilder<UserModel?>(
                      future: firestoreService.getUser(cat.ownerId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final owner = snapshot.data!;
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileScreen(userId: owner.id),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: owner.photoUrl != null
                                    ? NetworkImage(owner.photoUrl!)
                                    : null,
                                child: owner.photoUrl == null
                                    ? Text(owner.name[0].toUpperCase())
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Owner',
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                    Text(
                                      owner.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (owner.location != null)
                                      Text(
                                        owner.location!,
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
                  // Action Buttons
                  if (!isOwner)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (cat.breedingStatus == BreedingStatus.available)
                          FilledButton.icon(
                            onPressed: () => _showBreedingRequestDialog(context),
                            icon: const Icon(Icons.pets),
                            label: const Text('Request Breeding'),
                          ),
                        if (cat.breedingStatus == BreedingStatus.available)
                          const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Feature coming soon!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Request to Buy'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Essentials Container
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
                    'Essentials',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Breed', cat.breed.toString().split('.').last),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _buildInfoRow('Gender', cat.gender.toString().split('.').last),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _buildInfoRow('Age', _calculateAge(cat.birthDate)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About Me Container
            if (cat.description != null && cat.description!.isNotEmpty)
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
                    Text(
                      'About Me',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(cat.description ?? ''),
                  ],
                ),
              ),
            if (cat.description != null && cat.description!.isNotEmpty)
              const SizedBox(height: 16),

            // Health Records Container (if records exist)
            if (cat.healthRecords.isNotEmpty)
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
                      'Health Records',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...cat.healthRecords.entries.map((entry) {
                      final date = cat.healthRecordDates[entry.key];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(entry.key),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (date != null)
                                Text(
                                  'Date: ${date.day}/${date.month}/${date.year}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(entry.value),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.difference(birthDate);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;

    if (years > 0) {
      return '$years year${years == 1 ? '' : 's'}';
    } else {
      return '$months month${months == 1 ? '' : 's'}';
    }
  }

  void _showBreedingRequestDialog(BuildContext context) async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser == null) return;

    final firestoreService = context.read<FirestoreService>();
    
    // Get user's cats that are available for breeding
    final userCats = await firestoreService
        .getUserCats(currentUser.uid)
        .first
        .then((cats) => cats.where((c) => c.breedingStatus == BreedingStatus.available).toList());

    if (userCats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to have a cat available for breeding to make a request'),
        ),
      );
      return;
    }

    if (!context.mounted) return;

    CatModel? selectedCat;
    String message = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Breeding Request'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CatModel>(
                value: selectedCat,
                decoration: const InputDecoration(
                  labelText: 'Select your cat',
                ),
                items: userCats.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedCat = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Message to owner',
                  hintText: 'Introduce your cat and explain why you think they would be a good match',
                ),
                maxLines: 3,
                onChanged: (value) => message = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (selectedCat == null || message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a cat and write a message'),
                  ),
                );
                return;
              }

              Navigator.pop(context, {
                'selectedCat': selectedCat,
                'message': message,
              });
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    ).then((result) async {
      if (result != null && context.mounted) {
        final selectedCat = result['selectedCat'] as CatModel;
        final message = result['message'] as String;

        await firestoreService.sendBreedingRequest(
          catId: cat.id,
          requesterId: currentUser.uid,
          requestMessage: message,
          requesterCatId: selectedCat.id,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Breeding request sent successfully'),
            ),
          );
        }
      }
    });
  }
} 