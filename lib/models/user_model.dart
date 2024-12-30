class UserModel {
  final String id;
  final String email;
  final String username;
  final String name;
  final String? photoUrl;
  final String? location;
  final String? bio;
  final List<String> catIds;
  final List<String> followers;
  final List<String> following;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    this.photoUrl,
    this.location,
    this.bio,
    List<String>? catIds,
    List<String>? followers,
    List<String>? following,
  })  : catIds = catIds ?? [],
        followers = followers ?? [],
        following = following ?? [];

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String?,
      location: map['location'] as String?,
      bio: map['bio'] as String?,
      catIds: List<String>.from(map['catIds'] ?? []),
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'photoUrl': photoUrl,
      'location': location,
      'bio': bio,
      'catIds': catIds,
      'followers': followers,
      'following': following,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    String? photoUrl,
    String? location,
    String? bio,
    List<String>? catIds,
    List<String>? followers,
    List<String>? following,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      catIds: catIds ?? this.catIds,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
} 