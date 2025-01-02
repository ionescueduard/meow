import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  String content;
  List<String> imageUrls;
  List<String> catIds;
  List<String> likes;
  DateTime createdAt;
  DateTime updatedAt;
  int commentsCount;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    List<String>? imageUrls,
    List<String>? catIds,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? commentsCount,
  }) : imageUrls = imageUrls ?? [],
       catIds = catIds ?? [],
       likes = likes ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       commentsCount = commentsCount ?? 0;

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      content: map['content'] as String,
      imageUrls: List<String>.from(map['imageUrls'] as List),
      catIds: List<String>.from(map['catIds'] as List),
      likes: List<String>.from(map['likes'] as List),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      commentsCount: map['commentsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'imageUrls': imageUrls,
      'catIds': catIds,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'commentsCount': commentsCount,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? imageUrls,
    List<String>? catIds,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? commentsCount,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      catIds: catIds ?? this.catIds,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      commentsCount: commentsCount ?? this.commentsCount,
    );
  }

  void addLike(String userId) {
    if (!likes.contains(userId)) {
      likes.add(userId);
      updatedAt = DateTime.now();
    }
  }

  void removeLike(String userId) {
    if (likes.remove(userId)) {
      updatedAt = DateTime.now();
    }
  }
} 