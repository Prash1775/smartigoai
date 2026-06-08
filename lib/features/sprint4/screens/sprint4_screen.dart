import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/exam_types.dart';
import '../../../core/providers/auth_provider.dart';
import '../models/leaderboard_entry.dart';
import '../providers/sprint4_provider.dart';

class Sprint4Screen extends ConsumerStatefulWidget {
  const Sprint4Screen({super.key});

  @override
  ConsumerState<Sprint4Screen> createState() => _Sprint4ScreenState();
}

class _Sprint4ScreenState extends ConsumerState<Sprint4Screen> {
  final speakingPromptController = TextEditingController();
  final speakingTranscriptController = TextEditingController();
  final essayPromptController = TextEditingController();
  final essayController = TextEditingController();

  @override
  void dispose() {
    speakingPromptController.dispose();
    speakingTranscriptController.dispose();
    essayPromptController.dispose();
    essayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sprint4Provider);
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState is Authenticated;
    final uid = isAuthenticated ? authState.user.uid : null;
    final displayName = isAuthenticated ? authState.user.name : 'Student';
    final theme = Theme.of(context);

    _syncController(speakingPromptController, state.speakingPrompt);
    _syncController(speakingTranscriptController, state.speakingTranscript);
    _syncController(essayPromptController, state.essayPrompt);
    _syncController(essayController, state.essayText);

    return Scaffold(
      appBar: AppBar(title: const Text('SmartGo AI Sprint 4')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Exam Intelligence Hub',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Evaluate speaking and writing, run full mocks, predict scores, and track achievements.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExamType>(
              initialValue: state.selectedExam,
              decoration: _decoration('Exam Type'),
              items: ExamType.values
                  .map((exam) => DropdownMenuItem(
                      value: exam, child: Text(exam.displayName)))
                  .toList(),
              onChanged: (exam) {
                if (exam != null) {
                  ref.read(sprint4Provider.notifier).setExam(exam);
                }
              },
            ),
            if (!isAuthenticated) ...[
              const SizedBox(height: 16),
              _InfoPanel(
                color: theme.colorScheme.errorContainer,
                textColor: theme.colorScheme.onErrorContainer,
                text:
                    'Sign in to save evaluations, mock results, achievements, and leaderboard points.',
              ),
            ],
            if (state.error != null) ...[
              const SizedBox(height: 16),
              _InfoPanel(
                color: theme.colorScheme.errorContainer,
                textColor: theme.colorScheme.onErrorContainer,
                text: state.error!,
              ),
            ],
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth >= 1100
                    ? (constraints.maxWidth - 32) / 3
                    : constraints.maxWidth >= 720
                        ? (constraints.maxWidth - 16) / 2
                        : constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _panel(cardWidth, 'IELTS Speaking Evaluation',
                        _speakingSection(state, uid)),
                    _panel(cardWidth, 'Essay Evaluation',
                        _essaySection(state, uid)),
                    _panel(cardWidth, 'Full Mock Test Engine',
                        _mockSection(state, uid, displayName)),
                    _panel(cardWidth, 'AI Score Prediction',
                        _predictionSection(state, uid)),
                    _panel(
                        cardWidth, 'Achievements', _achievementsSection(uid)),
                    _panel(cardWidth, 'Leaderboards', _leaderboardSection()),
                  ],
                );
              },
            ),
            if (state.isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.text = value;
    }
  }

  Widget _panel(double width, String title, Widget child) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _speakingSection(Sprint4State state, String? uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: speakingPromptController,
          decoration: _decoration('Speaking Prompt'),
          minLines: 2,
          maxLines: 3,
          onChanged: ref.read(sprint4Provider.notifier).setSpeakingPrompt,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: speakingTranscriptController,
          decoration: _decoration('Spoken Answer Transcript'),
          minLines: 5,
          maxLines: 8,
          onChanged: ref.read(sprint4Provider.notifier).setSpeakingTranscript,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: uid == null || state.isLoading
              ? null
              : () => ref.read(sprint4Provider.notifier).evaluateSpeaking(uid),
          icon: const Icon(Icons.record_voice_over),
          label: const Text('Evaluate Speaking'),
        ),
        if (state.speakingEvaluation != null) ...[
          const SizedBox(height: 12),
          _scoreLine('Overall band',
              state.speakingEvaluation!.overallBand.toStringAsFixed(1)),
          _scoreLine('Fluency',
              state.speakingEvaluation!.fluencyScore.toStringAsFixed(1)),
          _scoreLine('Vocabulary',
              state.speakingEvaluation!.vocabularyScore.toStringAsFixed(1)),
          const SizedBox(height: 8),
          Text(state.speakingEvaluation!.feedback),
        ],
      ],
    );
  }

  Widget _essaySection(Sprint4State state, String? uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: essayPromptController,
          decoration: _decoration('Essay Prompt'),
          minLines: 2,
          maxLines: 3,
          onChanged: ref.read(sprint4Provider.notifier).setEssayPrompt,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: essayController,
          decoration: _decoration('Essay'),
          minLines: 7,
          maxLines: 10,
          onChanged: ref.read(sprint4Provider.notifier).setEssayText,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: uid == null || state.isLoading
              ? null
              : () => ref.read(sprint4Provider.notifier).evaluateEssay(uid),
          icon: const Icon(Icons.rate_review),
          label: const Text('Evaluate Essay'),
        ),
        if (state.essayEvaluation != null) ...[
          const SizedBox(height: 12),
          _scoreLine('Overall score',
              state.essayEvaluation!.overallScore.toStringAsFixed(1)),
          _scoreLine(
              'Task', state.essayEvaluation!.taskScore.toStringAsFixed(1)),
          _scoreLine('Coherence',
              state.essayEvaluation!.coherenceScore.toStringAsFixed(1)),
          const SizedBox(height: 8),
          Text(state.essayEvaluation!.feedback),
        ],
      ],
    );
  }

  Widget _mockSection(Sprint4State state, String? uid, String displayName) {
    final test = state.mockTest;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: uid == null || state.isLoading
              ? null
              : () => ref.read(sprint4Provider.notifier).createMockTest(uid),
          icon: const Icon(Icons.assignment),
          label: const Text('Create Full Mock'),
        ),
        if (test != null) ...[
          const SizedBox(height: 12),
          Text('${test.title} • ${test.durationMinutes} minutes'),
          const SizedBox(height: 12),
          ...test.questions.map((question) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${question.section}: ${question.question}'),
                  const SizedBox(height: 6),
                  ...question.options.map((option) {
                    return RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      title: Text(option),
                      value: option,
                      groupValue: state.mockAnswers[question.id],
                      onChanged: state.mockResult != null
                          ? null
                          : (value) {
                              if (value != null) {
                                ref
                                    .read(sprint4Provider.notifier)
                                    .answerMockQuestion(question.id, value);
                              }
                            },
                    );
                  }),
                ],
              ),
            );
          }),
          ElevatedButton.icon(
            onPressed:
                uid == null || state.isLoading || state.mockResult != null
                    ? null
                    : () => ref.read(sprint4Provider.notifier).submitMockTest(
                          uid: uid,
                          displayName: displayName,
                        ),
            icon: const Icon(Icons.check_circle),
            label: const Text('Submit Mock'),
          ),
        ],
        if (state.mockResult != null) ...[
          const SizedBox(height: 12),
          _scoreLine('Score', '${state.mockResult!.score.toStringAsFixed(1)}%'),
          _scoreLine('Correct',
              '${state.mockResult!.correctAnswers}/${state.mockResult!.totalQuestions}'),
          ...state.mockResult!.sectionScores.entries.map(
            (entry) =>
                _scoreLine(entry.key, '${entry.value.toStringAsFixed(1)}%'),
          ),
        ],
      ],
    );
  }

  Widget _predictionSection(Sprint4State state, String? uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Uses latest mock result plus essay and speaking signals available in this session.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: uid == null || state.isLoading
              ? null
              : () => ref.read(sprint4Provider.notifier).predictScore(uid),
          icon: const Icon(Icons.insights),
          label: const Text('Predict Score'),
        ),
        if (state.prediction != null) ...[
          const SizedBox(height: 12),
          _scoreLine(
              'Predicted score', state.prediction!.predictedScore.toString()),
          _scoreLine('Confidence',
              '${state.prediction!.confidence.toStringAsFixed(0)}%'),
          const SizedBox(height: 8),
          Text(state.prediction!.summary),
          const SizedBox(height: 8),
          ...state.prediction!.recommendations.map((item) => Text('- $item')),
        ],
      ],
    );
  }

  Widget _achievementsSection(String? uid) {
    if (uid == null) {
      return const Text('Sign in to unlock achievements.');
    }
    final achievements = ref.watch(sprint4AchievementsProvider(uid));
    return achievements.when(
      data: (items) {
        if (items.isEmpty) {
          return const Text('No achievements unlocked yet.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items.map((achievement) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.emoji_events),
              title: Text(achievement.title),
              subtitle: Text(achievement.description),
              trailing: Text('+${achievement.points}'),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _leaderboardSection() {
    final leaderboard = ref.watch(sprint4LeaderboardProvider);
    return leaderboard.when(
      data: (entries) {
        if (entries.isEmpty) {
          return const Text('Leaderboard is waiting for first scores.');
        }
        return Column(
          children: entries.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            return _leaderboardRow(rank, item);
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error: $error'),
    );
  }

  Widget _leaderboardRow(int rank, LeaderboardEntry entry) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text('$rank')),
      title: Text(entry.displayName),
      subtitle: Text('${entry.examType} - ${entry.mockTestsCompleted} mocks'),
      trailing: Text('${entry.points} pts'),
    );
  }

  Widget _scoreLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String text;

  const _InfoPanel({
    required this.color,
    required this.textColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}
