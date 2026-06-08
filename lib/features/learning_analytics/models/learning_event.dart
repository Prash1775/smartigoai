import 'package:cloud_firestore/cloud_firestore.dart';

class LearningEvent {
  final String id;
  final String uid;
  final String eventType;
  final String title;
  final String description;
  final String examType;
  final double? score;
  final DateTime createdAt;

  LearningEvent({
    required this.id,
    required this.uid,
    required this.eventType,
    required this.title,
    required this.description,
    required this.examType,
    this.score,
    required this.createdAt,
  });

  factory LearningEvent.fromMap(Map<String, dynamic> map) {
    return LearningEvent(
      id: map['id'] as String,
      uid: map['uid'] as String,
      eventType: map['eventType'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      examType: map['examType'] as String,
      score: map['score'] != null ? (map['score'] as num).toDouble() : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'eventType': eventType,
      'title': title,
      'description': description,
      'examType': examType,
      'score': score,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
