import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_router.dart';
import '../../../core/providers/auth_provider.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  static const Map<String, List<String>> _examTopics = {
    'IELTS': [
      'Reading Comprehension',
      'Writing Task 1 – Charts & Graphs',
      'Writing Task 2 – Essay',
      'Listening – Form Completion',
      'Listening – Multiple Choice',
      'Speaking – Part 1 Familiar Topics',
      'Speaking – Part 2 Long Turn',
      'Speaking – Part 3 Discussion',
      'Vocabulary & Collocations',
      'Grammar for IELTS',
    ],
    'GRE': [
      'Reading Comprehension',
      'Text Completion',
      'Sentence Equivalence',
      'Analytical Writing – Issue',
      'Arithmetic & Number Properties',
      'Algebra & Inequalities',
      'Geometry',
      'Data Analysis & Statistics',
      'GRE Vocabulary',
      'Logical Reasoning',
    ],
    'GMAT': [
      'Critical Reasoning',
      'Reading Comprehension',
      'Problem Solving',
      'Data Sufficiency',
      'Multi-Source Reasoning',
      'Table Analysis',
      'Graphics Interpretation',
      'Two-Part Analysis',
      'Integrated Reasoning',
      'Analytical Writing',
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState is Authenticated ? authState.user : null;
    final theme = Theme.of(context);
    final examType = user?.examType.toUpperCase() ?? 'IELTS';
    final topics = _examTopics[examType] ?? _examTopics['IELTS']!;
    final weakAreas = user?.weakAreas ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('$examType Practice'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Practice Mode',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get instant feedback on every answer',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Start Modes
          Text(
            'Quick Start',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Weak Area Review card
          if (weakAreas.isNotEmpty) ...[
            _QuickModeCard(
              title: '🎯 Weak Area Review',
              subtitle: 'Focused on: ${weakAreas.join(', ')}',
              color: Colors.orange.shade600,
              icon: Icons.warning_amber_rounded,
              onTap: () {
                final topic = weakAreas.first;
                context.push(
                  AppRoutes.practiceQuiz,
                  extra: {'topic': topic, 'examType': examType, 'mode': 'weak'},
                );
              },
            ),
            const SizedBox(height: 12),
          ],

          _QuickModeCard(
            title: '🏆 Full Mock Test',
            subtitle: 'Mixed questions across all topics',
            color: Colors.indigo.shade600,
            icon: Icons.quiz,
            onTap: () {
              context.push(
                AppRoutes.practiceQuiz,
                extra: {'topic': 'All Topics Mixed', 'examType': examType, 'mode': 'mock'},
              );
            },
          ),
          const SizedBox(height: 24),

          // Topic-by-Topic
          Text(
            'Practice by Topic',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...topics.map((topic) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TopicTile(
              topic: topic,
              examType: examType,
              isWeakArea: weakAreas.any(
                (w) => topic.toLowerCase().contains(w.toLowerCase()),
              ),
            ),
          )),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
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
}

class _QuickModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickModeCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final String topic;
  final String examType;
  final bool isWeakArea;

  const _TopicTile({
    required this.topic,
    required this.examType,
    required this.isWeakArea,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isWeakArea
                ? Colors.orange.shade100
                : theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isWeakArea ? Icons.warning_amber_rounded : Icons.lightbulb_outline,
            color: isWeakArea ? Colors.orange.shade800 : theme.colorScheme.primary,
          ),
        ),
        title: Text(
          topic,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: isWeakArea
            ? Text(
                'Weak area – needs attention',
                style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
              )
            : const Text('10 AI-generated questions', style: TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.play_circle_filled),
        onTap: () {
          context.push(
            AppRoutes.practiceQuiz,
            extra: {'topic': topic, 'examType': examType, 'mode': 'topic'},
          );
        },
      ),
    );
  }
}
