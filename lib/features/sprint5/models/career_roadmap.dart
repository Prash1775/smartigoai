import 'package:cloud_firestore/cloud_firestore.dart';

class CareerRoadmap {
  final String id;
  final String uid;
  final String careerGoal;
  final String targetRole;
  final String examType;
  final int targetScore;
  final List<String> milestones;
  final List<String> skillsToAcquire;
  final List<String> recommendedUniversities;
  final String aiGuidance;
  final double progressPercent;
  final DateTime createdAt;
  final DateTime targetDate;

  CareerRoadmap({
    required this.id,
    required this.uid,
    required this.careerGoal,
    required this.targetRole,
    required this.examType,
    required this.targetScore,
    required this.milestones,
    required this.skillsToAcquire,
    required this.recommendedUniversities,
    required this.aiGuidance,
    required this.progressPercent,
    required this.createdAt,
    required this.targetDate,
  });

  factory CareerRoadmap.fromMap(Map<String, dynamic> map) {
    return CareerRoadmap(
      id: map['id'] as String,
      uid: map['uid'] as String,
      careerGoal: map['careerGoal'] as String,
      targetRole: map['targetRole'] as String,
      examType: map['examType'] as String,
      targetScore: (map['targetScore'] as num).toInt(),
      milestones: List<String>.from(map['milestones'] as List),
      skillsToAcquire: List<String>.from(map['skillsToAcquire'] as List),
      recommendedUniversities:
          List<String>.from(map['recommendedUniversities'] as List),
      aiGuidance: map['aiGuidance'] as String,
      progressPercent: (map['progressPercent'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'careerGoal': careerGoal,
      'targetRole': targetRole,
      'examType': examType,
      'targetScore': targetScore,
      'milestones': milestones,
      'skillsToAcquire': skillsToAcquire,
      'recommendedUniversities': recommendedUniversities,
      'aiGuidance': aiGuidance,
      'progressPercent': progressPercent,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetDate': Timestamp.fromDate(targetDate),
    };
  }
}
