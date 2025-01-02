import 'package:cloud_firestore/cloud_firestore.dart';

class BreedingRequest {
  final String id;
  final String requesterId;
  final String receiverId;
  final String requesterCatId;
  final String catId;
  final String message;
  final String status;
  final bool seen;
  final DateTime createdAt;

  BreedingRequest({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.requesterCatId,
    required this.catId,
    required this.message,
    required this.status,
    this.seen = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'receiverId': receiverId,
      'requesterCatId': requesterCatId,
      'catId': catId,
      'message': message,
      'status': status,
      'seen': seen,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BreedingRequest.fromMap(Map<String, dynamic> map, String id) {
    return BreedingRequest(
      id: id,
      requesterId: map['requesterId'] as String,
      receiverId: map['receiverId'] as String,
      requesterCatId: map['requesterCatId'] as String,
      catId: map['catId'] as String,
      message: map['message'] as String,
      status: map['status'] as String,
      seen: map['seen'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  BreedingRequest copyWith({
    String? id,
    String? requesterId,
    String? receiverId,
    String? requesterCatId,
    String? catId,
    String? message,
    String? status,
    bool? seen,
    DateTime? createdAt,
  }) {
    return BreedingRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      receiverId: receiverId ?? this.receiverId,
      requesterCatId: requesterCatId ?? this.requesterCatId,
      catId: catId ?? this.catId,
      message: message ?? this.message,
      status: status ?? this.status,
      seen: seen ?? this.seen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 