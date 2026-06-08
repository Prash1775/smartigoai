import '../../../services/firestore_service.dart';
import '../../../services/gemini_service.dart';
import '../models/achievement.dart';
import '../models/essay_evaluation.dart';
import '../models/leaderboard_entry.dart';
import '../models/mock_result.dart';
import '../models/mock_test.dart';
import '../models/score_prediction.dart';
import '../models/speaking_evaluation.dart';

class Sprint4Repository {
  final GeminiService _geminiService;

  Sprint4Repository({GeminiService? geminiService})
      : _geminiService = geminiService ?? GeminiService();

  Future<SpeakingEvaluation> evaluateSpeaking({
    required String uid,
    required String prompt,
    required String transcript,
  }) async {
    final base = _estimateSpeakingBand(transcript);
    final aiFeedback = await _safeGenerate(
      '''Evaluate this IELTS speaking response.

Prompt: $prompt
Transcript: $transcript

Return concise feedback with strengths, issues, and 3 next actions.''',
    );

    final evaluation = SpeakingEvaluation(
      id: '${uid}_speaking_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      prompt: prompt,
      transcript: transcript,
      fluencyScore: base,
      vocabularyScore: (base + 0.3).clamp(0, 9),
      grammarScore: (base - 0.2).clamp(0, 9),
      pronunciationScore: base,
      overallBand: base,
      feedback: aiFeedback ?? _speakingFallbackFeedback(base),
      createdAt: DateTime.now(),
    );

    await FirestoreService.createSpeakingEvaluation(evaluation);
    await _unlockAchievement(
      uid: uid,
      title: 'Speaking Starter',
      description: 'Completed an IELTS speaking evaluation.',
      category: 'Speaking',
      points: 50,
    );
    return evaluation;
  }

  Future<EssayEvaluation> evaluateEssay({
    required String uid,
    required String examType,
    required String prompt,
    required String essay,
  }) async {
    final base = _estimateWritingScore(essay);
    final aiFeedback = await _safeGenerate(
      '''Evaluate this $examType essay.

Prompt: $prompt
Essay: $essay

Score task response, coherence, vocabulary, and grammar. Give practical revision advice.''',
    );

    final evaluation = EssayEvaluation(
      id: '${uid}_essay_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      examType: examType,
      prompt: prompt,
      essay: essay,
      taskScore: base,
      coherenceScore: (base - 0.1).clamp(0, 9),
      vocabularyScore: (base + 0.2).clamp(0, 9),
      grammarScore: (base - 0.2).clamp(0, 9),
      overallScore: base,
      feedback: aiFeedback ?? _essayFallbackFeedback(base),
      createdAt: DateTime.now(),
    );

    await FirestoreService.createEssayEvaluation(evaluation);
    await _unlockAchievement(
      uid: uid,
      title: 'Essay Evaluator',
      description: 'Submitted an essay for AI evaluation.',
      category: 'Writing',
      points: 60,
    );
    return evaluation;
  }

  Future<MockTest> createMockTest({
    required String uid,
    required String examType,
  }) async {
    final test = MockTest(
      id: '${uid}_mock_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      examType: examType,
      title: '$examType Full Mock Test',
      durationMinutes: 60,
      questions: _sampleQuestions(examType),
      createdAt: DateTime.now(),
    );
    await FirestoreService.createMockTest(test);
    return test;
  }

  Future<MockResult> submitMockResult({
    required String uid,
    required String displayName,
    required MockTest test,
    required Map<String, String> selectedAnswers,
  }) async {
    final correct = test.questions.where((question) {
      return selectedAnswers[question.id] == question.correctAnswer;
    }).length;
    final total = test.questions.length;
    final score = total == 0 ? 0.0 : (correct / total) * 100;
    final sectionScores = _buildSectionScores(test, selectedAnswers);

    final result = MockResult(
      id: '${test.id}_result_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      mockTestId: test.id,
      examType: test.examType,
      totalQuestions: total,
      correctAnswers: correct,
      score: double.parse(score.toStringAsFixed(1)),
      selectedAnswers: selectedAnswers,
      sectionScores: sectionScores,
      completedAt: DateTime.now(),
    );

    await FirestoreService.createMockResult(result);
    final earnedPoints = 100 + (score ~/ 10) * 10;
    await _unlockAchievement(
      uid: uid,
      title: 'Mock Test Finisher',
      description: 'Completed a full mock test.',
      category: 'Mock Test',
      points: earnedPoints,
    );
    await FirestoreService.upsertLeaderboardEntry(
      LeaderboardEntry(
        id: uid,
        uid: uid,
        displayName: displayName,
        examType: test.examType,
        points: earnedPoints,
        mockTestsCompleted: 1,
        updatedAt: DateTime.now(),
      ),
    );
    return result;
  }

  Future<ScorePrediction> predictScore({
    required String uid,
    required String examType,
    MockResult? latestMockResult,
    EssayEvaluation? essayEvaluation,
    SpeakingEvaluation? speakingEvaluation,
  }) async {
    final mockScore = latestMockResult?.score ?? 55.0;
    final essayScore = essayEvaluation?.overallScore;
    final speakingScore = speakingEvaluation?.overallBand;
    final predicted = _predictionForExam(
      examType,
      mockScore: mockScore,
      essayScore: essayScore,
      speakingScore: speakingScore,
    );
    final mentorText = await _safeGenerate(
      '''Act as SmartGo AI Mentor.

Exam: $examType
Mock score percent: $mockScore
Essay score: ${essayScore ?? 'not available'}
Speaking score: ${speakingScore ?? 'not available'}
Predicted score: $predicted

Give 5 short recommendations for the next 7 days.''',
    );

    final recommendations = _recommendationsFromText(mentorText);
    final prediction = ScorePrediction(
      id: '${uid}_prediction_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      examType: examType,
      predictedScore: predicted,
      confidence: latestMockResult == null ? 62 : 82,
      summary: mentorText ??
          'Prediction generated from your mock test, essay, and speaking activity.',
      recommendations: recommendations,
      createdAt: DateTime.now(),
    );

    await FirestoreService.createScorePrediction(prediction);
    return prediction;
  }

  Stream<List<Achievement>> watchAchievements(String uid) {
    return FirestoreService.getAchievements(uid);
  }

  Stream<List<LeaderboardEntry>> watchLeaderboard() {
    return FirestoreService.getLeaderboard();
  }

  Future<String?> _safeGenerate(String prompt) async {
    try {
      return await _geminiService.generateFromPrompt(
        prompt,
        temperature: 0.55,
        maxTokens: 600,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _unlockAchievement({
    required String uid,
    required String title,
    required String description,
    required String category,
    required int points,
  }) async {
    final achievement = Achievement(
      id: '${uid}_${title.toLowerCase().replaceAll(' ', '_')}',
      uid: uid,
      title: title,
      description: description,
      category: category,
      points: points,
      unlockedAt: DateTime.now(),
    );
    await FirestoreService.createAchievement(achievement);
  }

  double _estimateSpeakingBand(String transcript) {
    final words = transcript
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    if (words >= 180) return 7.5;
    if (words >= 120) return 7.0;
    if (words >= 80) return 6.5;
    if (words >= 45) return 6.0;
    return 5.5;
  }

  double _estimateWritingScore(String essay) {
    final words =
        essay.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (words >= 300) return 7.5;
    if (words >= 240) return 7.0;
    if (words >= 180) return 6.5;
    if (words >= 120) return 6.0;
    return 5.5;
  }

  String _speakingFallbackFeedback(double band) {
    return 'Estimated band $band. Expand answers with examples, reduce pauses, and practice linking phrases for clearer fluency.';
  }

  String _essayFallbackFeedback(double score) {
    return 'Estimated writing score $score. Strengthen paragraph structure, add specific examples, and proofread grammar before submission.';
  }

  List<MockQuestion> _sampleQuestions(String examType) {
    final prefix = examType.toLowerCase();
    return [
      MockQuestion(
        id: '${prefix}_reading_1',
        section: 'Reading',
        question: 'Which choice best states the main idea of a passage?',
        options: [
          'A narrow detail',
          'The central argument',
          'A side example',
          'A citation'
        ],
        correctAnswer: 'The central argument',
      ),
      MockQuestion(
        id: '${prefix}_reading_2',
        section: 'Reading',
        question: 'A strong inference must be based on:',
        options: [
          'Personal opinion',
          'Text evidence',
          'Outside facts',
          'Random guessing'
        ],
        correctAnswer: 'Text evidence',
      ),
      MockQuestion(
        id: '${prefix}_vocab_1',
        section: 'Vocabulary',
        question: 'Choose the closest meaning of "concise".',
        options: ['Brief and clear', 'Very old', 'Angry', 'Uncertain'],
        correctAnswer: 'Brief and clear',
      ),
      MockQuestion(
        id: '${prefix}_quant_1',
        section: 'Quant',
        question: 'If x = 4, what is 3x + 2?',
        options: ['10', '12', '14', '16'],
        correctAnswer: '14',
      ),
      MockQuestion(
        id: '${prefix}_writing_1',
        section: 'Writing',
        question: 'A strong essay conclusion should:',
        options: [
          'Introduce a new topic',
          'Restate the position clearly',
          'Ignore the prompt',
          'Only list vocabulary'
        ],
        correctAnswer: 'Restate the position clearly',
      ),
    ];
  }

  Map<String, double> _buildSectionScores(
      MockTest test, Map<String, String> selectedAnswers) {
    final sections = <String, List<MockQuestion>>{};
    for (final question in test.questions) {
      sections.putIfAbsent(question.section, () => []).add(question);
    }
    return sections.map((section, questions) {
      final correct = questions
          .where((question) =>
              selectedAnswers[question.id] == question.correctAnswer)
          .length;
      return MapEntry(
          section,
          double.parse(
              ((correct / questions.length) * 100).toStringAsFixed(1)));
    });
  }

  double _predictionForExam(
    String examType, {
    required double mockScore,
    double? essayScore,
    double? speakingScore,
  }) {
    if (examType == 'GRE') {
      return double.parse((260 + (mockScore / 100) * 80).toStringAsFixed(0));
    }
    if (examType == 'GMAT') {
      return double.parse((200 + (mockScore / 100) * 600).toStringAsFixed(0));
    }
    final writing = essayScore ?? 6.0;
    final speaking = speakingScore ?? 6.0;
    final band = ((mockScore / 100) * 9 + writing + speaking) / 3;
    return double.parse(band.toStringAsFixed(1));
  }

  List<String> _recommendationsFromText(String? text) {
    if (text == null || text.trim().isEmpty) {
      return const [
        'Review mistakes from the latest mock test.',
        'Complete one timed reading set.',
        'Revise vocabulary with active recall.',
        'Write one essay and compare it to the rubric.',
        'Do a short speaking drill aloud.',
      ];
    }
    return text
        .split(RegExp(r'\n+'))
        .map((line) => line.replaceFirst(RegExp(r'^[-*\d.\s]+'), '').trim())
        .where((line) => line.isNotEmpty)
        .take(5)
        .toList();
  }
}
