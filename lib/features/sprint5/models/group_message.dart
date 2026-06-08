import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  final String id;
  final String groupId;
  final String senderUid;
  final String senderName;
  final String message;
  final DateTime createdAt;

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderUid,
    required this.senderName,
    required this.message,
    required this.createdAt,
  });

  factory GroupMessage.fromMap(Map<String, dynamic> map) {
    return GroupMessage(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      senderUid: map['senderUid'] as String,
      senderName: map['senderName'] as String,
      message: map['message'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'senderUid': senderUid,
      'senderName': senderName,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
