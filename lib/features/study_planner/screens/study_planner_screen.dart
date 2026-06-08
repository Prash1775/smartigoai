import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_router.dart';
import '../../../core/providers/auth_provider.dart';

class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user;
    final plan = user.studyPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Study Plan'),
        centerTitle: true,
      ),
      body: plan == null
          ? _buildEmptyState(context, theme, user.uid)
          : _buildFullPlan(context, theme, plan),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, String uid) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'No Study Plan Found',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Generate an AI-powered daily schedule tailored to your target score, exam date, and weak areas.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('${AppRoutes.studyPlanGeneration}/$uid'),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Plan Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullPlan(BuildContext context, ThemeData theme, Map<String, dynamic> plan) {
    final summary = plan['summary'] as String? ?? '';
    final weeklyRoutine = plan['weeklyRoutine'] as List<dynamic>? ?? [];
    final milestones = plan['milestones'] as List<dynamic>? ?? [];
    final resources = plan['recommendedResources'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.secondary.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    summary,
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Weekly Routine
          Text('Weekly Routine', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...weeklyRoutine.map((routine) {
            final tasks = routine['tasks'] as List<dynamic>? ?? [];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ExpansionTile(
                title: Text(
                  routine['day'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(routine['focus'] ?? '', style: TextStyle(color: theme.colorScheme.secondary)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tasks.map((task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(child: Text(task.toString())),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 32),

          // Milestones
          if (milestones.isNotEmpty) ...[
            Text('Key Milestones', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...milestones.map((m) => ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(m['week'].toString(), style: TextStyle(color: theme.colorScheme.primary)),
              ),
              title: Text(m['goal'].toString(), style: const TextStyle(fontWeight: FontWeight.w500)),
            )),
            const SizedBox(height: 32),
          ],

          // Resources
          if (resources.isNotEmpty) ...[
            Text('Recommended Resources', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: resources.map((r) => Chip(
                label: Text(r.toString()),
                backgroundColor: Colors.grey.shade100,
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
