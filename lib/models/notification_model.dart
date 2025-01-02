import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  follow,
  like,
  comment,
  message,
  breeding,
}

class NotificationModel {
  final String id;
  final String senderId;
  final String? senderPhotoUrl;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? postId;

  NotificationModel({
    required this.id,
    required this.senderId,
    this.senderPhotoUrl,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.postId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      senderId: map['senderId'] as String,
      senderPhotoUrl: map['senderPhotoUrl'] as String?,
      message: map['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${map['type']}',
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool? ?? false,
      postId: map['postId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderPhotoUrl': senderPhotoUrl,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'postId': postId,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? senderId,
    String? senderPhotoUrl,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? postId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      postId: postId ?? this.postId,
    );
  }
} 