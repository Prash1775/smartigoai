import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/exam_types.dart';
import '../../../core/providers/auth_provider.dart';
import '../providers/sprint5_provider.dart';

class Sprint5Screen extends ConsumerStatefulWidget {
  const Sprint5Screen({super.key});

  @override
  ConsumerState<Sprint5Screen> createState() => _Sprint5ScreenState();
}

class _Sprint5ScreenState extends ConsumerState<Sprint5Screen> {
  final interviewAnswerController = TextEditingController();
  final groupNameController = TextEditingController();
  final groupDescController = TextEditingController();
  final postTitleController = TextEditingController();
  final postContentController = TextEditingController();
  final careerGoalController = TextEditingController();
  final targetRoleController = TextEditingController();
  final universitySearchController = TextEditingController();
  final scholarshipSearchController = TextEditingController();

  @override
  void dispose() {
    interviewAnswerController.dispose();
    groupNameController.dispose();
    groupDescController.dispose();
    postTitleController.dispose();
    postContentController.dispose();
    careerGoalController.dispose();
    targetRoleController.dispose();
    universitySearchController.dispose();
    scholarshipSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sprint5Provider);
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState is Authenticated;
    final uid = isAuthenticated ? authState.user.uid : null;
    final displayName = isAuthenticated ? authState.user.name : 'Student';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SmartGo AI Sprint 5: Career & Community Hub')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'University, Career & Community Intelligence',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Find universities, scholarships, prepare interviews, join study groups, engage in forums, and build your career roadmap.',
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
                  ref.read(sprint5Provider.notifier).setExam(exam);
                }
              },
            ),
            if (!isAuthenticated) ...[
              const SizedBox(height: 16),
              _infoPanel(
                theme,
                'Sign in to access career guidance, study groups, community forums, and premium features.',
              ),
            ],
            if (state.error != null) ...[
              const SizedBox(height: 16),
              _errorPanel(theme, state.error!),
            ],
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final isTablet = constraints.maxWidth < 1100;
                int cols = isTablet ? 2 : 3;
                if (isMobile) cols = 1;
                
                final cardWidth = (constraints.maxWidth - (16 * (cols - 1))) / cols;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _panel(cardWidth, '🏫 University Finder',
                        _universitySection(state, uid)),
                    _panel(cardWidth, '💰 Scholarship Finder',
                        _scholarshipSection(state, uid)),
                    _panel(cardWidth, '🎤 Interview Coach',
                        _interviewSection(state, uid, displayName)),
                    _panel(cardWidth, '👥 Study Groups',
                        _studyGroupSection(state, uid, displayName)),
                    _panel(cardWidth, '💬 Community Forum',
                        _forumSection(state, uid, displayName)),
                    _panel(cardWidth, '🎓 Career Roadmap',
                        _careerSection(state, uid)),
                    _panel(cardWidth, '⭐ Achievements',
                        const Center(child: Text('Coming Soon'))),
                    _panel(cardWidth, '📊 Web Dashboard',
                        const Center(child: Text('Premium Feature'))),
                    _panel(cardWidth, '💎 Premium Plans',
                        _subscriptionSection(state, uid)),
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

  Widget _universitySection(Sprint5State state, String? uid) {
    final universities = ref.watch(universitiesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: universitySearchController,
          decoration: _decoration('Search universities...'),
          onChanged: ref.read(sprint5Provider.notifier).setUniversitySearch,
        ),
        const SizedBox(height: 12),
        universities.when(
          data: (unis) => Text('${unis.length} universities available'),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
        const SizedBox(height: 8),
        const Text('• Filter by country'),
        const Text('• View admission requirements'),
        const Text('• Check average test scores'),
      ],
    );
  }

  Widget _scholarshipSection(Sprint5State state, String? uid) {
    final scholarships = ref.watch(scholarshipsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: scholarshipSearchController,
          decoration: _decoration('Search scholarships...'),
          onChanged: ref.read(sprint5Provider.notifier).setScholarshipSearch,
        ),
        const SizedBox(height: 12),
        scholarships.when(
          data: (schols) => Text('${schols.length} scholarships available'),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
        const SizedBox(height: 8),
        const Text('• Filter by university'),
        const Text('• View eligibility criteria'),
        const Text('• Get application deadlines'),
      ],
    );
  }

  Widget _interviewSection(
      Sprint5State state, String? uid, String displayName) {
    final topics = ['Leadership', 'Problem Solving', 'Communication', 'Teamwork', 'Motivation'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: state.interviewTopic,
          decoration: _decoration('Interview Topic'),
          items: topics
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (t) {
            if (t != null) {
              ref.read(sprint5Provider.notifier).setInterviewTopic(t);
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: interviewAnswerController,
          decoration: _decoration('Your Answer'),
          minLines: 4,
          maxLines: 6,
          onChanged:
              ref.read(sprint5Provider.notifier).setInterviewAnswer,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: uid == null || state.isLoading
              ? null
              : () => ref.read(sprint5Provider.notifier).conductInterview(uid, displayName),
          icon: const Icon(Icons.record_voice_over),
          label: const Text('Practice Interview'),
        ),
        if (state.lastInterviewSession != null) ...[
          const SizedBox(height: 12),
          _scoreLine('Overall', '${state.lastInterviewSession!.overallScore.toStringAsFixed(1)}/10'),
          _scoreLine('Confidence', '${state.lastInterviewSession!.confidenceScore.toStringAsFixed(1)}/10'),
          const SizedBox(height: 8),
          Text('Improvements:'),
          ...state.lastInterviewSession!.improvements
              .map((imp) => Text('• $imp')),
        ],
      ],
    );
  }

  Widget _studyGroupSection(
      Sprint5State state, String? uid, String displayName) {
    final groups = ref.watch(studyGroupsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: groupNameController,
          decoration: _decoration('Group Name'),
          onChanged: ref.read(sprint5Provider.notifier).setGroupName,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: groupDescController,
          decoration: _decoration('Description'),
          minLines: 2,
          maxLines: 3,
          onChanged: ref.read(sprint5Provider.notifier).setGroupDescription,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: state.groupTopic,
          decoration: _decoration('Topic'),
          items: ['Reading', 'Writing', 'Speaking', 'Vocabulary']
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (t) {
            if (t != null) {
              ref.read(sprint5Provider.notifier).setGroupTopic(t);
            }
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: uid == null || state.isLoading
              ? null
              : () => ref.read(sprint5Provider.notifier).createStudyGroup(uid, displayName),
          icon: const Icon(Icons.group_add),
          label: const Text('Create Group'),
        ),
        const SizedBox(height: 12),
        groups.when(
          data: (groupList) => Text('${groupList.length} active groups'),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _forumSection(Sprint5State state, String? uid, String displayName) {
    final posts = ref.watch(forumPostsProvider);
    final categories = ['General Advice', 'Study Tips', 'Exam Strategy', 'University Life'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: postTitleController,
          decoration: _decoration('Post Title'),
          onChanged: ref.read(sprint5Provider.notifier).setPostTitle,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: postContentController,
          decoration: _decoration('Post Content'),
          minLines: 3,
          maxLines: 4,
          onChanged: ref.read(sprint5Provider.notifier).setPostContent,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: state.postCategory,
          decoration: _decoration('Category'),
          items: categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (c) {
            if (c != null) {
              ref.read(sprint5Provider.notifier).setPostCategory(c);
            }
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: uid == null || state.isLoading
              ? null
              : () => ref.read(sprint5Provider.notifier).createPost(uid, displayName),
          icon: const Icon(Icons.post_add),
          label: const Text('Create Post'),
        ),
        const SizedBox(height: 12),
        posts.when(
          data: (postList) => Text('${postList.length} community posts'),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _careerSection(Sprint5State state, String? uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: careerGoalController,
          decoration: _decoration('Career Goal (e.g., Data Science Leader)'),
          onChanged: ref.read(sprint5Provider.notifier).setCareerGoal,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: targetRoleController,
          decoration: _decoration('Target Role (e.g., Senior Data Scientist)'),
          onChanged: ref.read(sprint5Provider.notifier).setTargetRole,
        ),
        const SizedBox(height: 12),
        Slider(
          value: state.targetScore.toDouble(),
          min: 50,
          max: 200,
          divisions: 15,
          label: '${state.targetScore}',
          onChanged: (val) =>
              ref.read(sprint5Provider.notifier).setTargetScore(val.toInt()),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: uid == null || state.isLoading
              ? null
              : () =>
                  ref.read(sprint5Provider.notifier).generateCareerRoadmap(uid),
          icon: const Icon(Icons.auto_stories),
          label: const Text('Generate Roadmap'),
        ),
        if (state.careerRoadmap != null) ...[
          const SizedBox(height: 12),
          Text('Goal: ${state.careerRoadmap!.careerGoal}'),
          Text('Progress: ${state.careerRoadmap!.progressPercent.toStringAsFixed(0)}%'),
          const SizedBox(height: 8),
          Text('Milestones:', style: Theme.of(context).textTheme.titleSmall),
          ...state.careerRoadmap!.milestones.map((m) => Text('• $m')),
        ],
      ],
    );
  }

  Widget _subscriptionSection(Sprint5State state, String? uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Pro Plan: \$9.99/month'),
        const SizedBox(height: 6),
        const Text('• Unlimited Mocks'),
        const Text('• Interview Coach'),
        const Text('• Study Groups'),
        const SizedBox(height: 14),
        const Text('Elite Plan: \$19.99/month'),
        const SizedBox(height: 6),
        const Text('• Everything in Pro'),
        const Text('• Career Roadmap'),
        const Text('• University Finder'),
        const SizedBox(height: 14),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(label: Text('Pro'), value: 'Pro'),
            ButtonSegment(label: Text('Elite'), value: 'Elite'),
          ],
          selected: {state.selectedPlan},
          onSelectionChanged: (sel) {
            ref.read(sprint5Provider.notifier).setSelectedPlan(sel.first);
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: uid == null || state.isLoading
              ? null
              : () =>
                  ref.read(sprint5Provider.notifier).upgradeToPremium(uid),
          icon: const Icon(Icons.credit_card),
          label: const Text('Upgrade Now'),
        ),
      ],
    );
  }

  Widget _panel(double width, String title, Widget child) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _infoPanel(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
    );
  }

  Widget _errorPanel(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
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
}
