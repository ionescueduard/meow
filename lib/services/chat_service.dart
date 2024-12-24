import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String? mediaUrl;
  final DateTime timestamp;
  bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.mediaUrl,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'mediaUrl': mediaUrl,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      content: map['content'] as String,
      mediaUrl: map['mediaUrl'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isRead: map['isRead'] as bool,
    );
  }
}

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  String _getChatId(String userId1, String userId2) {
    // Ensure consistent chat ID regardless of who initiates
    final List<String> sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? mediaUrl,
  }) async {
    final chatId = _getChatId(senderId, receiverId);
    final messageId = _uuid.v4();

    final message = Message(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      mediaUrl: mediaUrl,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    // Update chat metadata
    await _firestore.collection('chats').doc(chatId).set({
      'participants': [senderId, receiverId],
      'lastMessage': content,
      'lastMessageTime': DateTime.now().toIso8601String(),
      'lastSenderId': senderId,
    }, SetOptions(merge: true));
  }

  Stream<List<Message>> getMessages(String userId1, String userId2) {
    final chatId = _getChatId(userId1, userId2);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final otherUserId = (data['participants'] as List)
                  .firstWhere((id) => id != userId);
              return {
                'chatId': doc.id,
                'otherUserId': otherUserId,
                'lastMessage': data['lastMessage'],
                'lastMessageTime': data['lastMessageTime'],
                'lastSenderId': data['lastSenderId'],
              };
            }).toList());
  }

  Future<void> markMessageAsRead(String messageId, String chatId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'isRead': true});
  }

  Future<void> deleteMessage(String messageId, String chatId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> deleteChat(String chatId) async {
    // Delete all messages in the chat
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();
    
    for (final message in messages.docs) {
      await message.reference.delete();
    }

    // Delete the chat document
    await _firestore.collection('chats').doc(chatId).delete();
  }
} 