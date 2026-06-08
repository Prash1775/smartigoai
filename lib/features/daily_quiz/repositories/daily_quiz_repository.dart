import 'dart:convert';

import '../../../services/firestore_service.dart';
import '../../../services/gemini_service.dart';
import '../../ai_coach/agents/agent_definitions.dart';
import '../models/daily_quiz.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';

class DailyQuizGenerationResult {
  final DailyQuiz quiz;
  final List<QuizQuestion> questions;

  DailyQuizGenerationResult({
    required this.quiz,
    required this.questions,
  });
}

class DailyQuizRepository {
  final GeminiService _geminiService;

  DailyQuizRepository({GeminiService? geminiService}) : _geminiService = geminiService ?? GeminiService();

  Future<DailyQuizGenerationResult> generateDailyQuiz({
    required String uid,
    required String examType,
    required String topicsStudied,
    required String difficulty,
    int questionCount = 10,
  }) async {
    final quizId = '${uid}_${DateTime.now().millisecondsSinceEpoch}';
    final prompt = _buildQuizPrompt(
      examType: examType,
      topicsStudied: topicsStudied,
      difficulty: difficulty,
      questionCount: questionCount,
    );

    final response = await _geminiService.generateReply(
      AgentType.questionGenerator,
      const [],
      QuestionGeneratorInputModel(prompt),
    );

    final parsed = _parseQuizResponse(
      response,
      quizId,
      examType: examType,
      topicsStudied: topicsStudied,
      difficulty: difficulty,
    );
    await FirestoreService.createDailyQuiz(parsed.quiz);
    await FirestoreService.createQuizQuestions(parsed.questions);
    return parsed;
  }

  Future<void> saveQuizResult(QuizResult result) async {
    await FirestoreService.createQuizResult(result);
  }

  String _buildQuizPrompt({
    required String examType,
    required String topicsStudied,
    required String difficulty,
    required int questionCount,
  }) {
    return '''Exam Type: $examType
Topics Studied Today: $topicsStudied
Difficulty: $difficulty
Question Count: $questionCount

Please generate $questionCount multiple-choice questions for the exam listed above. Return only valid JSON with a top-level object containing a "questions" array. Each entry must include:
- "question"
- "options" (an array of 4 answer choices)
- "correctAnswer"
- "explanation"

Example:
{
  "questions": [
    {
      "question": "...",
      "options": ["A", "B", "C", "D"],
      "correctAnswer": "B",
      "explanation": "..."
    }
  ]
}
''';
  }

  DailyQuizGenerationResult _parseQuizResponse(
    String response,
    String quizId, {
    required String examType,
    required String topicsStudied,
    required String difficulty,
  }) {
    final jsonString = _extractJson(response);
    final payload = jsonDecode(jsonString) as Map<String, dynamic>;
    final rawQuestions = payload['questions'] as List<dynamic>?;
    if (rawQuestions == null || rawQuestions.isEmpty) {
      throw FormatException('Quiz generator returned no questions.');
    }

    final questions = <QuizQuestion>[];
    for (var index = 0; index < rawQuestions.length; index++) {
      final item = rawQuestions[index] as Map<String, dynamic>;
      final question = item['question'] as String?;
      final options = item['options'] as List<dynamic>?;
      final correctAnswer = item['correctAnswer'] as String?;
      final explanation = item['explanation'] as String?;

      if (question == null || options == null || correctAnswer == null || explanation == null) {
        throw FormatException('Quiz question JSON is missing required fields.');
      }

      questions.add(QuizQuestion(
        id: '${quizId}_q${index + 1}',
        quizId: quizId,
        questionIndex: index + 1,
        question: question.trim(),
        options: List<String>.from(options.map((option) => option.toString())),
        correctAnswer: correctAnswer.trim(),
        explanation: explanation.trim(),
        createdAt: DateTime.now(),
      ));
    }

    final quiz = DailyQuiz(
      id: quizId,
      uid: quizId.split('_').first,
      examType: examType,
      topicsStudied: topicsStudied,
      difficulty: difficulty,
      questionCount: questions.length,
      createdAt: DateTime.now(),
    );

    return DailyQuizGenerationResult(quiz: quiz, questions: questions);
  }

  String _extractJson(String input) {
    final cleaned = input.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start < 0 || end < 0 || end <= start) {
      throw FormatException('Unable to parse JSON from quiz generator response.');
    }
    return cleaned.substring(start, end + 1);
  }
}
