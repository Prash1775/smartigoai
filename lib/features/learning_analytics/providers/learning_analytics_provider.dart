import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/exam_types.dart';
import '../models/daily_report.dart';
import '../models/flashcard.dart';
import '../models/generated_note.dart';
import '../models/learning_event.dart';
import '../models/revision_task.dart';
import '../models/readiness_score.dart';
import '../models/vocabulary_entry.dart';
import '../models/weekly_report.dart';
import '../repositories/learning_analytics_repository.dart';

final learningAnalyticsRepositoryProvider =
    Provider<LearningAnalyticsRepository>((ref) {
  return LearningAnalyticsRepository();
});

final learningAnalyticsProvider =
    StateNotifierProvider<LearningAnalyticsNotifier, LearningAnalyticsState>(
        (ref) {
  final repository = ref.watch(learningAnalyticsRepositoryProvider);
  return LearningAnalyticsNotifier(repository);
});

final learningEventsProvider =
    StreamProvider.family<List<LearningEvent>, String>((ref, uid) {
  final repository = ref.watch(learningAnalyticsRepositoryProvider);
  return repository.watchLearningEvents(uid);
});

final dailyReportsProvider =
    StreamProvider.family<List<DailyReport>, String>((ref, uid) {
  final repository = ref.watch(learningAnalyticsRepositoryProvider);
  return repository.watchDailyReports(uid);
});

final weeklyReportsProvider =
    StreamProvider.family<List<WeeklyReport>, String>((ref, uid) {
  final repository = ref.watch(learningAnalyticsRepositoryProvider);
  return repository.watchWeeklyReports(uid);
});

final vocabularyProvider =
    StreamProvider.family<List<VocabularyEntry>, String>((ref, uid) {
  final repository = ref.watch(learningAnalyticsRepositoryProvider);
  return repository.watchVocabulary(uid);
});

final flashcardsProvider =
    StreamProvider.family<List<Flashcard>, String>((ref, uid) {
  final repository = ref.watch(learningAnalyticsRepositoryProvider);
  return repository.watchFlashcards(uid);
});

final generatedNotesProvider =
    StreamProvider.family<List<GeneratedNote>, String>((ref, uid) {
  final repository = ref.watch(learningAnalyticsRepositoryProvider);
  return repository.watchGeneratedNotes(uid);
});

final revisionTasksProvider =
    StreamProvider.family<List<RevisionTask>, String>((ref, uid) {
  final repository = ref.watch(learningAnalyticsRepositoryProvider);
  return repository.watchRevisionTasks(uid);
});

class LearningAnalyticsState {
  final ExamType selectedExam;
  final String eventType;
  final String eventTitle;
  final String eventDescription;
  final String noteTitle;
  final String noteTopics;
  final String weakTopicsInput;
  final String readinessSource;
  final double readinessValue;
  final String vocabularyWord;
  final String vocabularyMeaning;
  final String vocabularyExample;
  final String flashcardFront;
  final String flashcardBack;
  final String revisionTopic;
  final String revisionDescription;
  final String revisionPriority;
  final bool isLoading;
  final String? error;
  final GeneratedNote? generatedNote;
  final List<String> weakTopics;
  final List<RevisionTask> revisionTasks;

  const LearningAnalyticsState({
    this.selectedExam = ExamType.ielts,
    this.eventType = 'Practice',
    this.eventTitle = '',
    this.eventDescription = '',
    this.noteTitle = '',
    this.noteTopics = '',
    this.weakTopicsInput = '',
    this.readinessSource = 'Self Assessment',
    this.readinessValue = 50.0,
    this.vocabularyWord = '',
    this.vocabularyMeaning = '',
    this.vocabularyExample = '',
    this.flashcardFront = '',
    this.flashcardBack = '',
    this.revisionTopic = '',
    this.revisionDescription = '',
    this.revisionPriority = 'Medium',
    this.isLoading = false,
    this.error,
    this.generatedNote,
    this.weakTopics = const [],
    this.revisionTasks = const [],
  });

  LearningAnalyticsState copyWith({
    ExamType? selectedExam,
    String? eventType,
    String? eventTitle,
    String? eventDescription,
    String? noteTitle,
    String? noteTopics,
    String? weakTopicsInput,
    String? readinessSource,
    double? readinessValue,
    String? vocabularyWord,
    String? vocabularyMeaning,
    String? vocabularyExample,
    String? flashcardFront,
    String? flashcardBack,
    String? revisionTopic,
    String? revisionDescription,
    String? revisionPriority,
    bool? isLoading,
    String? error,
    GeneratedNote? generatedNote,
    List<String>? weakTopics,
    List<RevisionTask>? revisionTasks,
  }) {
    return LearningAnalyticsState(
      selectedExam: selectedExam ?? this.selectedExam,
      eventType: eventType ?? this.eventType,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDescription: eventDescription ?? this.eventDescription,
      noteTitle: noteTitle ?? this.noteTitle,
      noteTopics: noteTopics ?? this.noteTopics,
      weakTopicsInput: weakTopicsInput ?? this.weakTopicsInput,
      readinessSource: readinessSource ?? this.readinessSource,
      readinessValue: readinessValue ?? this.readinessValue,
      vocabularyWord: vocabularyWord ?? this.vocabularyWord,
      vocabularyMeaning: vocabularyMeaning ?? this.vocabularyMeaning,
      vocabularyExample: vocabularyExample ?? this.vocabularyExample,
      flashcardFront: flashcardFront ?? this.flashcardFront,
      flashcardBack: flashcardBack ?? this.flashcardBack,
      revisionTopic: revisionTopic ?? this.revisionTopic,
      revisionDescription: revisionDescription ?? this.revisionDescription,
      revisionPriority: revisionPriority ?? this.revisionPriority,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      generatedNote: generatedNote ?? this.generatedNote,
      weakTopics: weakTopics ?? this.weakTopics,
      revisionTasks: revisionTasks ?? this.revisionTasks,
    );
  }
}

class LearningAnalyticsNotifier extends StateNotifier<LearningAnalyticsState> {
  final LearningAnalyticsRepository _repository;

  LearningAnalyticsNotifier(this._repository)
      : super(const LearningAnalyticsState());

  void setExamType(ExamType examType) {
    state = state.copyWith(selectedExam: examType);
  }

  void setEventType(String eventType) {
    state = state.copyWith(eventType: eventType);
  }

  void setEventTitle(String title) {
    state = state.copyWith(eventTitle: title);
  }

  void setEventDescription(String description) {
    state = state.copyWith(eventDescription: description);
  }

  void setNoteTitle(String title) {
    state = state.copyWith(noteTitle: title);
  }

  void setNoteTopics(String topics) {
    state = state.copyWith(noteTopics: topics);
  }

  void setWeakTopicsInput(String input) {
    state = state.copyWith(weakTopicsInput: input);
  }

  void setReadinessSource(String source) {
    state = state.copyWith(readinessSource: source);
  }

  void setReadinessValue(double value) {
    state = state.copyWith(readinessValue: value);
  }

  void setVocabularyWord(String word) {
    state = state.copyWith(vocabularyWord: word);
  }

  void setVocabularyMeaning(String meaning) {
    state = state.copyWith(vocabularyMeaning: meaning);
  }

  void setVocabularyExample(String example) {
    state = state.copyWith(vocabularyExample: example);
  }

  void setFlashcardFront(String front) {
    state = state.copyWith(flashcardFront: front);
  }

  void setFlashcardBack(String back) {
    state = state.copyWith(flashcardBack: back);
  }

  void setRevisionTopic(String topic) {
    state = state.copyWith(revisionTopic: topic);
  }

  void setRevisionDescription(String description) {
    state = state.copyWith(revisionDescription: description);
  }

  void setRevisionPriority(String priority) {
    state = state.copyWith(revisionPriority: priority);
  }

  Future<void> addLearningEvent(String uid) async {
    if (state.eventTitle.isEmpty || state.eventDescription.isEmpty) {
      state = state.copyWith(error: 'Fill event title and description.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final event = LearningEvent(
      id: '${uid}_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      eventType: state.eventType,
      title: state.eventTitle,
      description: state.eventDescription,
      examType: state.selectedExam.displayName,
      score: null,
      createdAt: DateTime.now(),
    );

    try {
      await _repository.saveLearningEvent(event);
      state = state.copyWith(
        isLoading: false,
        eventTitle: '',
        eventDescription: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createReadinessScore(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    final score = ReadinessScore(
      id: '${uid}_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      score: state.readinessValue,
      source: state.readinessSource,
      createdAt: DateTime.now(),
    );

    try {
      await _repository.saveReadinessScore(score);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addVocabularyEntry(String uid) async {
    if (state.vocabularyWord.isEmpty || state.vocabularyMeaning.isEmpty) {
      state = state.copyWith(error: 'Enter word and meaning.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final entry = VocabularyEntry(
      id: '${uid}_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      word: state.vocabularyWord,
      meaning: state.vocabularyMeaning,
      example: state.vocabularyExample,
      mastered: false,
      createdAt: DateTime.now(),
    );

    try {
      await _repository.saveVocabulary(entry);
      state = state.copyWith(
        isLoading: false,
        vocabularyWord: '',
        vocabularyMeaning: '',
        vocabularyExample: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addFlashcard(String uid) async {
    if (state.flashcardFront.isEmpty || state.flashcardBack.isEmpty) {
      state = state.copyWith(error: 'Enter flashcard front and back.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final card = Flashcard(
      id: '${uid}_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      front: state.flashcardFront,
      back: state.flashcardBack,
      category: state.selectedExam.displayName,
      createdAt: DateTime.now(),
      reviewedAt: null,
      reviewCount: 0,
    );

    try {
      await _repository.saveFlashcard(card);
      state = state.copyWith(
          isLoading: false, flashcardFront: '', flashcardBack: '');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> generateNotes(String uid) async {
    if (state.noteTitle.isEmpty || state.noteTopics.isEmpty) {
      state = state.copyWith(
          error: 'Provide a title and topics for note generation.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final note = await _repository.generateNotes(
        uid: uid,
        title: state.noteTitle,
        topics: state.noteTopics,
        examType: state.selectedExam.displayName,
      );
      state = state.copyWith(isLoading: false, generatedNote: note);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> detectWeakTopics(String uid) async {
    if (state.weakTopicsInput.isEmpty) {
      state = state.copyWith(
          error: 'Enter your study summary or exam performance highlights.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final topics = await _repository.detectWeakTopics(
          uid: uid, summary: state.weakTopicsInput);
      state = state.copyWith(isLoading: false, weakTopics: topics);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createRevisionTasks(String uid) async {
    if (state.weakTopics.isEmpty) {
      state = state.copyWith(
          error: 'Detect weak topics first or provide at least one topic.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final tasks = await _repository.generateRevisionTasks(
          uid: uid, weakTopics: state.weakTopics);
      state = state.copyWith(isLoading: false, revisionTasks: tasks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createDailyReport(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    final report = DailyReport(
      id: '${uid}_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      date: DateTime.now(),
      summary: 'Automated daily report for ${state.selectedExam.displayName}.',
      eventsLogged: 0,
      readinessScore: state.readinessValue,
      vocabularyLearned: 0,
      createdAt: DateTime.now(),
    );

    try {
      await _repository.saveDailyReport(report);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createWeeklyReport(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final report = WeeklyReport(
      id: '${uid}_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      weekStart: weekStart,
      weekEnd: weekEnd,
      summary: 'Weekly progress summary for ${state.selectedExam.displayName}.',
      tasksCompleted:
          state.revisionTasks.where((task) => task.completed).length,
      flashcardsReviewed: 0,
      averageReadiness: state.readinessValue,
      createdAt: DateTime.now(),
    );

    try {
      await _repository.saveWeeklyReport(report);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
