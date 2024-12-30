import 'package:cloud_firestore/cloud_firestore.dart';

class BreedingRequest {
  final String id;
  final String catId;
  final String requesterId;
  final String requesterCatId;
  final String message;
  final String status;
  final DateTime createdAt;

  BreedingRequest({
    required this.id,
    required this.catId,
    required this.requesterId,
    required this.requesterCatId,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory BreedingRequest.fromMap(Map<String, dynamic> map, String id) {
    return BreedingRequest(
      id: id,
      catId: map['catId'] as String,
      requesterId: map['requesterId'] as String,
      requesterCatId: map['requesterCatId'] as String,
      message: map['message'] as String,
      status: map['status'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'catId': catId,
      'requesterId': requesterId,
      'requesterCatId': requesterCatId,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BreedingRequest copyWith({
    String? id,
    String? catId,
    String? requesterId,
    String? requesterCatId,
    String? message,
    String? status,
    DateTime? createdAt,
  }) {
    return BreedingRequest(
      id: id ?? this.id,
      catId: catId ?? this.catId,
      requesterId: requesterId ?? this.requesterId,
      requesterCatId: requesterCatId ?? this.requesterCatId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 