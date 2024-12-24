import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/cat_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class BreedingScreen extends StatefulWidget {
  const BreedingScreen({super.key});

  @override
  State<BreedingScreen> createState() => _BreedingScreenState();
}

class _BreedingScreenState extends State<BreedingScreen> {
  String? _selectedBreed;
  String? _selectedGender;
  String? _selectedLocation;
  Position? _currentPosition;
  double _maxDistance = 50.0; // km

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result != LocationPermission.whileInUse && 
          result != LocationPermission.always) {
        return;
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _selectedLocation = '${place.locality}, ${place.administrativeArea}';
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: const Text('Location'),
          subtitle: Text(_selectedLocation ?? 'Not set'),
          trailing: IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maximum Distance: ${_maxDistance.round()} km',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Slider(
                value: _maxDistance,
                min: 5,
                max: 500,
                divisions: 99,
                label: '${_maxDistance.round()} km',
                onChanged: (value) {
                  setState(() {
                    _maxDistance = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Stream<List<CatModel>> _getFilteredCats() {
    return context.read<FirestoreService>().searchCats(
      breed: _selectedBreed,
      gender: _selectedGender,
      location: _currentPosition != null
          ? {
              'latitude': _currentPosition!.latitude,
              'longitude': _currentPosition!.longitude,
              'maxDistance': _maxDistance,
            }
          : null,
    );
  }

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
                value: _selectedBreed,
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
                  setState(() => _selectedBreed = value);
                },
              ),
              const SizedBox(height: 8),

              // Gender filter
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.male),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() => _selectedGender = value);
                },
              ),
              const SizedBox(height: 8),

              // Location filter
              _buildLocationFilter(),
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
                  child: Text('No cats available for breeding'),
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