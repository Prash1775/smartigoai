import 'package:cloud_firestore/cloud_firestore.dart';

class SpeakingEvaluation {
  final String id;
  final String uid;
  final String prompt;
  final String transcript;
  final double fluencyScore;
  final double vocabularyScore;
  final double grammarScore;
  final double pronunciationScore;
  final double overallBand;
  final String feedback;
  final DateTime createdAt;

  SpeakingEvaluation({
    required this.id,
    required this.uid,
    required this.prompt,
    required this.transcript,
    required this.fluencyScore,
    required this.vocabularyScore,
    required this.grammarScore,
    required this.pronunciationScore,
    required this.overallBand,
    required this.feedback,
    required this.createdAt,
  });

  factory SpeakingEvaluation.fromMap(Map<String, dynamic> map) {
    return SpeakingEvaluation(
      id: map['id'] as String,
      uid: map['uid'] as String,
      prompt: map['prompt'] as String,
      transcript: map['transcript'] as String,
      fluencyScore: (map['fluencyScore'] as num).toDouble(),
      vocabularyScore: (map['vocabularyScore'] as num).toDouble(),
      grammarScore: (map['grammarScore'] as num).toDouble(),
      pronunciationScore: (map['pronunciationScore'] as num).toDouble(),
      overallBand: (map['overallBand'] as num).toDouble(),
      feedback: map['feedback'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'prompt': prompt,
      'transcript': transcript,
      'fluencyScore': fluencyScore,
      'vocabularyScore': vocabularyScore,
      'grammarScore': grammarScore,
      'pronunciationScore': pronunciationScore,
      'overallBand': overallBand,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
