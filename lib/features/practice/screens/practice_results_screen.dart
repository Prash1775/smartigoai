import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/practice_question.dart';
import 'practice_quiz_screen.dart';

class PracticeResultsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> results;
  final String examType;
  final String topic;

  const PracticeResultsScreen({
    super.key,
    required this.results,
    required this.examType,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correctCount = results.where((r) => r['isCorrect'] == true).length;
    final total = results.length;
    final percentage = total > 0 ? (correctCount / total * 100).round() : 0;

    final Color scoreColor;
    final String scoreEmoji;
    final String scoreMessage;

    if (percentage >= 80) {
      scoreColor = Colors.green.shade600;
      scoreEmoji = '🏆';
      scoreMessage = 'Excellent work! You\'ve mastered this topic!';
    } else if (percentage >= 60) {
      scoreColor = Colors.orange.shade600;
      scoreEmoji = '💪';
      scoreMessage = 'Good effort! Keep practising to improve.';
    } else {
      scoreColor = Colors.red.shade500;
      scoreEmoji = '📚';
      scoreMessage = 'This is a weak area. Review these questions carefully.';
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Your Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Score Banner
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              border: Border.all(color: scoreColor.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(scoreEmoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                Text(
                  '$correctCount / $total correct',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  scoreMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    topic,
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.list),
                  label: const Text('All Topics'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => _RetryQuizRedirect(
                          topic: topic,
                          examType: examType,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question-by-Question Breakdown
          Text(
            'Question Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...results.asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;
            final question = result['question'] as PracticeQuestion;
            final selectedIdx = result['selectedIndex'] as int;
            final isCorrect = result['isCorrect'] as bool;

            return _QuestionReviewCard(
              number: index + 1,
              question: question,
              selectedIndex: selectedIdx,
              isCorrect: isCorrect,
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// Helper widget to navigate back to the quiz with a fresh instance
class _RetryQuizRedirect extends StatefulWidget {
  final String topic;
  final String examType;

  const _RetryQuizRedirect({required this.topic, required this.examType});

  @override
  State<_RetryQuizRedirect> createState() => _RetryQuizRedirectState();
}

class _RetryQuizRedirectState extends State<_RetryQuizRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PracticeQuizScreen(
              topic: widget.topic,
              examType: widget.examType,
              mode: 'topic',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// ---------------------------------------------------------------------------
// Per-question review card (expandable)
// ---------------------------------------------------------------------------

class _QuestionReviewCard extends StatefulWidget {
  final int number;
  final PracticeQuestion question;
  final int selectedIndex;
  final bool isCorrect;

  const _QuestionReviewCard({
    required this.number,
    required this.question,
    required this.selectedIndex,
    required this.isCorrect,
  });

  @override
  State<_QuestionReviewCard> createState() => _QuestionReviewCardState();
}

class _QuestionReviewCardState extends State<_QuestionReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCorrect = widget.isCorrect;
    final q = widget.question;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: isCorrect
                    ? Icon(Icons.check, color: Colors.green.shade700, size: 20)
                    : Icon(Icons.close, color: Colors.red.shade600, size: 20),
              ),
            ),
            title: Text(
              'Q${widget.number}: ${q.questionText}',
              maxLines: _expanded ? null : 2,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),

          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // All Options
                  ...List.generate(q.options.length, (i) {
                    Color bg = Colors.grey.shade50;
                    Color border = Colors.grey.shade200;
                    Widget? trailing;

                    if (i == q.correctIndex) {
                      bg = Colors.green.shade50;
                      border = Colors.green.shade400;
                      trailing = const Icon(Icons.check_circle, color: Colors.green, size: 18);
                    } else if (i == widget.selectedIndex && !isCorrect) {
                      bg = Colors.red.shade50;
                      border = Colors.red.shade300;
                      trailing = const Icon(Icons.cancel, color: Colors.red, size: 18);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${['A', 'B', 'C', 'D'][i]}. ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          if (trailing != null) trailing,
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Explanation
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Explanation',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        MarkdownBody(
                          data: q.explanation,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              color: Colors.blue.shade900,
                              height: 1.5,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
