import 'package:cloud_firestore/cloud_firestore.dart';

class ScorePrediction {
  final String id;
  final String uid;
  final String examType;
  final double predictedScore;
  final double confidence;
  final String summary;
  final List<String> recommendations;
  final DateTime createdAt;

  ScorePrediction({
    required this.id,
    required this.uid,
    required this.examType,
    required this.predictedScore,
    required this.confidence,
    required this.summary,
    required this.recommendations,
    required this.createdAt,
  });

  factory ScorePrediction.fromMap(Map<String, dynamic> map) {
    return ScorePrediction(
      id: map['id'] as String,
      uid: map['uid'] as String,
      examType: map['examType'] as String,
      predictedScore: (map['predictedScore'] as num).toDouble(),
      confidence: (map['confidence'] as num).toDouble(),
      summary: map['summary'] as String,
      recommendations:
          List<String>.from(map['recommendations'] as List<dynamic>),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'examType': examType,
      'predictedScore': predictedScore,
      'confidence': confidence,
      'summary': summary,
      'recommendations': recommendations,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
