import 'package:cloud_firestore/cloud_firestore.dart';

class StudyPlan {
  final String id;
  final String uid;
  final String examType;
  final int targetScore;
  final DateTime examDate;
  final double readinessScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudyPlan({
    required this.id,
    required this.uid,
    required this.examType,
    required this.targetScore,
    required this.examDate,
    required this.readinessScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    return StudyPlan(
      id: map['id'] as String,
      uid: map['uid'] as String,
      examType: map['examType'] as String,
      targetScore: (map['targetScore'] as num).toInt(),
      examDate: (map['examDate'] as Timestamp).toDate(),
      readinessScore: (map['readinessScore'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'examType': examType,
      'targetScore': targetScore,
      'examDate': Timestamp.fromDate(examDate),
      'readinessScore': readinessScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
