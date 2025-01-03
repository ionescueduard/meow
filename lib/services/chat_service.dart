import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';
import '../models/user_model.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final StorageService _storageService;
  final NotificationService _notificationService;

  ChatService(this._storageService, this._notificationService);

  // Chat Rooms
  Stream<List<ChatRoomModel>> getUserChatRooms(String userId) {
    return _db
        .collection('chatRooms')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<ChatRoomModel> createChatRoom(List<String> participantIds) async {
    final chatRoom = ChatRoomModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      participantIds: participantIds,
      lastMessageTime: DateTime.now(),
      unreadCount: {for (var id in participantIds) id: 0},
    );

    await _db.collection('chatRooms').doc(chatRoom.id).set(chatRoom.toMap());
    return chatRoom;
  }

  Future<ChatRoomModel?> getChatRoom(String roomId) async {
    final doc = await _db.collection('chatRooms').doc(roomId).get();
    if (!doc.exists) return null;
    return ChatRoomModel.fromMap(doc.data()!, doc.id);
  }

  Future<ChatRoomModel?> findExistingChatRoom(List<String> participantIds) async {
    final querySnapshot = await _db
        .collection('chatRooms')
        .where('participantIds', isEqualTo: participantIds..sort())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return ChatRoomModel.fromMap(querySnapshot.docs.first.data(),
        querySnapshot.docs.first.id);
  }

  // Messages
  Stream<List<ChatMessageModel>> getChatMessages(String roomId) {
    return _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    required MessageType type,
    String? referencedCatId,
  }) async {
    final message = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: roomId,
      senderId: senderId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      referencedCatId: referencedCatId,
    );

    final batch = _db.batch();

    // Add message
    batch.set(
      _db
          .collection('chatRooms')
          .doc(roomId)
          .collection('messages')
          .doc(message.id),
      message.toMap(),
    );

    // Update chat room
    final chatRoom = await getChatRoom(roomId);
    if (chatRoom != null) {
      final updatedUnreadCount = Map<String, int>.from(chatRoom.unreadCount);
      for (final participantId in chatRoom.participantIds) {
        if (participantId != senderId) {
          updatedUnreadCount[participantId] =
              (updatedUnreadCount[participantId] ?? 0) + 1;

          // Get sender info and send notification
          final sender = await _db
              .collection('users')
              .doc(senderId)
              .get()
              .then((doc) => UserModel.fromMap(doc.data()!, doc.id));

          await _notificationService.sendChatNotification(
            userId: participantId,
            message: message,
            sender: sender,
          );
        }
      }

      batch.update(
        _db.collection('chatRooms').doc(roomId),
        {
          'lastMessageTime': Timestamp.fromDate(message.timestamp),
          'lastMessageText': content,
          'lastMessageSenderId': senderId,
          'unreadCount': updatedUnreadCount,
        },
      );
    }

    await batch.commit();
  }

  Future<void> markMessagesAsRead(String roomId, String userId) async {
    final batch = _db.batch();

    // Update unread count in chat room
    final chatRoom = await getChatRoom(roomId);
    if (chatRoom != null) {
      final updatedUnreadCount = Map<String, int>.from(chatRoom.unreadCount);
      updatedUnreadCount[userId] = 0;

      batch.update(
        _db.collection('chatRooms').doc(roomId),
        {'unreadCount': updatedUnreadCount},
      );
    }

    // Mark messages as read
    final messages = await _db
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<String> sendImageMessage(
      String roomId, String senderId, File imageFile) async {
    final imageUrl = await _storageService.uploadPostImage(imageFile);
    await sendMessage(
      roomId: roomId,
      senderId: senderId,
      content: imageUrl,
      type: MessageType.image,
    );
    return imageUrl;
  }

  Future<void> shareCatProfile(
      String roomId, String senderId, String catId) async {
    await sendMessage(
      roomId: roomId,
      senderId: senderId,
      content: 'Shared a cat profile',
      type: MessageType.catProfile,
      referencedCatId: catId,
    );
  }
} 