import 'package:cloud_firestore/cloud_firestore.dart';

class EssayEvaluation {
  final String id;
  final String uid;
  final String examType;
  final String prompt;
  final String essay;
  final double taskScore;
  final double coherenceScore;
  final double vocabularyScore;
  final double grammarScore;
  final double overallScore;
  final String feedback;
  final DateTime createdAt;

  EssayEvaluation({
    required this.id,
    required this.uid,
    required this.examType,
    required this.prompt,
    required this.essay,
    required this.taskScore,
    required this.coherenceScore,
    required this.vocabularyScore,
    required this.grammarScore,
    required this.overallScore,
    required this.feedback,
    required this.createdAt,
  });

  factory EssayEvaluation.fromMap(Map<String, dynamic> map) {
    return EssayEvaluation(
      id: map['id'] as String,
      uid: map['uid'] as String,
      examType: map['examType'] as String,
      prompt: map['prompt'] as String,
      essay: map['essay'] as String,
      taskScore: (map['taskScore'] as num).toDouble(),
      coherenceScore: (map['coherenceScore'] as num).toDouble(),
      vocabularyScore: (map['vocabularyScore'] as num).toDouble(),
      grammarScore: (map['grammarScore'] as num).toDouble(),
      overallScore: (map['overallScore'] as num).toDouble(),
      feedback: map['feedback'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'examType': examType,
      'prompt': prompt,
      'essay': essay,
      'taskScore': taskScore,
      'coherenceScore': coherenceScore,
      'vocabularyScore': vocabularyScore,
      'grammarScore': grammarScore,
      'overallScore': overallScore,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
