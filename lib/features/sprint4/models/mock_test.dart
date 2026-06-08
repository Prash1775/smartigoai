import 'package:cloud_firestore/cloud_firestore.dart';

class MockQuestion {
  final String id;
  final String section;
  final String question;
  final List<String> options;
  final String correctAnswer;

  MockQuestion({
    required this.id,
    required this.section,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory MockQuestion.fromMap(Map<String, dynamic> map) {
    return MockQuestion(
      id: map['id'] as String,
      section: map['section'] as String,
      question: map['question'] as String,
      options: List<String>.from(map['options'] as List<dynamic>),
      correctAnswer: map['correctAnswer'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section': section,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}

class MockTest {
  final String id;
  final String uid;
  final String examType;
  final String title;
  final int durationMinutes;
  final List<MockQuestion> questions;
  final DateTime createdAt;

  MockTest({
    required this.id,
    required this.uid,
    required this.examType,
    required this.title,
    required this.durationMinutes,
    required this.questions,
    required this.createdAt,
  });

  factory MockTest.fromMap(Map<String, dynamic> map) {
    final rawQuestions = map['questions'] as List<dynamic>;
    return MockTest(
      id: map['id'] as String,
      uid: map['uid'] as String,
      examType: map['examType'] as String,
      title: map['title'] as String,
      durationMinutes: (map['durationMinutes'] as num).toInt(),
      questions: rawQuestions
          .map((item) => MockQuestion.fromMap(item as Map<String, dynamic>))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'examType': examType,
      'title': title,
      'durationMinutes': durationMinutes,
      'questions': questions.map((question) => question.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
