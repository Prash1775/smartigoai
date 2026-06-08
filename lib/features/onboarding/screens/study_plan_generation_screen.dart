import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../config/routes/app_router.dart';
import '../../../services/firestore_service.dart';
import '../../../services/gemini_service.dart';

class StudyPlanGenerationScreen extends ConsumerStatefulWidget {
  final String uid;

  const StudyPlanGenerationScreen({super.key, required this.uid});

  @override
  ConsumerState<StudyPlanGenerationScreen> createState() =>
      _StudyPlanGenerationScreenState();
}

class _StudyPlanGenerationScreenState
    extends ConsumerState<StudyPlanGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  final List<String> _loadingMessages = [
    'Analyzing your profile...',
    'Evaluating target score...',
    'Assessing weak areas...',
    'Structuring daily schedule...',
    'Adding practice tests...',
    'Finalizing AI study plan...',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _messageTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });

    // Start generation after a short delay
    Future.delayed(const Duration(milliseconds: 500), _generateStudyPlan);
  }

  @override
  void dispose() {
    _animController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateStudyPlan() async {
    try {
      // 1. Fetch user data
      final user = await FirestoreService.getUser(widget.uid);
      if (user == null) {
        throw Exception('User not found');
      }

      // 2. Build prompt
      final todayDate = DateTime.now().toIso8601String().split('T').first;
      final daysToGenerate = (user.daysUntilExam != null && user.daysUntilExam! < 14) ? user.daysUntilExam! : 14;

      final prompt = '''
You are an expert ${user.examType} tutor. Create a detailed, personalized study plan in JSON format.
Student Profile:
- Exam: ${user.examType}
- Target Score: ${user.targetScore}
- Current Level: ${user.currentLevel}
- Weak Areas: ${user.weakAreas.join(', ')}
- Daily Study Time: ${user.dailyStudyMinutes} minutes
- Days until exam: ${user.daysUntilExam ?? 'Unknown'}
- Today's Date: $todayDate

Generate a comprehensive study plan tailored to these specific inputs.
CRITICAL INSTRUCTIONS:
- You must generate a day-by-day schedule for the next $daysToGenerate days starting from $todayDate.
- The output MUST be a single, valid JSON object.
- ALL property names and string values MUST be enclosed in double quotes.
- NO trailing commas.
- Do NOT include any markdown blocks (like ```json), explanations, or text outside the JSON object.

The output MUST match this exact structure:
{
  "summary": "A 2-sentence encouraging summary of the strategy.",
  "dailySchedule": [
    {
      "date": "YYYY-MM-DD",
      "focus": "Reading Comprehension",
      "tasks": [
        {"title": "Read 2 passages", "isCompleted": false},
        {"title": "Review vocabulary", "isCompleted": false}
      ]
    }
  ],
  "recommendedResources": ["Resource 1", "Resource 2"]
}
''';

      // 3. Call Gemini
      final geminiService = GeminiService();
      final responseText = await geminiService.generateFromPrompt(
        prompt,
        temperature: 0.7,
        maxTokens: 2000,
        responseMimeType: 'application/json',
      );

      // Clean up markdown wrapping if present
      String cleanText = responseText.trim();
      if (cleanText.startsWith('```json')) {
        cleanText = cleanText.substring(7);
      } else if (cleanText.startsWith('```')) {
        cleanText = cleanText.substring(3);
      }
      if (cleanText.endsWith('```')) {
        cleanText = cleanText.substring(0, cleanText.length - 3);
      }
      cleanText = cleanText.trim();

      // 4. Parse and Save
      final studyPlanJson = jsonDecode(cleanText) as Map<String, dynamic>;
      
      await FirestoreService.updateUser(widget.uid, {
        'studyPlan': studyPlanJson,
      });

      // 5. Navigate to Dashboard
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      // Catch ALL errors (Quota exceeded, JSON parse fail, 503 errors, etc.)
      // Provide a robust fallback plan so the user is never stuck
      final user = await FirestoreService.getUser(widget.uid);
      final examType = user?.examType ?? 'Exam';
      
      final fallbackPlan = {
        "summary": "We've created a solid foundation for your $examType prep. Let's get started!",
        "dailySchedule": [
          {
            "date": DateTime.now().toIso8601String().split('T').first,
            "focus": "Core Concepts Review",
            "tasks": [
              {"title": "Review fundamental strategies", "isCompleted": false},
              {"title": "Complete 10 practice questions", "isCompleted": false}
            ]
          },
          {
            "date": DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T').first,
            "focus": "Targeted Practice",
            "tasks": [
              {"title": "Focus on weak areas", "isCompleted": false},
              {"title": "Read 2 articles/passages", "isCompleted": false}
            ]
          }
        ],
        "recommendedResources": ["Official Guide", "SmartGo AI Coach", "Daily Practice Tests"]
      };

      await FirestoreService.updateUser(widget.uid, {
        'studyPlan': fallbackPlan,
      });

      if (mounted) {
        // Silently navigate to dashboard with the fallback plan
        context.go(AppRoutes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing AI Icon
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(
                                0.2 * (1 + math.sin(_animController.value * 2 * 3.14159))),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 64,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
                
                // Animated Loading Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _loadingMessages[_currentMessageIndex],
                    key: ValueKey<int>(_currentMessageIndex),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Progress Indicator
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ),
                
                const SizedBox(height: 64),
                Text(
                  'This might take 10-15 seconds as our AI\ncustomizes your learning journey.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


