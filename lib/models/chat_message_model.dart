import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  catProfile,
}

class ChatMessageModel {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? referencedCatId; // For cat profile sharing

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.referencedCatId,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['id'] as String,
      roomId: map['roomId'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${map['type']}',
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] as bool,
      referencedCatId: map['referencedCatId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'referencedCatId': referencedCatId,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? roomId,
    String? senderId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    String? referencedCatId,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      referencedCatId: referencedCatId ?? this.referencedCatId,
    );
  }
} 