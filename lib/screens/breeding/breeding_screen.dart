import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class BreedingScreen extends StatefulWidget {
  const BreedingScreen({super.key});

  @override
  State<BreedingScreen> createState() => _BreedingScreenState();
}

class _BreedingScreenState extends State<BreedingScreen> {
  String? selectedBreed;
  CatGender? selectedGender;
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Column(
      children: [
        // Filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Breed filter
              DropdownButtonFormField<String>(
                value: selectedBreed,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  prefixIcon: Icon(Icons.pets),
                ),
                items: const [
                  DropdownMenuItem(value: 'Persian', child: Text('Persian')),
                  DropdownMenuItem(value: 'Siamese', child: Text('Siamese')),
                  DropdownMenuItem(value: 'Maine Coon', child: Text('Maine Coon')),
                  DropdownMenuItem(value: 'British Shorthair', child: Text('British Shorthair')),
                ],
                onChanged: (value) {
                  setState(() => selectedBreed = value);
                },
              ),
              const SizedBox(height: 8),

              // Gender filter
              DropdownButtonFormField<CatGender>(
                value: selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.male),
                ),
                items: CatGender.values.map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedGender = value);
                },
              ),
              const SizedBox(height: 8),

              // Location filter
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                onChanged: (value) {
                  setState(() => selectedLocation = value);
                },
              ),
            ],
          ),
        ),

        // Results
        Expanded(
          child: StreamBuilder<List<CatModel>>(
            stream: firestoreService.searchCats(availableForBreeding: true),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final cats = snapshot.data ?? [];
              if (cats.isEmpty) {
                return const Center(
                  child: Text('No cats available for breeding'),
                );
              }

              // Apply filters
              final filteredCats = cats.where((cat) {
                if (selectedBreed != null && cat.breed != selectedBreed) {
                  return false;
                }
                if (selectedGender != null && cat.gender != selectedGender) {
                  return false;
                }
                // TODO: Implement location filtering
                return true;
              }).toList();

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredCats.length,
                itemBuilder: (context, index) {
                  final cat = filteredCats[index];
                  return _CatCard(cat: cat);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatCard extends StatelessWidget {
  final CatModel cat;

  const _CatCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to cat details screen
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cat image
            Expanded(
              child: cat.photoUrls.isNotEmpty
                  ? Image.network(
                      cat.photoUrls.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets, size: 64),
                    ),
            ),

            // Cat info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(cat.breed),
                  Text(
                    '${cat.gender.toString().split('.').last}, ${_calculateAge(cat.birthDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  FutureBuilder<UserModel?>(
                    future: firestoreService.getUser(cat.ownerId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        'Owner: ${snapshot.data!.name}',
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (months < 12) {
      return '$months months';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      return remainingMonths > 0
          ? '$years years, $remainingMonths months'
          : '$years years';
    }
  }
} 