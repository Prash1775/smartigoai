import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

final dashboardStatsProvider = FutureProvider((ref) async {
  final authState = ref.watch(authStateProvider);
  
  if (authState is Authenticated) {
    return {
      'studyStreak': authState.user.studyStreak,
      'readinessScore': authState.user.readinessScore,
      'recentScore': 0,
      'todayGoal': 'Start your daily study plan',
    };
  }
  
  return {
    'studyStreak': 0,
    'readinessScore': 0.0,
    'recentScore': 0,
    'todayGoal': 'Complete setup',
  };
});
