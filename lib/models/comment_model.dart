import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      text: map['text'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? text,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 