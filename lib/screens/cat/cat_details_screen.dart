import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import 'edit_cat_screen.dart';

class CatDetailsScreen extends StatelessWidget {
  final CatModel cat;

  const CatDetailsScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final currentUser = context.read<AuthService>().currentUser;
    final isOwner = currentUser?.uid == cat.userId;

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
            if (cat.imageUrls.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: cat.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      cat.imageUrls[index],
                      fit: BoxFit.cover,
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
                      if (cat.availableForBreeding)
                        const Chip(
                          label: Text('Available for Breeding'),
                          backgroundColor: Colors.green,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<UserModel?>(
                    future: firestoreService.getUser(cat.userId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      final owner = snapshot.data!;
                      return Text(
                        'Owner: ${owner.displayName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Breed', cat.breed),
                  _buildInfoRow('Gender', cat.gender),
                  _buildInfoRow('Age', _calculateAge(cat.birthDate)),
                  if (cat.description.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(cat.description),
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
                        ...cat.healthRecords.map((record) => Card(
                              child: ListTile(
                                title: Text(record.title),
                                subtitle: Text(record.description),
                                trailing: Text(
                                  record.date.toString().split(' ')[0],
                                ),
                              ),
                            )),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !isOwner && cat.availableForBreeding
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Implement breeding request
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Breeding request feature coming soon!'),
                  ),
                );
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
} 