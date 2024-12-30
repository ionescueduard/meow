import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String text;
  final DateTime createdAt;
  List<String> likes;
  final String? parentId; // ID of the parent comment if this is a reply
  final int replyCount;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.text,
    required this.createdAt,
    List<String>? likes,
    this.parentId,
    this.replyCount = 0,
  }) : likes = likes ?? [];

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? text,
    DateTime? createdAt,
    List<String>? likes,
    String? parentId,
    int? replyCount,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      parentId: parentId ?? this.parentId,
      replyCount: replyCount ?? this.replyCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'text': text,
      'createdAt': createdAt.toUtc().millisecondsSinceEpoch,
      'likes': likes,
      'parentId': parentId,
      'replyCount': replyCount,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      postId: map['postId'] as String,
      userId: map['userId'] as String,
      text: map['text'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int).toLocal(),
      likes: List<String>.from(map['likes'] ?? []),
      parentId: map['parentId'] as String?,
      replyCount: map['replyCount'] as int? ?? 0,
    );
  }

  void removeLike(String userId) {
    likes!.remove(userId);
  }

  void addLike(String userId) {
    if (!likes!.contains(userId)) {
      likes!.add(userId);
    }
  }
} 