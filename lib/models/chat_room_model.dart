import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participantIds;
  final DateTime lastMessageTime;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;

  ChatRoomModel({
    required this.id,
    required this.participantIds,
    required this.lastMessageTime,
    this.lastMessageText,
    this.lastMessageSenderId,
    required this.unreadCount,
  });

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoomModel(
      id: id,
      participantIds: List<String>.from(map['participantIds'] as List),
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      lastMessageText: map['lastMessageText'] as String?,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      unreadCount: Map<String, int>.from(map['unreadCount'] as Map),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageText': lastMessageText,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount': unreadCount,
    };
  }

  ChatRoomModel copyWith({
    String? id,
    List<String>? participantIds,
    DateTime? lastMessageTime,
    String? lastMessageText,
    String? lastMessageSenderId,
    Map<String, int>? unreadCount,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
} 