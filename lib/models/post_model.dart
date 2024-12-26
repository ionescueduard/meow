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
  Map<String, String> comments; // key: commentId, value: comment content

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    List<String>? imageUrls,
    List<String>? catIds,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, String>? comments,
  }) : imageUrls = imageUrls ?? [],
       catIds = catIds ?? [],
       likes = likes ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       comments = comments ?? {};

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
      comments: Map<String, String>.from(map['comments'] ?? {}),
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
      'comments': comments,
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
    Map<String, String>? comments,
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
      comments: comments ?? this.comments,
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

  void addComment(String commentId, String content) {
    comments[commentId] = content;
    updatedAt = DateTime.now();
  }

  void removeComment(String commentId) {
    if (comments.remove(commentId) != null) {
      updatedAt = DateTime.now();
    }
  }
} 