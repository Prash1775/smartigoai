import 'package:cloud_firestore/cloud_firestore.dart';

class StudyGroup {
  final String id;
  final String creatorUid;
  final String creatorName;
  final String name;
  final String description;
  final String topic;
  final String examType;
  final int memberCount;
  final List<String> memberUids;
  final String visibility;
  final int messageCount;
  final DateTime createdAt;

  StudyGroup({
    required this.id,
    required this.creatorUid,
    required this.creatorName,
    required this.name,
    required this.description,
    required this.topic,
    required this.examType,
    required this.memberCount,
    required this.memberUids,
    required this.visibility,
    required this.messageCount,
    required this.createdAt,
  });

  factory StudyGroup.fromMap(Map<String, dynamic> map) {
    return StudyGroup(
      id: map['id'] as String,
      creatorUid: map['creatorUid'] as String,
      creatorName: map['creatorName'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      topic: map['topic'] as String,
      examType: map['examType'] as String,
      memberCount: (map['memberCount'] as num).toInt(),
      memberUids: List<String>.from(map['memberUids'] as List),
      visibility: map['visibility'] as String,
      messageCount: (map['messageCount'] as num).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorUid': creatorUid,
      'creatorName': creatorName,
      'name': name,
      'description': description,
      'topic': topic,
      'examType': examType,
      'memberCount': memberCount,
      'memberUids': memberUids,
      'visibility': visibility,
      'messageCount': messageCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
