import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;
  List<String> likes;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
    List<String>? likes,
  }) : likes = likes ?? [];

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      text: map['text'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? text,
    DateTime? createdAt,
    List<String>? likes,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
    );
  }

  void addLike(String userId) {
    if (!likes.contains(userId)) {
      likes.add(userId);
    }
  }

  void removeLike(String userId) {
    likes.remove(userId);
  }
} 