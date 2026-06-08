import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/routes/app_router.dart';
import '../../../services/firestore_service.dart';
import '../../../core/constants/exam_types.dart';

class GmatOnboardingScreen extends ConsumerStatefulWidget {
  final String uid;

  const GmatOnboardingScreen({super.key, required this.uid});

  @override
  ConsumerState<GmatOnboardingScreen> createState() =>
      _GmatOnboardingScreenState();
}

class _GmatOnboardingScreenState extends ConsumerState<GmatOnboardingScreen> {
  int _currentStep = 0;
  bool isLoading = false;

  // Step 1: Target Score
  int selectedScore = 700;

  // Step 2: Current Level
  String currentLevel = 'intermediate';

  // Step 3: Exam Date
  DateTime? examDate;

  // Step 4: Weak Areas
  final Set<String> weakAreas = {};
  final List<String> _allAreas = [
    'Verbal Reasoning',
    'Quantitative Reasoning',
    'Integrated Reasoning',
    'Analytical Writing',
    'Data Sufficiency',
    'Critical Reasoning',
  ];

  // Step 5: Daily Study Time
  int dailyMinutes = 60;

  final _totalSteps = 5;

  Future<void> _handleComplete() async {
    setState(() => isLoading = true);

    try {
      await FirestoreService.updateUser(widget.uid, {
        'examType': ExamType.gmat.displayName,
        'targetScore': selectedScore,
        'currentLevel': currentLevel,
        'examDate': examDate?.toIso8601String(),
        'weakAreas': weakAreas.toList(),
        'dailyStudyMinutes': dailyMinutes,
        'isOnboarded': true,
      });

      if (mounted) {
        context.go('${AppRoutes.studyPlanGeneration}/${widget.uid}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _handleComplete();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (_currentStep + 1) / _totalSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GMAT Setup'),
        leading: _currentStep > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back)
            : null,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Step ${_currentStep + 1} of $_totalSteps',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                Text(_stepTitle(),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SingleChildScrollView(
                key: ValueKey(_currentStep),
                padding: const EdgeInsets.all(24),
                child: _buildStep(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0057D9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: isLoading
                    ? const SizedBox(height: 22, width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : Text(_currentStep < _totalSteps - 1 ? 'Continue' : 'Start My Journey',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle() {
    switch (_currentStep) {
      case 0: return 'Target Score';
      case 1: return 'Your Level';
      case 2: return 'Exam Date';
      case 3: return 'Focus Areas';
      case 4: return 'Study Time';
      default: return '';
    }
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0: return _buildTargetScoreStep();
      case 1: return _buildCurrentLevelStep();
      case 2: return _buildExamDateStep();
      case 3: return _buildWeakAreasStep();
      case 4: return _buildDailyTimeStep();
      default: return const SizedBox();
    }
  }

  Widget _buildTargetScoreStep() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What\'s your target\nGMAT score?',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('GMAT score ranges from 200 to 800.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.primary.withOpacity(0.05),
              ]),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 2),
            ),
            child: Center(
              child: Text('$selectedScore',
                  style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Slider(
          value: selectedScore.toDouble(), min: 200, max: 800, divisions: 120,
          label: '$selectedScore',
          onChanged: (value) => setState(() => selectedScore = value.toInt()),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _quickScore('500', 500), _quickScore('600', 600),
            _quickScore('700', 700), _quickScore('800', 800),
          ],
        ),
      ],
    );
  }

  Widget _quickScore(String label, int score) {
    final isSelected = selectedScore == score;
    return OutlinedButton(
      onPressed: () => setState(() => selectedScore = score),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.08) : null,
      ),
      child: Text(label),
    );
  }

  Widget _buildCurrentLevelStep() {
    final theme = Theme.of(context);
    final levels = [
      {'value': 'beginner', 'title': 'Beginner', 'subtitle': 'First time preparing for GMAT', 'icon': Icons.school_outlined},
      {'value': 'intermediate', 'title': 'Intermediate', 'subtitle': 'Some prep done, need more practice', 'icon': Icons.trending_up},
      {'value': 'advanced', 'title': 'Advanced', 'subtitle': 'Retaking for a higher score', 'icon': Icons.star_outlined},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What\'s your current\nprep level?',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        ...levels.map((level) {
          final isSelected = currentLevel == level['value'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => currentLevel = level['value'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1)),
                child: Row(children: [
                  Container(width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary.withOpacity(0.15) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(level['icon'] as IconData,
                        color: isSelected ? theme.colorScheme.primary : Colors.grey)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(level['title'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,
                        color: isSelected ? theme.colorScheme.primary : Colors.black87)),
                    Text(level['subtitle'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ])),
                  if (isSelected) Icon(Icons.check_circle, color: theme.colorScheme.primary),
                ]),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExamDateStep() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('When is your\nGMAT exam?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('We\'ll create a day-by-day plan.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 40),
        Center(child: Column(children: [
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(context: context,
                initialDate: examDate ?? DateTime.now().add(const Duration(days: 90)),
                firstDate: DateTime.now().add(const Duration(days: 7)),
                lastDate: DateTime.now().add(const Duration(days: 730)));
              if (picked != null) setState(() => examDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2), width: 2)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_month, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 16),
                Text(examDate != null ? '${examDate!.day}/${examDate!.month}/${examDate!.year}' : 'Tap to select date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                        color: examDate != null ? theme.colorScheme.primary : Colors.grey[500])),
              ]),
            ),
          ),
          if (examDate != null) ...[
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
              child: Text('${examDate!.difference(DateTime.now()).inDays} days until your exam',
                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600))),
          ],
          const SizedBox(height: 24),
          TextButton(onPressed: () => _next(),
            child: Text('Skip for now', style: TextStyle(color: Colors.grey[500]))),
        ])),
      ],
    );
  }

  Widget _buildWeakAreasStep() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Which areas need\nthe most work?',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Select all that apply.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 32),
        Wrap(spacing: 10, runSpacing: 10, children: _allAreas.map((area) {
          final isSelected = weakAreas.contains(area);
          return GestureDetector(
            onTap: () => setState(() => isSelected ? weakAreas.remove(area) : weakAreas.add(area)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300)),
              child: Text(area, style: TextStyle(fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87)),
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildDailyTimeStep() {
    final theme = Theme.of(context);
    final options = [
      {'minutes': 30, 'label': '30 min', 'desc': 'Light study'},
      {'minutes': 60, 'label': '1 hour', 'desc': 'Regular pace'},
      {'minutes': 120, 'label': '2 hours', 'desc': 'Intensive prep'},
      {'minutes': 180, 'label': '3 hours', 'desc': 'Full commitment'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How much time can\nyou study daily?',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        ...options.map((option) {
          final isSelected = dailyMinutes == option['minutes'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => dailyMinutes = option['minutes'] as int),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                      width: isSelected ? 2 : 1)),
                child: Row(children: [
                  Container(width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primary.withOpacity(0.15) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.schedule, color: isSelected ? theme.colorScheme.primary : Colors.grey)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(option['label'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16,
                        color: isSelected ? theme.colorScheme.primary : Colors.black87)),
                    Text(option['desc'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ])),
                  if (isSelected) Icon(Icons.check_circle, color: theme.colorScheme.primary),
                ]),
              ),
            ),
          );
        }),
      ],
    );
  }
}
