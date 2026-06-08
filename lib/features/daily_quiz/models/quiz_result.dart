import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResult {
  final String id;
  final String quizId;
  final String uid;
  final int totalQuestions;
  final int correctAnswers;
  final double score;
  final Map<String, String> selectedAnswers;
  final DateTime completedAt;

  QuizResult({
    required this.id,
    required this.quizId,
    required this.uid,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.selectedAnswers,
    required this.completedAt,
  });

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'] as String,
      quizId: map['quizId'] as String,
      uid: map['uid'] as String,
      totalQuestions: (map['totalQuestions'] as num).toInt(),
      correctAnswers: (map['correctAnswers'] as num).toInt(),
      score: (map['score'] as num).toDouble(),
      selectedAnswers: Map<String, String>.from(map['selectedAnswers'] as Map),
      completedAt: (map['completedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'uid': uid,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
      'selectedAnswers': selectedAnswers,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}
