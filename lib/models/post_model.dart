class PostModel {
  final String id;
  final String userId;
  final String? catId;
  final String content;
  List<String> mediaUrls;
  List<String> likes;
  Map<String, String> comments; // key: commentId, value: comment content
  DateTime createdAt;
  DateTime updatedAt;

  PostModel({
    required this.id,
    required this.userId,
    this.catId,
    required this.content,
    List<String>? mediaUrls,
    List<String>? likes,
    Map<String, String>? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : mediaUrls = mediaUrls ?? [],
        likes = likes ?? [],
        comments = comments ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'catId': catId,
      'content': content,
      'mediaUrls': mediaUrls,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      catId: map['catId'] as String?,
      content: map['content'] as String,
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      likes: List<String>.from(map['likes'] ?? []),
      comments: Map<String, String>.from(map['comments'] ?? {}),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  PostModel copyWith({
    String? content,
    List<String>? mediaUrls,
    List<String>? likes,
    Map<String, String>? comments,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      catId: catId,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
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