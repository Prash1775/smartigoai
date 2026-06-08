import 'package:cloud_firestore/cloud_firestore.dart';

class MockResult {
  final String id;
  final String uid;
  final String mockTestId;
  final String examType;
  final int totalQuestions;
  final int correctAnswers;
  final double score;
  final Map<String, String> selectedAnswers;
  final Map<String, double> sectionScores;
  final DateTime completedAt;

  MockResult({
    required this.id,
    required this.uid,
    required this.mockTestId,
    required this.examType,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.selectedAnswers,
    required this.sectionScores,
    required this.completedAt,
  });

  factory MockResult.fromMap(Map<String, dynamic> map) {
    return MockResult(
      id: map['id'] as String,
      uid: map['uid'] as String,
      mockTestId: map['mockTestId'] as String,
      examType: map['examType'] as String,
      totalQuestions: (map['totalQuestions'] as num).toInt(),
      correctAnswers: (map['correctAnswers'] as num).toInt(),
      score: (map['score'] as num).toDouble(),
      selectedAnswers: Map<String, String>.from(map['selectedAnswers'] as Map),
      sectionScores: Map<String, double>.from(
        (map['sectionScores'] as Map).map(
          (key, value) => MapEntry(key as String, (value as num).toDouble()),
        ),
      ),
      completedAt: (map['completedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'mockTestId': mockTestId,
      'examType': examType,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'score': score,
      'selectedAnswers': selectedAnswers,
      'sectionScores': sectionScores,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}
