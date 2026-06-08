import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/exam_types.dart';
import '../models/daily_task.dart';
import '../models/study_plan.dart';
import '../repositories/study_planner_repository.dart';

final studyPlannerRepositoryProvider = Provider<StudyPlannerRepository>((ref) {
  return StudyPlannerRepository();
});

final studyPlannerProvider =
    StateNotifierProvider<StudyPlannerNotifier, StudyPlannerState>((ref) {
  final repository = ref.watch(studyPlannerRepositoryProvider);
  return StudyPlannerNotifier(repository);
});

class StudyPlannerState {
  final ExamType selectedExam;
  final int targetScore;
  final DateTime? examDate;
  final double readinessScore;
  final bool isLoading;
  final String? error;
  final StudyPlan? studyPlan;
  final List<DailyTask> dailyTasks;

  const StudyPlannerState({
    this.selectedExam = ExamType.ielts,
    this.targetScore = 7,
    this.examDate,
    this.readinessScore = 40,
    this.isLoading = false,
    this.error,
    this.studyPlan,
    this.dailyTasks = const [],
  });

  StudyPlannerState copyWith({
    ExamType? selectedExam,
    int? targetScore,
    DateTime? examDate,
    double? readinessScore,
    bool? isLoading,
    String? error,
    StudyPlan? studyPlan,
    List<DailyTask>? dailyTasks,
  }) {
    return StudyPlannerState(
      selectedExam: selectedExam ?? this.selectedExam,
      targetScore: targetScore ?? this.targetScore,
      examDate: examDate ?? this.examDate,
      readinessScore: readinessScore ?? this.readinessScore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      studyPlan: studyPlan ?? this.studyPlan,
      dailyTasks: dailyTasks ?? this.dailyTasks,
    );
  }
}

class StudyPlannerNotifier extends StateNotifier<StudyPlannerState> {
  final StudyPlannerRepository _repository;

  StudyPlannerNotifier(this._repository) : super(const StudyPlannerState());

  void setExamType(ExamType examType) {
    state = state.copyWith(
      selectedExam: examType,
      targetScore: examType.defaultTargetScore,
    );
  }

  void setExamDate(DateTime examDate) {
    state = state.copyWith(examDate: examDate);
  }

  void setTargetScore(int targetScore) {
    state = state.copyWith(targetScore: targetScore);
  }

  void setReadinessScore(double readinessScore) {
    state = state.copyWith(readinessScore: readinessScore);
  }

  Future<void> createStudyPlan({
    required String uid,
  }) async {
    if (state.examDate == null) {
      state = state.copyWith(error: 'Please select your exam date.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final planId = '${uid}_${DateTime.now().millisecondsSinceEpoch}';
    final plan = StudyPlan(
      id: planId,
      uid: uid,
      examType: state.selectedExam.displayName,
      targetScore: state.targetScore,
      examDate: state.examDate!,
      readinessScore: state.readinessScore,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final tasks = await _repository.generateTasksWithAi(plan);
      await _repository.saveStudyPlan(plan, tasks);
      state = state.copyWith(
        isLoading: false,
        studyPlan: plan,
        dailyTasks: tasks,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }
}
