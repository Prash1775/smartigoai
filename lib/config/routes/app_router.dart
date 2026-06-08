import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/exam_selection/screens/exam_selection_screen.dart';
import '../../features/onboarding/screens/first_time_exam_selection_screen.dart';
import '../../features/onboarding/screens/ielts_onboarding_screen.dart';
import '../../features/onboarding/screens/gre_onboarding_screen.dart';
import '../../features/onboarding/screens/gmat_onboarding_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/ai_coach/screens/ai_coach_screen.dart';
import '../../features/daily_quiz/screens/daily_quiz_screen.dart';
import '../../features/learning_analytics/screens/learning_analytics_screen.dart';
import '../../features/sprint4/screens/sprint4_screen.dart';
import '../../features/sprint5/screens/sprint5_screen.dart';
import '../../features/study_planner/screens/study_planner_screen.dart';
import '../../features/learn/screens/learn_screen.dart';
import '../../features/practice/screens/practice_screen.dart';
import '../../features/practice/screens/practice_quiz_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/onboarding/screens/study_plan_generation_screen.dart';
import '../../features/learn/screens/syllabus_screen.dart';

// Route names for type-safe navigation
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String examSelection = '/exam-selection';
  static const String firstTimeExamSelection = '/onboarding/exam-selection';
  static const String onboardingIelts = '/onboarding/ielts';
  static const String onboardingGre = '/onboarding/gre';
  static const String onboardingGmat = '/onboarding/gmat';
  static const String dashboard = '/dashboard';
  static const String learn = '/learn';
  static const String practice = '/practice';
  static const String progress = '/progress';
  static const String aiCoach = '/ai-coach';
  static const String dailyQuiz = '/daily-quiz';
  static const String profile = '/profile';
  static const String studyPlanner = '/study-planner';
  static const String learningAnalytics = '/learning-analytics';
  static const String sprint4 = '/sprint-4';
  static const String sprint5 = '/sprint-5';
  static const String studyPlanGeneration = '/onboarding/study-plan-generation';
  static const String syllabus = '/syllabus';
  static const String practiceQuiz = '/practice/quiz';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.examSelection,
        builder: (context, state) => const ExamSelectionScreen(),
      ),
      // Onboarding routes
      GoRoute(
        path: '${AppRoutes.firstTimeExamSelection}/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return FirstTimeExamSelectionScreen(uid: uid);
        },
      ),
      GoRoute(
        path: '${AppRoutes.onboardingIelts}/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return IeltsOnboardingScreen(uid: uid);
        },
      ),
      GoRoute(
        path: '${AppRoutes.onboardingGre}/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return GreOnboardingScreen(uid: uid);
        },
      ),
      GoRoute(
        path: '${AppRoutes.onboardingGmat}/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return GmatOnboardingScreen(uid: uid);
        },
      ),
      GoRoute(
        path: '${AppRoutes.studyPlanGeneration}/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid'] ?? '';
          return StudyPlanGenerationScreen(uid: uid);
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      // Bottom navigation screens
      GoRoute(
        path: AppRoutes.learn,
        builder: (context, state) => const LearnScreen(),
      ),
      GoRoute(
        path: AppRoutes.practice,
        builder: (context, state) => const PracticeScreen(),
      ),
      GoRoute(
        path: AppRoutes.practiceQuiz,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PracticeQuizScreen(
            topic: extra['topic'] as String? ?? 'General',
            examType: extra['examType'] as String? ?? 'IELTS',
            mode: extra['mode'] as String? ?? 'topic',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiCoach,
        builder: (context, state) => const AiCoachScreen(),
      ),
      GoRoute(
        path: AppRoutes.dailyQuiz,
        builder: (context, state) => const DailyQuizScreen(),
      ),
      GoRoute(
        path: AppRoutes.studyPlanner,
        builder: (context, state) => const StudyPlannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.learningAnalytics,
        builder: (context, state) => const LearningAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.sprint4,
        builder: (context, state) => const Sprint4Screen(),
      ),
      GoRoute(
        path: AppRoutes.sprint5,
        builder: (context, state) => const Sprint5Screen(),
      ),
      GoRoute(
        path: AppRoutes.syllabus,
        builder: (context, state) => const SyllabusScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    initialLocation: AppRoutes.splash,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
