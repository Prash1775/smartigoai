import 'package:cloud_firestore/cloud_firestore.dart';

class InterviewSession {
  final String id;
  final String uid;
  final String displayName;
  final String topic;
  final String question;
  final String userAnswer;
  final String aiEvaluation;
  final double confidenceScore;
  final double clarityScore;
  final double structureScore;
  final double overallScore;
  final List<String> improvements;
  final DateTime createdAt;

  InterviewSession({
    required this.id,
    required this.uid,
    required this.displayName,
    required this.topic,
    required this.question,
    required this.userAnswer,
    required this.aiEvaluation,
    required this.confidenceScore,
    required this.clarityScore,
    required this.structureScore,
    required this.overallScore,
    required this.improvements,
    required this.createdAt,
  });

  factory InterviewSession.fromMap(Map<String, dynamic> map) {
    return InterviewSession(
      id: map['id'] as String,
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      topic: map['topic'] as String,
      question: map['question'] as String,
      userAnswer: map['userAnswer'] as String,
      aiEvaluation: map['aiEvaluation'] as String,
      confidenceScore: (map['confidenceScore'] as num).toDouble(),
      clarityScore: (map['clarityScore'] as num).toDouble(),
      structureScore: (map['structureScore'] as num).toDouble(),
      overallScore: (map['overallScore'] as num).toDouble(),
      improvements: List<String>.from(map['improvements'] as List),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'displayName': displayName,
      'topic': topic,
      'question': question,
      'userAnswer': userAnswer,
      'aiEvaluation': aiEvaluation,
      'confidenceScore': confidenceScore,
      'clarityScore': clarityScore,
      'structureScore': structureScore,
      'overallScore': overallScore,
      'improvements': improvements,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
