import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/exam_types.dart';
import '../models/achievement.dart';
import '../models/essay_evaluation.dart';
import '../models/leaderboard_entry.dart';
import '../models/mock_result.dart';
import '../models/mock_test.dart';
import '../models/score_prediction.dart';
import '../models/speaking_evaluation.dart';
import '../repositories/sprint4_repository.dart';

final sprint4RepositoryProvider = Provider<Sprint4Repository>((ref) {
  return Sprint4Repository();
});

final sprint4Provider =
    StateNotifierProvider<Sprint4Notifier, Sprint4State>((ref) {
  return Sprint4Notifier(ref.watch(sprint4RepositoryProvider));
});

final sprint4AchievementsProvider =
    StreamProvider.family<List<Achievement>, String>((ref, uid) {
  return ref.watch(sprint4RepositoryProvider).watchAchievements(uid);
});

final sprint4LeaderboardProvider =
    StreamProvider<List<LeaderboardEntry>>((ref) {
  return ref.watch(sprint4RepositoryProvider).watchLeaderboard();
});

class Sprint4State {
  final ExamType selectedExam;
  final String speakingPrompt;
  final String speakingTranscript;
  final String essayPrompt;
  final String essayText;
  final bool isLoading;
  final String? error;
  final SpeakingEvaluation? speakingEvaluation;
  final EssayEvaluation? essayEvaluation;
  final MockTest? mockTest;
  final Map<String, String> mockAnswers;
  final MockResult? mockResult;
  final ScorePrediction? prediction;

  const Sprint4State({
    this.selectedExam = ExamType.ielts,
    this.speakingPrompt =
        'Describe a goal you achieved and explain why it mattered to you.',
    this.speakingTranscript = '',
    this.essayPrompt =
        'Some people believe online learning is better than classroom learning. Discuss both views and give your opinion.',
    this.essayText = '',
    this.isLoading = false,
    this.error,
    this.speakingEvaluation,
    this.essayEvaluation,
    this.mockTest,
    this.mockAnswers = const {},
    this.mockResult,
    this.prediction,
  });

  Sprint4State copyWith({
    ExamType? selectedExam,
    String? speakingPrompt,
    String? speakingTranscript,
    String? essayPrompt,
    String? essayText,
    bool? isLoading,
    String? error,
    SpeakingEvaluation? speakingEvaluation,
    EssayEvaluation? essayEvaluation,
    MockTest? mockTest,
    Map<String, String>? mockAnswers,
    MockResult? mockResult,
    ScorePrediction? prediction,
  }) {
    return Sprint4State(
      selectedExam: selectedExam ?? this.selectedExam,
      speakingPrompt: speakingPrompt ?? this.speakingPrompt,
      speakingTranscript: speakingTranscript ?? this.speakingTranscript,
      essayPrompt: essayPrompt ?? this.essayPrompt,
      essayText: essayText ?? this.essayText,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      speakingEvaluation: speakingEvaluation ?? this.speakingEvaluation,
      essayEvaluation: essayEvaluation ?? this.essayEvaluation,
      mockTest: mockTest ?? this.mockTest,
      mockAnswers: mockAnswers ?? this.mockAnswers,
      mockResult: mockResult ?? this.mockResult,
      prediction: prediction ?? this.prediction,
    );
  }
}

class Sprint4Notifier extends StateNotifier<Sprint4State> {
  final Sprint4Repository _repository;

  Sprint4Notifier(this._repository) : super(const Sprint4State());

  void setExam(ExamType examType) =>
      state = state.copyWith(selectedExam: examType);
  void setSpeakingPrompt(String value) =>
      state = state.copyWith(speakingPrompt: value);
  void setSpeakingTranscript(String value) =>
      state = state.copyWith(speakingTranscript: value);
  void setEssayPrompt(String value) =>
      state = state.copyWith(essayPrompt: value);
  void setEssayText(String value) => state = state.copyWith(essayText: value);

  Future<void> evaluateSpeaking(String uid) async {
    if (state.speakingTranscript.trim().isEmpty) {
      state = state.copyWith(error: 'Enter a speaking transcript first.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final evaluation = await _repository.evaluateSpeaking(
        uid: uid,
        prompt: state.speakingPrompt,
        transcript: state.speakingTranscript,
      );
      state = state.copyWith(isLoading: false, speakingEvaluation: evaluation);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> evaluateEssay(String uid) async {
    if (state.essayText.trim().isEmpty) {
      state = state.copyWith(error: 'Enter an essay first.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final evaluation = await _repository.evaluateEssay(
        uid: uid,
        examType: state.selectedExam.displayName,
        prompt: state.essayPrompt,
        essay: state.essayText,
      );
      state = state.copyWith(isLoading: false, essayEvaluation: evaluation);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> createMockTest(String uid) async {
    state = state.copyWith(
        isLoading: true, error: null, mockAnswers: {}, mockResult: null);
    try {
      final test = await _repository.createMockTest(
        uid: uid,
        examType: state.selectedExam.displayName,
      );
      state = state.copyWith(isLoading: false, mockTest: test);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  void answerMockQuestion(String questionId, String answer) {
    final answers = Map<String, String>.from(state.mockAnswers);
    answers[questionId] = answer;
    state = state.copyWith(mockAnswers: answers);
  }

  Future<void> submitMockTest({
    required String uid,
    required String displayName,
  }) async {
    final test = state.mockTest;
    if (test == null) {
      state = state.copyWith(error: 'Create a mock test first.');
      return;
    }
    if (state.mockAnswers.length != test.questions.length) {
      state = state.copyWith(
          error: 'Answer all mock test questions before submitting.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.submitMockResult(
        uid: uid,
        displayName: displayName,
        test: test,
        selectedAnswers: state.mockAnswers,
      );
      state = state.copyWith(isLoading: false, mockResult: result);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> predictScore(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prediction = await _repository.predictScore(
        uid: uid,
        examType: state.selectedExam.displayName,
        latestMockResult: state.mockResult,
        essayEvaluation: state.essayEvaluation,
        speakingEvaluation: state.speakingEvaluation,
      );
      state = state.copyWith(isLoading: false, prediction: prediction);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }
}
