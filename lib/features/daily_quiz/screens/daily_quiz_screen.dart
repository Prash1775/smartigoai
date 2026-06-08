import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/exam_types.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/daily_quiz_provider.dart';

class DailyQuizScreen extends ConsumerStatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  ConsumerState<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends ConsumerState<DailyQuizScreen> {
  final topicsController = TextEditingController();

  @override
  void dispose() {
    topicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyQuizProvider);
    final theme = Theme.of(context);

    if (topicsController.text != state.topicsStudied) {
      topicsController.text = state.topicsStudied;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quiz Generator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Build a daily quiz based on today\'s study topics.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<ExamType>(
              value: state.selectedExam,
              decoration: InputDecoration(
                labelText: 'Exam Type',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              items: ExamType.values.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text(exam.displayName),
                );
              }).toList(),
              onChanged: (exam) {
                if (exam != null) {
                  ref.read(dailyQuizProvider.notifier).setExamType(exam);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: topicsController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Topics Studied Today',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onChanged: (value) {
                ref.read(dailyQuizProvider.notifier).setTopicsStudied(value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: state.difficulty,
              decoration: InputDecoration(
                labelText: 'Difficulty',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              items: const [
                DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Hard', child: Text('Hard')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(dailyQuizProvider.notifier).setDifficulty(value);
                }
              },
            ),
            const SizedBox(height: 20),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  state.error!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      final authState = ref.read(authStateProvider);
                      if (authState is! Authenticated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please sign in to generate a quiz.')),
                        );
                        return;
                      }
                      ref
                          .read(dailyQuizProvider.notifier)
                          .generateQuiz(authState.user.uid);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Generate Daily Quiz'),
            ),
            const SizedBox(height: 24),
            if (state.quiz != null) ...[
              Text(
                'Generated Quiz',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Exam: ${state.quiz!.examType}'),
                      const SizedBox(height: 8),
                      Text('Topics: ${state.quiz!.topicsStudied}'),
                      const SizedBox(height: 8),
                      Text('Difficulty: ${state.quiz!.difficulty}'),
                      const SizedBox(height: 8),
                      Text('Questions: ${state.questions.length}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...state.questions.map((question) {
                final selectedAnswer = state.selectedAnswers[question.id];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${question.questionIndex}. ${question.question}',
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        ...question.options.map((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: selectedAnswer,
                            onChanged: state.result != null
                                ? null
                                : (value) {
                                    if (value != null) {
                                      ref
                                          .read(dailyQuizProvider.notifier)
                                          .updateAnswer(question.id, value);
                                    }
                                  },
                          );
                        }).toList(),
                        if (state.result != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Correct Answer: ${question.correctAnswer}',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.explanation,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
              if (state.result == null)
                ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          final authState = ref.read(authStateProvider);
                          if (authState is! Authenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please sign in to submit your quiz.')),
                            );
                            return;
                          }
                          ref
                              .read(dailyQuizProvider.notifier)
                              .submitQuizResult(authState.user.uid);
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Submit Quiz Answers'),
                ),
              if (state.result != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Score: ${state.result!.correctAnswers} / ${state.result!.totalQuestions} (${state.result!.score}%)',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your results have been saved to Firestore.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
