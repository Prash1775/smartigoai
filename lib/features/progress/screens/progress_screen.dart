import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final user = authState is Authenticated ? authState.user : null;
    
    final readinessScore = user?.readinessScore ?? 0.0;
    final studyStreak = user?.studyStreak ?? 0;
    final displayScore = (readinessScore > 1.0 ? readinessScore / 100 : readinessScore); // handling 0-100 or 0-1 range

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Overall Readiness',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: displayScore,
                        strokeWidth: 12,
                        backgroundColor: theme.colorScheme.surface,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '\${(displayScore * 100).toInt()}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(displayScore > 0.5 ? 'You are on track to hit your target score!' : 'Keep studying to improve your readiness!'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Performance by Subject',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSubjectBar(context, 'Reading', 0.8, Colors.blue),
          _buildSubjectBar(context, 'Listening', 0.7, Colors.green),
          _buildSubjectBar(context, 'Writing', 0.5, Colors.orange),
          _buildSubjectBar(context, 'Speaking', 0.6, Colors.purple),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(context, 'Study Streak', '\${studyStreak} Days', Icons.local_fire_department, Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(context, 'Hours Studied', '42.5h', Icons.timer, Colors.blue),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSubjectBar(BuildContext context, String subject, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(subject, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 12,
                backgroundColor: color.withOpacity(0.2),
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text('\${(value * 100).toInt()}%', style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
