import 'package:cloud_firestore/cloud_firestore.dart';

class ReadinessScore {
  final String id;
  final String uid;
  final double score;
  final String source;
  final DateTime createdAt;

  ReadinessScore({
    required this.id,
    required this.uid,
    required this.score,
    required this.source,
    required this.createdAt,
  });

  factory ReadinessScore.fromMap(Map<String, dynamic> map) {
    return ReadinessScore(
      id: map['id'] as String,
      uid: map['uid'] as String,
      score: (map['score'] as num).toDouble(),
      source: map['source'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'score': score,
      'source': source,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
