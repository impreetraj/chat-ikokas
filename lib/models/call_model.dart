import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String callId;
  final String callerId;
  final String callerName;
  final String callerImage;
  final String receiverId;
  final String channelId;
  final String status; // "calling" | "accepted" | "rejected" | "ended"
  final DateTime createdAt;

  CallModel({
    required this.callId,
    required this.callerId,
    required this.callerName,
    required this.callerImage,
    required this.receiverId,
    required this.channelId,
    required this.status,
    required this.createdAt,
  });

  factory CallModel.fromMap(Map<String, dynamic> map, String id) {
    return CallModel(
      callId: id,
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerImage: map['callerImage'] ?? '',
      receiverId: map['receiverId'] ?? '',
      channelId: map['channelId'] ?? '',
      status: map['status'] ?? 'calling',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerImage': callerImage,
      'receiverId': receiverId,
      'channelId': channelId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CallModel copyWith({String? status}) {
    return CallModel(
      callId: callId,
      callerId: callerId,
      callerName: callerName,
      callerImage: callerImage,
      receiverId: receiverId,
      channelId: channelId,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
