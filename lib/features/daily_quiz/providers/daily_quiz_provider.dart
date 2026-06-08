import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/exam_types.dart';
import '../models/daily_quiz.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../repositories/daily_quiz_repository.dart';

final dailyQuizRepositoryProvider = Provider<DailyQuizRepository>((ref) {
  return DailyQuizRepository();
});

final dailyQuizProvider =
    StateNotifierProvider<DailyQuizNotifier, DailyQuizState>((ref) {
  final repository = ref.watch(dailyQuizRepositoryProvider);
  return DailyQuizNotifier(repository);
});

class DailyQuizState {
  final ExamType selectedExam;
  final String topicsStudied;
  final String difficulty;
  final bool isLoading;
  final String? error;
  final DailyQuiz? quiz;
  final List<QuizQuestion> questions;
  final Map<String, String> selectedAnswers;
  final QuizResult? result;

  const DailyQuizState({
    this.selectedExam = ExamType.ielts,
    this.topicsStudied = '',
    this.difficulty = 'Medium',
    this.isLoading = false,
    this.error,
    this.quiz,
    this.questions = const [],
    this.selectedAnswers = const {},
    this.result,
  });

  static const _undefined = Object();

  DailyQuizState copyWith({
    ExamType? selectedExam,
    String? topicsStudied,
    String? difficulty,
    bool? isLoading,
    Object? error = _undefined,
    Object? quiz = _undefined,
    List<QuizQuestion>? questions,
    Map<String, String>? selectedAnswers,
    Object? result = _undefined,
  }) {
    return DailyQuizState(
      selectedExam: selectedExam ?? this.selectedExam,
      topicsStudied: topicsStudied ?? this.topicsStudied,
      difficulty: difficulty ?? this.difficulty,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _undefined) ? this.error : error as String?,
      quiz: identical(quiz, _undefined) ? this.quiz : quiz as DailyQuiz?,
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      result:
          identical(result, _undefined) ? this.result : result as QuizResult?,
    );
  }
}

class DailyQuizNotifier extends StateNotifier<DailyQuizState> {
  final DailyQuizRepository _repository;

  DailyQuizNotifier(this._repository) : super(const DailyQuizState());

  void setExamType(ExamType examType) {
    state = state.copyWith(selectedExam: examType);
  }

  void setTopicsStudied(String topicsStudied) {
    state = state.copyWith(topicsStudied: topicsStudied);
  }

  void setDifficulty(String difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  Future<void> generateQuiz(String uid) async {
    if (state.topicsStudied.isEmpty) {
      state = state.copyWith(error: 'Please enter the topics studied today.');
      return;
    }

    state = state.copyWith(
        isLoading: true,
        error: null,
        quiz: null,
        questions: [],
        result: null,
        selectedAnswers: {});

    try {
      final result = await _repository.generateDailyQuiz(
        uid: uid,
        examType: state.selectedExam.displayName,
        topicsStudied: state.topicsStudied,
        difficulty: state.difficulty,
      );

      state = state.copyWith(
        isLoading: false,
        quiz: result.quiz,
        questions: result.questions,
        error: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void updateAnswer(String questionId, String answer) {
    final updatedAnswers = Map<String, String>.from(state.selectedAnswers);
    updatedAnswers[questionId] = answer;
    state = state.copyWith(selectedAnswers: updatedAnswers);
  }

  Future<void> submitQuizResult(String uid) async {
    if (state.quiz == null || state.questions.isEmpty) {
      state = state.copyWith(error: 'No quiz is available to submit.');
      return;
    }

    if (state.selectedAnswers.length != state.questions.length) {
      state = state.copyWith(
          error: 'Please answer all questions before submitting.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final totalQuestions = state.questions.length;
    final correctAnswers = state.questions.where((question) {
      final selected = state.selectedAnswers[question.id];
      return selected != null &&
          selected.trim() == question.correctAnswer.trim();
    }).length;
    final score =
        totalQuestions == 0 ? 0.0 : (correctAnswers / totalQuestions) * 100;

    final result = QuizResult(
      id: '${state.quiz!.id}_${DateTime.now().millisecondsSinceEpoch}',
      quizId: state.quiz!.id,
      uid: uid,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      score: double.parse(score.toStringAsFixed(1)),
      selectedAnswers: state.selectedAnswers,
      completedAt: DateTime.now(),
    );

    try {
      await _repository.saveQuizResult(result);
      state = state.copyWith(isLoading: false, result: result);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }
}
