import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String id;
  final String quizId;
  final int questionIndex;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final DateTime createdAt;

  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.questionIndex,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.createdAt,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as String,
      quizId: map['quizId'] as String,
      questionIndex: (map['questionIndex'] as num).toInt(),
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List<dynamic>),
      correctAnswer: map['correctAnswer'] as String,
      explanation: map['explanation'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizId': quizId,
      'questionIndex': questionIndex,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
