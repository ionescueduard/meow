class UserModel {
  final String id;
  final String email;
  final String name;
  String? photoUrl;
  String? location;
  String? bio;
  List<String> catIds;
  DateTime createdAt;
  DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.location,
    this.bio,
    List<String>? catIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : catIds = catIds ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'location': location,
      'bio': bio,
      'catIds': catIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String?,
      location: map['location'] as String?,
      bio: map['bio'] as String?,
      catIds: List<String>.from(map['catIds'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? location,
    String? bio,
    List<String>? catIds,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      catIds: catIds ?? this.catIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
} 