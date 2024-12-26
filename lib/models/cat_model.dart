enum CatGender {
  male,
  female,
}

enum BreedingStatus {
  available,
  notAvailable,
}

enum CatBreed {
  persian,
  siamese,
  maineCoon,
  britishShorthair,
}

class CatModel {
  final String id;
  final String ownerId;
  final String name;
  final CatBreed breed;
  final DateTime birthDate;
  final CatGender gender;
  List<String> photoUrls;
  String? description;
  BreedingStatus breedingStatus;
  Map<String, String> healthRecords; // key: record type, value: details
  DateTime createdAt;
  DateTime updatedAt;

  CatModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.gender,
    List<String>? photoUrls,
    this.description,
    BreedingStatus? breedingStatus,
    Map<String, String>? healthRecords,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : photoUrls = photoUrls ?? [],
        breedingStatus = breedingStatus ?? BreedingStatus.notAvailable,
        healthRecords = healthRecords ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'breed': breed.toString().split('.').last,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender.toString().split('.').last,
      'photoUrls': photoUrls,
      'description': description,
      'breedingStatus': breedingStatus.toString().split('.').last,
      'healthRecords': healthRecords,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CatModel.fromMap(Map<String, dynamic> map) {
    return CatModel(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      name: map['name'] as String,
      breed: CatBreed.values.firstWhere(
        (e) => e.toString().split('.').last == map['breed'],
      ),
      birthDate: DateTime.parse(map['birthDate'] as String),
      gender: CatGender.values.firstWhere(
        (e) => e.toString().split('.').last == map['gender'],
      ),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      description: map['description'] as String?,
      breedingStatus: BreedingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['breedingStatus'],
      ),
      healthRecords: Map<String, String>.from(map['healthRecords'] ?? {}),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  CatModel copyWith({
    String? name,
    CatBreed? breed,
    DateTime? birthDate,
    CatGender? gender,
    List<String>? photoUrls,
    String? description,
    BreedingStatus? breedingStatus,
    Map<String, String>? healthRecords,
  }) {
    return CatModel(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      photoUrls: photoUrls ?? this.photoUrls,
      description: description ?? this.description,
      breedingStatus: breedingStatus ?? this.breedingStatus,
      healthRecords: healthRecords ?? this.healthRecords,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 