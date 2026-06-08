import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/practice_question.dart';
import '../services/practice_service.dart';
import 'practice_results_screen.dart';

class PracticeQuizScreen extends StatefulWidget {
  final String topic;
  final String examType;
  final String mode;

  const PracticeQuizScreen({
    super.key,
    required this.topic,
    required this.examType,
    required this.mode,
  });

  @override
  State<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends State<PracticeQuizScreen>
    with SingleTickerProviderStateMixin {
  final PracticeService _service = PracticeService();

  List<PracticeQuestion> _questions = [];
  bool _isLoading = true;
  String? _error;

  int _currentIndex = 0;
  int? _selectedOption; // index of what the user tapped
  bool _hasAnswered = false;
  bool _showExplanation = false;

  // Track results: list of {question, selectedIndex, isCorrect}
  final List<Map<String, dynamic>> _results = [];

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await _service.generateQuestions(
        examType: widget.examType,
        topic: widget.topic,
        count: 10,
      );
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
        _slideController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onOptionTap(int optionIndex) {
    if (_hasAnswered) return;

    final question = _questions[_currentIndex];
    final isCorrect = optionIndex == question.correctIndex;

    setState(() {
      _selectedOption = optionIndex;
      _hasAnswered = true;
      _showExplanation = true;
    });

    _results.add({
      'question': question,
      'selectedIndex': optionIndex,
      'isCorrect': isCorrect,
    });
  }

  void _nextQuestion() {
    if (_currentIndex >= _questions.length - 1) {
      // Go to results
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PracticeResultsScreen(
            results: _results,
            examType: widget.examType,
            topic: widget.topic,
          ),
        ),
      );
      return;
    }

    _slideController.reset();
    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _hasAnswered = false;
      _showExplanation = false;
    });
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'AI is crafting your questions...',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.topic,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Could not load questions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() { _isLoading = true; _error = null; });
                    _loadQuestions();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.topic)),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final correctCount = _results.where((r) => r['isCorrect'] == true).length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Q${_currentIndex + 1} of ${_questions.length}'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '✓ $correctCount',
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),

          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic chip
                    Chip(
                      label: Text(
                        widget.topic,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: theme.colorScheme.primaryContainer,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    // Question Text
                    Text(
                      question.questionText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options
                    ...List.generate(question.options.length, (i) {
                      return _OptionCard(
                        label: ['A', 'B', 'C', 'D'][i],
                        text: question.options[i],
                        state: _hasAnswered
                            ? (i == question.correctIndex
                                ? _OptionState.correct
                                : (i == _selectedOption
                                    ? _OptionState.wrong
                                    : _OptionState.dimmed))
                            : _OptionState.normal,
                        onTap: () => _onOptionTap(i),
                      );
                    }),

                    // Explanation Panel
                    if (_showExplanation) ...[
                      const SizedBox(height: 20),
                      _ExplanationPanel(
                        isCorrect: _selectedOption == question.correctIndex,
                        explanation: question.explanation,
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Bottom CTA
          if (_hasAnswered)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _currentIndex >= _questions.length - 1
                        ? '🏁 See Results'
                        : 'Next Question →',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Option State
// ---------------------------------------------------------------------------

enum _OptionState { normal, correct, wrong, dimmed }

class _OptionCard extends StatelessWidget {
  final String label;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color labelBg;
    Color labelText;

    switch (state) {
      case _OptionState.correct:
        bg = Colors.green.shade50;
        border = Colors.green.shade600;
        labelBg = Colors.green.shade600;
        labelText = Colors.white;
        break;
      case _OptionState.wrong:
        bg = Colors.red.shade50;
        border = Colors.red.shade400;
        labelBg = Colors.red.shade400;
        labelText = Colors.white;
        break;
      case _OptionState.dimmed:
        bg = Colors.grey.shade50;
        border = Colors.grey.shade200;
        labelBg = Colors.grey.shade200;
        labelText = Colors.grey.shade500;
        break;
      case _OptionState.normal:
        bg = Colors.white;
        border = Colors.grey.shade300;
        labelBg = Colors.grey.shade100;
        labelText = Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: state == _OptionState.normal ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: labelBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: state == _OptionState.dimmed ? Colors.grey : Colors.black87,
                    fontWeight: state == _OptionState.correct
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (state == _OptionState.correct)
                const Icon(Icons.check_circle, color: Colors.green, size: 22),
              if (state == _OptionState.wrong)
                const Icon(Icons.cancel, color: Colors.red, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Explanation Panel
// ---------------------------------------------------------------------------

class _ExplanationPanel extends StatelessWidget {
  final bool isCorrect;
  final String explanation;

  const _ExplanationPanel({required this.isCorrect, required this.explanation});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
        border: Border.all(
          color: isCorrect ? Colors.green.shade300 : Colors.orange.shade300,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.emoji_events : Icons.lightbulb,
                color: isCorrect ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct! 🎉' : 'Not quite — here\'s why:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green.shade800 : Colors.orange.shade800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: explanation,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: isCorrect ? Colors.green.shade900 : Colors.orange.shade900,
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
