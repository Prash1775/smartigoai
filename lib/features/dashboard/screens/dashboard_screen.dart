import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);
    final authState = ref.watch(authStateProvider);
    
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final userName = user.name.split(' ').first;
    final examType = user.examType.toUpperCase();
    final targetScore = user.targetScore;
    final daysUntilExam = user.daysUntilExam;

    return Scaffold(
      appBar: AppBar(
        title: Text('SmartGo AI — $examType Prep'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go(AppRoutes.profile),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome & Exam Status Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Welcome back, $userName!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Target: $targetScore',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (daysUntilExam != null)
                      Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$daysUntilExam days until exam',
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AI Study Plan Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Study Plan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (user.studyPlan == null)
                _buildGeneratePlanCard(context)
              else
                _buildStudyPlanCard(context, user.studyPlan!),

              const SizedBox(height: 24),

              // Quick Actions Grid
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(
                    context: context,
                    title: 'Full Syllabus',
                    icon: Icons.menu_book,
                    color: Colors.blue,
                    route: AppRoutes.syllabus,
                  ),
                  _buildActionCard(
                    context: context,
                    title: 'Practice Tests',
                    icon: Icons.edit_document,
                    color: Colors.orange,
                    route: AppRoutes.practice,
                  ),
                  _buildActionCard(
                    context: context,
                    title: 'AI Coach',
                    icon: Icons.smart_toy,
                    color: Colors.purple,
                    route: AppRoutes.aiCoach,
                  ),
                  _buildActionCard(
                    context: context,
                    title: 'Analytics',
                    icon: Icons.analytics,
                    color: Colors.teal,
                    route: AppRoutes.learningAnalytics,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.book), label: 'Learn'),
          NavigationDestination(icon: Icon(Icons.edit), label: 'Practice'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'AI Coach'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onDestinationSelected: (index) {
          const routes = [
            AppRoutes.dashboard,
            AppRoutes.learn,
            AppRoutes.practice,
            AppRoutes.aiCoach,
            AppRoutes.profile,
          ];
          context.go(routes[index]);
        },
      ),
    );
  }

  Widget _buildGeneratePlanCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
      ),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome, size: 40, color: Colors.blue),
            const SizedBox(height: 12),
            const Text(
              'No Study Plan Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate an AI-powered study plan tailored to your target score and weak areas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final authState = ProviderScope.containerOf(context).read(authStateProvider);
                if (authState is Authenticated) {
                  context.go('${AppRoutes.studyPlanGeneration}/${authState.user.uid}');
                }
              },
              child: const Text('Generate Plan Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyPlanCard(BuildContext context, Map<String, dynamic> plan) {
    final summary = plan['summary'] as String? ?? 'Keep up the good work!';
    final todayIsoDate = DateTime.now().toIso8601String().split('T').first;
    final dailySchedule = plan['dailySchedule'] as List<dynamic>? ?? [];
    
    Map<String, dynamic>? todayPlan;
    for (final dayPlan in dailySchedule) {
      if (dayPlan['date'] == todayIsoDate) {
        todayPlan = dayPlan as Map<String, dynamic>;
        break;
      }
    }

    if (todayPlan == null && dailySchedule.isNotEmpty) {
      todayPlan = dailySchedule.first as Map<String, dynamic>;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      summary,
                      style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (todayPlan != null) ...[
              Row(
                children: [
                  Text(
                    'Today: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    todayPlan['focus'] ?? 'General Review',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...?((todayPlan['tasks'] as List<dynamic>?)?.map((task) {
                final String title = task is Map ? (task['title'] ?? '') : task.toString();
                final bool isCompleted = task is Map ? (task['isCompleted'] == true) : false;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 20, 
                        color: isCompleted ? Colors.green : Colors.grey
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })),
            ] else ...[
              const Text('Review your full plan to see upcoming tasks.'),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go(AppRoutes.studyPlanner),
                child: const Text('View Full Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.go(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
