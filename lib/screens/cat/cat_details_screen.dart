import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/full_screen_image.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (cat.photoUrls.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: cat.photoUrls.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImage(
                              imageUrls: cat.photoUrls,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        cat.photoUrls[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (cat.breedingStatus == BreedingStatus.available)
                        const Chip(
                          label: Text('Available for Breeding'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<UserModel?>(
                    future: firestoreService.getUser(cat.ownerId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final owner = snapshot.data!;
                      return Text(
                        'Owner: ${owner.name}',
                        style: Theme.of(context).textTheme.titleMedium,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Breed', cat.breed.toString().split('.').last),
                  _buildInfoRow('Gender', cat.gender.toString().split('.').last),
                  _buildInfoRow('Age', _calculateAge(cat.birthDate)),
                  if (cat.description != null && cat.description!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(cat.description ?? ''),
                      ],
                    ),
                  if (cat.healthRecords.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Health Records',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ...cat.healthRecords.entries.map((entry) => ListTile(
                            title: Text(entry.key),
                            subtitle: Text(entry.value),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !isOwner && cat.breedingStatus == BreedingStatus.available
          ? FloatingActionButton.extended(
              onPressed: () {
                _showBreedingRequestDialog(context);
              },
              label: const Text('Request Breeding'),
              icon: const Icon(Icons.pets),
            )
          : null,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
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