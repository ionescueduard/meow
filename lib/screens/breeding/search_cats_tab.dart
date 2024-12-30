import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../cat/cat_details_screen.dart';

class SearchCatsTab extends StatefulWidget {
  const SearchCatsTab({super.key});

  @override
  State<SearchCatsTab> createState() => _SearchCatsTabState();
}

class _SearchCatsTabState extends State<SearchCatsTab> {
  CatBreed? _selectedBreed;
  CatGender? _selectedGender;
  BreedingStatus? _selectedBreedingStatus;
  double _minAge = 0;
  double _maxAge = 10;
  bool _showFilters = false;

  Stream<List<CatModel>> _getFilteredCats() {
    return context.read<FirestoreService>().searchCats(
      breed: _selectedBreed,
      gender: _selectedGender,
      breedingStatus: _selectedBreedingStatus,
      minAge: _minAge,
      maxAge: _maxAge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter toggle
        ListTile(
          leading: const Icon(Icons.filter_list),
          title: const Text('Filters'),
          trailing: IconButton(
            icon: Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ),

        // Filters
        if (_showFilters)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Breed filter
                DropdownButtonFormField<CatBreed>(
                  value: _selectedBreed,
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  items: CatBreed.values
                      .map((breed) => DropdownMenuItem(
                            value: breed,
                            child: Text(breed.toString().split('.').last),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBreed = value),
                ),
                const SizedBox(height: 8),

                // Gender filter
                DropdownButtonFormField<CatGender>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.male),
                  ),
                  items: CatGender.values
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender.toString().split('.').last),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: 8),

                // Breeding status filter
                DropdownButtonFormField<BreedingStatus>(
                  value: _selectedBreedingStatus,
                  decoration: const InputDecoration(
                    labelText: 'Breeding Status',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  items: BreedingStatus.values
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.toString().split('.').last),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedBreedingStatus = value),
                ),
                const SizedBox(height: 16),

                // Age range filter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Age Range: ${_minAge.round()} - ${_maxAge.round()} years',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    RangeSlider(
                      values: RangeValues(_minAge, _maxAge),
                      min: 0,
                      max: 15,
                      divisions: 15,
                      labels: RangeLabels(
                        '${_minAge.round()} years',
                        '${_maxAge.round()} years',
                      ),
                      onChanged: (values) => setState(() {
                        _minAge = values.start;
                        _maxAge = values.end;
                      }),
                    ),
                  ],
                ),

                // Reset filters button
                TextButton.icon(
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Reset Filters'),
                  onPressed: () => setState(() {
                    _selectedBreed = null;
                    _selectedGender = null;
                    _selectedBreedingStatus = null;
                    _minAge = 0;
                    _maxAge = 10;
                  }),
                ),
              ],
            ),
          ),

        // Results
        Expanded(
          child: StreamBuilder<List<CatModel>>(
            stream: _getFilteredCats(),
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
                  child: Text('No cats found matching your criteria'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: cats.length,
                itemBuilder: (context, index) {
                  final cat = cats[index];
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
                      child: const Center(
                        child: Icon(Icons.pets, size: 64),
                      ),
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
                  Text(cat.breed.toString().split('.').last),
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