import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../services/gemini_service.dart';
import '../../../services/youtube_service.dart';

// ─── Activity Log Model ────────────────────────────────────────────────────
class ActivityLog {
  final String activity;
  final String category;
  final int score; // 0–100
  final DateTime date;
  ActivityLog({
    required this.activity,
    required this.category,
    required this.score,
    required this.date,
  });
}

// ─── Analytics State ──────────────────────────────────────────────────────
class AnalyticsState {
  final List<ActivityLog> activityLogs;
  final List<Map<String, dynamic>> weeklyScores;
  final String aiSuggestion;
  final List<YouTubeVideo> videos;
  final bool isLoading;
  final bool isLoadingVideos;
  final String? error;

  const AnalyticsState({
    this.activityLogs = const [],
    this.weeklyScores = const [],
    this.aiSuggestion = '',
    this.videos = const [],
    this.isLoading = false,
    this.isLoadingVideos = false,
    this.error,
  });

  AnalyticsState copyWith({
    List<ActivityLog>? activityLogs,
    List<Map<String, dynamic>>? weeklyScores,
    String? aiSuggestion,
    List<YouTubeVideo>? videos,
    bool? isLoading,
    bool? isLoadingVideos,
    String? error,
  }) {
    return AnalyticsState(
      activityLogs: activityLogs ?? this.activityLogs,
      weeklyScores: weeklyScores ?? this.weeklyScores,
      aiSuggestion: aiSuggestion ?? this.aiSuggestion,
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingVideos: isLoadingVideos ?? this.isLoadingVideos,
      error: error,
    );
  }
}

// ─── Analytics Notifier ───────────────────────────────────────────────────
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier() : super(const AnalyticsState());

  void loadDemoData(String examType) {
    // In a real app these would come from Firestore quiz_results, mock_results, etc.
    final now = DateTime.now();
    final logs = [
      ActivityLog(activity: 'Daily Quiz', category: 'Practice', score: 78, date: now.subtract(const Duration(days: 0))),
      ActivityLog(activity: 'Reading Exercise', category: 'Study', score: 85, date: now.subtract(const Duration(days: 1))),
      ActivityLog(activity: 'Mock Test Section 1', category: 'Mock', score: 72, date: now.subtract(const Duration(days: 2))),
      ActivityLog(activity: 'Vocabulary Review', category: 'Study', score: 90, date: now.subtract(const Duration(days: 3))),
      ActivityLog(activity: 'Writing Practice', category: 'Practice', score: 65, date: now.subtract(const Duration(days: 4))),
      ActivityLog(activity: 'Listening Drill', category: 'Study', score: 80, date: now.subtract(const Duration(days: 5))),
      ActivityLog(activity: 'Full Mock Test', category: 'Mock', score: 74, date: now.subtract(const Duration(days: 6))),
    ];

    final weeklyScores = [
      {'day': 'Mon', 'score': 74},
      {'day': 'Tue', 'score': 80},
      {'day': 'Wed', 'score': 65},
      {'day': 'Thu', 'score': 90},
      {'day': 'Fri', 'score': 85},
      {'day': 'Sat', 'score': 78},
      {'day': 'Sun', 'score': 82},
    ];

    state = state.copyWith(activityLogs: logs, weeklyScores: weeklyScores);
  }

  Future<void> fetchAiSuggestion({
    required String examType,
    required String currentLevel,
    required List<String> weakAreas,
    required double readinessScore,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prompt = '''
You are an expert $examType coach analyzing a student's performance data.

Student Profile:
- Exam: $examType
- Current Level: $currentLevel
- Readiness Score: ${readinessScore.toStringAsFixed(0)}%
- Weak Areas: ${weakAreas.join(', ')}
- Recent Activities: ${state.activityLogs.map((l) => '${l.activity} (${l.score}%)').join(', ')}

Provide a SHORT, encouraging 3-sentence coaching insight:
1. What is going well (based on scores above 80%)
2. What needs immediate focus (the weakest area)
3. One specific action they should take TODAY

Keep it personal, motivating and specific to $examType. Do NOT use bullet points, just 3 natural sentences.
''';
      final gemini = GeminiService();
      final suggestion = await gemini.generateFromPrompt(prompt, temperature: 0.7, maxTokens: 200);
      state = state.copyWith(aiSuggestion: suggestion, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        aiSuggestion: 'Keep up the great work! Focus on your weak areas today and practice at least one full section.',
        isLoading: false,
      );
    }
  }

  Future<void> fetchVideos(String examType) async {
    state = state.copyWith(isLoadingVideos: true);
    try {
      final videos = await YouTubeService.fetchVideosForExam(examType: examType);
      state = state.copyWith(videos: videos, isLoadingVideos: false);
    } catch (_) {
      state = state.copyWith(isLoadingVideos: false);
    }
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>(
  (ref) => AnalyticsNotifier(),
);

// ─── Main Analytics Screen ────────────────────────────────────────────────
class LearningAnalyticsScreen extends ConsumerStatefulWidget {
  const LearningAnalyticsScreen({super.key});

  @override
  ConsumerState<LearningAnalyticsScreen> createState() =>
      _LearningAnalyticsScreenState();
}

class _LearningAnalyticsScreenState
    extends ConsumerState<LearningAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final auth = ref.read(authStateProvider);
    if (auth is! Authenticated) return;
    final user = auth.user;
    final notifier = ref.read(analyticsProvider.notifier);
    notifier.loadDemoData(user.examType);
    notifier.fetchAiSuggestion(
      examType: user.examType,
      currentLevel: user.currentLevel,
      weakAreas: user.weakAreas,
      readinessScore: user.readinessScore,
    );
    notifier.fetchVideos(user.examType);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsProvider);
    final auth = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    if (auth is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Learning Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Progress'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
            Tab(icon: Icon(Icons.play_circle_outline), text: 'Videos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProgressTab(context, state, user, theme),
          _buildActivityTab(context, state, theme),
          _buildVideosTab(context, state, user, theme),
        ],
      ),
    );
  }

  // ── Tab 1: Progress ────────────────────────────────────────────────────
  Widget _buildProgressTab(BuildContext context, AnalyticsState state,
      dynamic user, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header stats
          _buildStatsRow(user, theme),
          const SizedBox(height: 24),

          // Weekly score chart
          _buildSectionTitle('📈 Weekly Score Progress', theme),
          const SizedBox(height: 12),
          _buildBarChart(state.weeklyScores, theme),
          const SizedBox(height: 24),

          // Weak areas
          _buildSectionTitle('⚠️ Areas Needing Focus', theme),
          const SizedBox(height: 12),
          _buildWeakAreasCard(user.weakAreas, theme),
          const SizedBox(height: 24),

          // AI Suggestion
          _buildSectionTitle('🤖 AI Coach Insight', theme),
          const SizedBox(height: 12),
          _buildAiInsightCard(state, theme),
        ],
      ),
    );
  }

  Widget _buildStatsRow(dynamic user, ThemeData theme) {
    return Row(
      children: [
        _buildStatCard('Readiness', '${user.readinessScore.toStringAsFixed(0)}%',
            Icons.speed, Colors.blue, theme),
        const SizedBox(width: 12),
        _buildStatCard('Streak', '${user.studyStreak} days',
            Icons.local_fire_department, Colors.orange, theme),
        const SizedBox(width: 12),
        _buildStatCard('Level', _capitalize(user.currentLevel),
            Icons.star, Colors.purple, theme),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon,
      Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> weeklyScores, ThemeData theme) {
    if (weeklyScores.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final maxScore = 100.0;
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weeklyScores.map((data) {
          final score = (data['score'] as int).toDouble();
          final heightFraction = score / maxScore;
          final isToday = data['day'] == _todayAbbrev();
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('${score.toInt()}',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isToday ? theme.colorScheme.primary : Colors.grey)),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 28,
                height: 130 * heightFraction,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isToday
                        ? [theme.colorScheme.primary, theme.colorScheme.secondary]
                        : [Colors.blue.shade200, Colors.blue.shade100],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(data['day'] as String,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? theme.colorScheme.primary : Colors.grey)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeakAreasCard(List<String> weakAreas, ThemeData theme) {
    if (weakAreas.isEmpty) {
      return _buildInfoCard('No weak areas detected yet. Keep practising!', theme);
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: weakAreas.map((area) {
          return Chip(
            label: Text(area),
            backgroundColor: Colors.red.shade50,
            side: BorderSide(color: Colors.red.shade200),
            labelStyle: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
            avatar: const Icon(Icons.warning_amber, size: 16, color: Colors.red),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAiInsightCard(AnalyticsState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.9),
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('SmartGo AI says:',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  state.aiSuggestion.isEmpty
                      ? 'Tap to get your personalized AI insight...'
                      : state.aiSuggestion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white, height: 1.6),
                ),
              ],
            ),
    );
  }

  // ── Tab 2: Activity Log ────────────────────────────────────────────────
  Widget _buildActivityTab(BuildContext context, AnalyticsState state,
      ThemeData theme) {
    if (state.activityLogs.isEmpty) {
      return const Center(child: Text('No activity recorded yet.'));
    }

    // Compute summary stats
    final avgScore = state.activityLogs.isEmpty
        ? 0
        : state.activityLogs.map((l) => l.score).reduce((a, b) => a + b) ~/
            state.activityLogs.length;
    final bestScore = state.activityLogs.map((l) => l.score).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary row
          Row(
            children: [
              _buildStatCard('Avg Score', '$avgScore%', Icons.analytics,
                  Colors.teal, theme),
              const SizedBox(width: 12),
              _buildStatCard('Best Score', '$bestScore%', Icons.emoji_events,
                  Colors.amber, theme),
              const SizedBox(width: 12),
              _buildStatCard('Activities', '${state.activityLogs.length}',
                  Icons.checklist, Colors.indigo, theme),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('📋 Recent Activity', theme),
          const SizedBox(height: 12),
          ...state.activityLogs.map((log) => _buildActivityCard(log, theme)),
        ],
      ),
    );
  }

  Widget _buildActivityCard(ActivityLog log, ThemeData theme) {
    final color = log.score >= 80
        ? Colors.green
        : log.score >= 60
            ? Colors.orange
            : Colors.red;
    final icon = log.category == 'Mock'
        ? Icons.assignment
        : log.category == 'Practice'
            ? Icons.sports_esports
            : Icons.book;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.activity,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  '${log.category} • ${_formatDate(log.date)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${log.score}%',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Video Lessons ───────────────────────────────────────────────
  Widget _buildVideosTab(BuildContext context, AnalyticsState state,
      dynamic user, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.play_circle, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user.examType} Video Lessons',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold)),
                      Text('Curated educational content for ${user.examType}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (state.isLoadingVideos)
            const Center(child: CircularProgressIndicator())
          else if (state.videos.isEmpty)
            _buildNoVideosCard(user.examType, theme)
          else
            ...state.videos.map((video) => _buildVideoCard(video, theme)),
        ],
      ),
    );
  }

  Widget _buildVideoCard(YouTubeVideo video, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  video.thumbnailUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.video_library, size: 48, color: Colors.grey),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  video.channelTitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[500]),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openVideo(context, video),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Watch on YouTube'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVideosCard(String examType, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.videocam_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            'YouTube videos require a free API key',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Get a free YouTube Data API v3 key at console.cloud.google.com and add it to the app to unlock $examType video lessons.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openVideo(BuildContext context, YouTubeVideo video) {
    // Show a dialog with the video link since web can't open external URLs natively
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(video.title, maxLines: 2, style: const TextStyle(fontSize: 15)),
        content: Text('Open this video on YouTube?\n\n${video.watchUrl}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening: ${video.watchUrl}')),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(title,
        style: theme.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildInfoCard(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: theme.textTheme.bodyMedium),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _todayAbbrev() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[DateTime.now().weekday - 1];
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }
}
