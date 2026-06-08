import 'package:cloud_firestore/cloud_firestore.dart';

class DailyQuiz {
  final String id;
  final String uid;
  final String examType;
  final String topicsStudied;
  final String difficulty;
  final int questionCount;
  final DateTime createdAt;

  DailyQuiz({
    required this.id,
    required this.uid,
    required this.examType,
    required this.topicsStudied,
    required this.difficulty,
    required this.questionCount,
    required this.createdAt,
  });

  factory DailyQuiz.fromMap(Map<String, dynamic> map) {
    return DailyQuiz(
      id: map['id'] as String,
      uid: map['uid'] as String,
      examType: map['examType'] as String,
      topicsStudied: map['topicsStudied'] as String,
      difficulty: map['difficulty'] as String,
      questionCount: (map['questionCount'] as num).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'examType': examType,
      'topicsStudied': topicsStudied,
      'difficulty': difficulty,
      'questionCount': questionCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
