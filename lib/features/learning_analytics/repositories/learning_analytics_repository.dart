import 'dart:convert';

import '../../../services/firestore_service.dart';
import '../../../services/gemini_service.dart';
import '../models/daily_report.dart';
import '../models/flashcard.dart';
import '../models/generated_note.dart';
import '../models/learning_event.dart';
import '../models/revision_task.dart';
import '../models/readiness_score.dart';
import '../models/vocabulary_entry.dart';
import '../models/weekly_report.dart';

class LearningAnalyticsRepository {
  final GeminiService _geminiService;

  LearningAnalyticsRepository({GeminiService? geminiService}) : _geminiService = geminiService ?? GeminiService();

  Future<void> saveLearningEvent(LearningEvent event) async {
    await FirestoreService.createLearningEvent(event);
  }

  Future<void> saveDailyReport(DailyReport report) async {
    await FirestoreService.createDailyReport(report);
  }

  Future<void> saveWeeklyReport(WeeklyReport report) async {
    await FirestoreService.createWeeklyReport(report);
  }

  Future<void> saveReadinessScore(ReadinessScore score) async {
    await FirestoreService.createReadinessScore(score);
  }

  Future<void> saveVocabulary(VocabularyEntry entry) async {
    await FirestoreService.createVocabularyEntry(entry);
  }

  Future<void> saveFlashcard(Flashcard card) async {
    await FirestoreService.createFlashcard(card);
  }

  Future<void> saveGeneratedNote(GeneratedNote note) async {
    await FirestoreService.createGeneratedNote(note);
  }

  Future<void> saveRevisionTask(RevisionTask task) async {
    await FirestoreService.createRevisionTask(task);
  }

  Stream<List<LearningEvent>> watchLearningEvents(String uid) {
    return FirestoreService.getLearningEvents(uid);
  }

  Stream<List<DailyReport>> watchDailyReports(String uid) {
    return FirestoreService.getDailyReports(uid);
  }

  Stream<List<WeeklyReport>> watchWeeklyReports(String uid) {
    return FirestoreService.getWeeklyReports(uid);
  }

  Stream<List<ReadinessScore>> watchReadinessScores(String uid) {
    return FirestoreService.getReadinessScores(uid);
  }

  Stream<List<VocabularyEntry>> watchVocabulary(String uid) {
    return FirestoreService.getVocabulary(uid);
  }

  Stream<List<Flashcard>> watchFlashcards(String uid) {
    return FirestoreService.getFlashcards(uid);
  }

  Stream<List<GeneratedNote>> watchGeneratedNotes(String uid) {
    return FirestoreService.getGeneratedNotes(uid);
  }

  Stream<List<RevisionTask>> watchRevisionTasks(String uid) {
    return FirestoreService.getRevisionTasks(uid);
  }

  Future<GeneratedNote> generateNotes({
    required String uid,
    required String title,
    required String topics,
    required String examType,
  }) async {
    final prompt = '''You are SmartGo AI Notes Generator.

Create a clear study note for the following exam topics:

Exam Type: $examType
Topics: $topics

Include:
- concise summary
- key concepts
- examples
- revision tips
- action items
''';

    final content = await _geminiService.generateFromPrompt(prompt, temperature: 0.7, maxTokens: 700);
    final note = GeneratedNote(
      id: '${uid}_${DateTime.now().millisecondsSinceEpoch}',
      uid: uid,
      title: title,
      content: content,
      sourceTopics: topics,
      createdAt: DateTime.now(),
    );

    await saveGeneratedNote(note);
    return note;
  }

  Future<List<String>> detectWeakTopics({
    required String uid,
    required String summary,
  }) async {
    final prompt = '''You are SmartGo AI Weak Topic Detector.

Review the following study summary and identify up to 5 weak topic areas the student should revise:

$summary

Return a JSON array of topic names only.''';

    final response = await _geminiService.generateFromPrompt(prompt, temperature: 0.6, maxTokens: 250);
    final extracted = _extractJsonArray(response);
    return extracted;
  }

  Future<List<RevisionTask>> generateRevisionTasks({
    required String uid,
    required List<String> weakTopics,
  }) async {
    final prompt = '''You are SmartGo AI Revision Planner.

Create one revision task for each weak topic below. Include a short description and suggested completion deadline.

Topics:
${weakTopics.join(', ')}

Return a JSON array of objects with keys: topic, description, priority.''';

    final response = await _geminiService.generateFromPrompt(prompt, temperature: 0.65, maxTokens: 300);
    final raw = jsonDecode(_extractJson(response)) as List<dynamic>;
    final tasks = <RevisionTask>[];
    for (var item in raw) {
      final map = item as Map<String, dynamic>;
      final topic = map['topic'] as String? ?? 'Topic';
      final description = map['description'] as String? ?? 'Review this topic.';
      final priority = map['priority'] as String? ?? 'Medium';

      final task = RevisionTask(
        id: '${uid}_${topic.replaceAll(' ', '_').toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
        uid: uid,
        topic: topic,
        description: description,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        priority: priority,
        createdAt: DateTime.now(),
      );
      tasks.add(task);
      await saveRevisionTask(task);
    }

    return tasks;
  }

  String _extractJson(String response) {
    final cleaned = response.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start < 0 || end < 0 || end <= start) {
      throw FormatException('Unable to parse JSON from Gemini response.');
    }
    return cleaned.substring(start, end + 1);
  }

  List<String> _extractJsonArray(String response) {
    final cleaned = response.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = cleaned.indexOf('[');
    final end = cleaned.lastIndexOf(']');
    if (start < 0 || end < 0 || end <= start) {
      throw FormatException('Unable to parse JSON array from Gemini response.');
    }
    final jsonArray = cleaned.substring(start, end + 1);
    final decoded = jsonDecode(jsonArray) as List<dynamic>;
    return decoded.map((item) => item.toString()).toList();
  }
}
