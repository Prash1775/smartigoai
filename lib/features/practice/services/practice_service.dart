import 'dart:convert';
import '../../../services/gemini_service.dart';
import '../models/practice_question.dart';

class PracticeService {
  final GeminiService _ai;

  PracticeService({GeminiService? ai}) : _ai = ai ?? GeminiService();

  /// Generates [count] practice questions for [examType] on the given [topic].
  Future<List<PracticeQuestion>> generateQuestions({
    required String examType,
    required String topic,
    int count = 10,
  }) async {
    final prompt = '''
You are an expert $examType exam question creator.
Generate exactly $count multiple-choice questions about: "$topic" for the $examType exam.

CRITICAL RULES:
- Each question must have EXACTLY 4 answer choices (A, B, C, D).
- One option must be clearly correct.
- Provide a 2-3 sentence explanation of WHY the correct answer is right and why the others are wrong.
- Base questions on the actual $examType exam syllabus and difficulty level.
- Output ONLY a JSON array. No markdown, no extra text.

Format:
[
  {
    "question": "The question text here?",
    "options": ["Option A text", "Option B text", "Option C text", "Option D text"],
    "correctAnswer": "A",
    "explanation": "Option A is correct because... Options B, C, D are wrong because..."
  }
]
''';

    final raw = await _ai.generateFromPrompt(prompt, temperature: 0.5, maxTokens: 3000);

    // Strip markdown fences
    String cleaned = raw.trim();
    if (cleaned.startsWith('```json')) cleaned = cleaned.substring(7);
    if (cleaned.startsWith('```')) cleaned = cleaned.substring(3);
    if (cleaned.endsWith('```')) cleaned = cleaned.substring(0, cleaned.length - 3);
    cleaned = cleaned.trim();

    final List<dynamic> data = jsonDecode(cleaned);
    return data
        .map((e) => PracticeQuestion.fromJson(e as Map<String, dynamic>))
        .where((q) => q.questionText.isNotEmpty && q.options.length == 4)
        .take(count)
        .toList();
  }
}
