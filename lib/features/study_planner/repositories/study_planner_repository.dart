import 'dart:convert';
import '../../../services/firestore_service.dart';
import '../../../services/gemini_service.dart';
import '../models/daily_task.dart';
import '../models/study_plan.dart';

class StudyPlannerRepository {
  final GeminiService _geminiService;

  StudyPlannerRepository({GeminiService? geminiService}) : _geminiService = geminiService ?? GeminiService();

  Future<void> saveStudyPlan(StudyPlan plan, List<DailyTask> tasks) async {
    await FirestoreService.createStudyPlan(plan);
    await FirestoreService.createDailyTasks(tasks);
  }

  Stream<List<StudyPlan>> watchStudyPlans(String uid) {
    return FirestoreService.getStudyPlans(uid);
  }

  Stream<List<DailyTask>> watchDailyTasks(String planId) {
    return FirestoreService.getDailyTasks(planId);
  }

  Future<List<DailyTask>> generateTasksWithAi(StudyPlan plan) async {
    final prompt = '''
You are an expert exam study planner for the ${plan.examType} exam.
The user is aiming for a target score of ${plan.targetScore}.
Their current readiness score is ${plan.readinessScore}%.
The exam date is ${plan.examDate.toIso8601String().split('T').first}.

Please generate a list of exactly 4 daily study tasks for today to help them prepare.
Categories can be: Reading, Writing, Quant, Vocabulary, Listening, etc.

Return ONLY a JSON array of objects, with each object containing:
- "category": string
- "description": string
- "quantity": integer

Example:
[
  { "category": "Vocabulary", "description": "Review advanced words", "quantity": 20 }
]
''';

    try {
      final response = await _geminiService.generateFromPrompt(prompt, temperature: 0.7, maxTokens: 400);
      
      // Clean up potential markdown formatting in JSON response
      String jsonText = response.trim();
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }
      
      final List<dynamic> data = jsonDecode(jsonText.trim());
      
      final List<DailyTask> tasks = [];
      final date = DateTime(plan.examDate.year, plan.examDate.month, plan.examDate.day);
      final createdAt = DateTime.now();
      
      for (int i = 0; i < data.length; i++) {
        final item = data[i] as Map<String, dynamic>;
        tasks.add(
          DailyTask(
            id: '${plan.id}_task_$i',
            planId: plan.id,
            date: date,
            category: item['category']?.toString() ?? 'Study',
            description: item['description']?.toString() ?? 'Complete task',
            quantity: (item['quantity'] as num?)?.toInt() ?? 1,
            completed: false,
            createdAt: createdAt,
          ),
        );
      }
      return tasks;
    } catch (e) {
      // Fallback if AI fails
      throw Exception('Failed to generate plan: \$e');
    }
  }
}

