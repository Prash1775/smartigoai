import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/auth_provider.dart';
import 'reading_practice_screen.dart';
import 'vocabulary_screen.dart';
import 'writing_practice_screen.dart';
import 'listening_practice_screen.dart';
import 'speaking_practice_screen.dart';

// ─────────────────────────────────────────────────────────────
// Data model for a syllabus topic
// ─────────────────────────────────────────────────────────────
class SyllabusTopic {
  final String name;
  final String icon;
  final double progress; // 0.0 – 1.0
  final int totalLessons;
  final int completedLessons;
  final Color color;

  const SyllabusTopic({
    required this.name,
    required this.icon,
    required this.progress,
    required this.totalLessons,
    required this.completedLessons,
    required this.color,
  });
}

enum TaskType { reading, writing, vocabulary, listening, speaking, quant, verbal, dataInsights }

class DailyTask {
  final String title;
  final String subtitle;
  final IconData icon;
  final TaskType taskType;
  bool completed;

  DailyTask({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.taskType,
    this.completed = false,
  });
}

class StudyChannel {
  final String name;
  final String description;
  final String specialty; // e.g. 'Speaking & Writing'
  final String channelUrl;
  final String subscribers;
  final Color avatarColor;
  final String avatarEmoji;
  final List<String> tags;

  const StudyChannel({
    required this.name,
    required this.description,
    required this.specialty,
    required this.channelUrl,
    required this.subscribers,
    required this.avatarColor,
    required this.avatarEmoji,
    required this.tags,
  });
}

// ─────────────────────────────────────────────────────────────
// Exam-specific data
// ─────────────────────────────────────────────────────────────
class _ExamData {
  static List<SyllabusTopic> syllabus(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return [
          SyllabusTopic(name: 'Listening', icon: '🎧', progress: 0.72, totalLessons: 25, completedLessons: 18, color: Colors.teal),
          SyllabusTopic(name: 'Reading', icon: '📖', progress: 0.60, totalLessons: 30, completedLessons: 18, color: Colors.blue),
          SyllabusTopic(name: 'Writing Task 1', icon: '✏️', progress: 0.45, totalLessons: 20, completedLessons: 9, color: Colors.orange),
          SyllabusTopic(name: 'Writing Task 2', icon: '📝', progress: 0.30, totalLessons: 20, completedLessons: 6, color: Colors.deepOrange),
          SyllabusTopic(name: 'Speaking', icon: '🎤', progress: 0.55, totalLessons: 15, completedLessons: 8, color: Colors.purple),
          SyllabusTopic(name: 'Vocabulary', icon: '🔤', progress: 0.80, totalLessons: 40, completedLessons: 32, color: Colors.green),
        ];
      case 'GRE':
        return [
          SyllabusTopic(name: 'Verbal Reasoning', icon: '💬', progress: 0.65, totalLessons: 30, completedLessons: 19, color: Colors.blue),
          SyllabusTopic(name: 'Quantitative Reasoning', icon: '🔢', progress: 0.50, totalLessons: 35, completedLessons: 17, color: Colors.green),
          SyllabusTopic(name: 'Analytical Writing', icon: '✍️', progress: 0.35, totalLessons: 15, completedLessons: 5, color: Colors.orange),
          SyllabusTopic(name: 'Text Completion', icon: '📄', progress: 0.70, totalLessons: 20, completedLessons: 14, color: Colors.purple),
          SyllabusTopic(name: 'Reading Comprehension', icon: '📖', progress: 0.55, totalLessons: 25, completedLessons: 14, color: Colors.teal),
          SyllabusTopic(name: 'Algebra & Geometry', icon: '📐', progress: 0.40, totalLessons: 20, completedLessons: 8, color: Colors.red),
        ];
      case 'GMAT':
      default:
        return [
          SyllabusTopic(name: 'Quantitative', icon: '🔢', progress: 0.60, totalLessons: 35, completedLessons: 21, color: Colors.blue),
          SyllabusTopic(name: 'Verbal', icon: '💬', progress: 0.55, totalLessons: 30, completedLessons: 16, color: Colors.green),
          SyllabusTopic(name: 'Data Insights', icon: '📊', progress: 0.40, totalLessons: 25, completedLessons: 10, color: Colors.orange),
          SyllabusTopic(name: 'Critical Reasoning', icon: '🧠', progress: 0.50, totalLessons: 20, completedLessons: 10, color: Colors.purple),
          SyllabusTopic(name: 'Reading Comprehension', icon: '📖', progress: 0.65, totalLessons: 20, completedLessons: 13, color: Colors.teal),
          SyllabusTopic(name: 'Sentence Correction', icon: '✏️', progress: 0.30, totalLessons: 15, completedLessons: 4, color: Colors.red),
        ];
    }
  }

  static List<DailyTask> dailyTasks(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return [
          DailyTask(title: 'Read 1 academic article', subtitle: 'True/False/Not Given practice', icon: Icons.menu_book, taskType: TaskType.reading),
          DailyTask(title: 'Write 1 Task 2 essay', subtitle: 'Agree/Disagree topic – 250 words', icon: Icons.edit, taskType: TaskType.writing),
          DailyTask(title: 'Learn 10 vocabulary words', subtitle: 'Academic Word List – flashcards', icon: Icons.abc, taskType: TaskType.vocabulary),
          DailyTask(title: 'Listen to 1 audio passage', subtitle: 'IELTS Listening Section 3', icon: Icons.headphones, taskType: TaskType.listening),
          DailyTask(title: 'Speaking practice – 3 mins', subtitle: 'Describe a place you have visited', icon: Icons.mic, taskType: TaskType.speaking),
        ];
      case 'GRE':
        return [
          DailyTask(title: '1 Reading Comprehension set', subtitle: '5 questions on a long passage', icon: Icons.menu_book, taskType: TaskType.reading),
          DailyTask(title: 'Write 1 Issue Essay outline', subtitle: 'Practice structuring your argument', icon: Icons.edit, taskType: TaskType.writing),
          DailyTask(title: 'Flashcards – 20 GRE words', subtitle: 'High-frequency vocabulary review', icon: Icons.style, taskType: TaskType.vocabulary),
          DailyTask(title: '10 Quantitative questions', subtitle: 'Algebra & Number Properties', icon: Icons.calculate, taskType: TaskType.quant),
          DailyTask(title: '15 Verbal Reasoning questions', subtitle: 'Sentence Equivalence & Text Completion', icon: Icons.spellcheck, taskType: TaskType.verbal),
        ];
      case 'GMAT':
      default:
        return [
          DailyTask(title: '1 Reading Comprehension passage', subtitle: 'Business or science topic', icon: Icons.menu_book, taskType: TaskType.reading),
          DailyTask(title: 'Write 1 AWA essay', subtitle: 'Analyse an argument critically', icon: Icons.edit, taskType: TaskType.writing),
          DailyTask(title: '5 Sentence Correction drills', subtitle: 'Parallelism & Modifier errors', icon: Icons.spellcheck, taskType: TaskType.vocabulary),
          DailyTask(title: '10 Quantitative questions', subtitle: 'Data Sufficiency focus', icon: Icons.calculate, taskType: TaskType.quant),
          DailyTask(title: 'Review 1 Data Insights set', subtitle: 'Multi-source reasoning practice', icon: Icons.bar_chart, taskType: TaskType.dataInsights),
        ];
    }
  }

  static List<StudyChannel> channels(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return [
          StudyChannel(
            name: 'E2 IELTS',
            description: 'The world\'s #1 IELTS YouTube channel. Full lessons, live practice tests, and expert teachers. Best for all 4 skills.',
            specialty: 'All Skills',
            channelUrl: 'https://www.youtube.com/@E2IELTS',
            subscribers: '4.5M+',
            avatarColor: Color(0xFF1565C0),
            avatarEmoji: '🎯',
            tags: ['Listening', 'Reading', 'Writing', 'Speaking'],
          ),
          StudyChannel(
            name: 'IELTS Liz',
            description: 'Free IELTS tips, model answers, lessons and videos. One of the most trusted individual IELTS tutors online.',
            specialty: 'Writing & Tips',
            channelUrl: 'https://www.youtube.com/@ieltsliz',
            subscribers: '500K+',
            avatarColor: Color(0xFF6A1B9A),
            avatarEmoji: '📝',
            tags: ['Writing', 'Speaking', 'Grammar'],
          ),
          StudyChannel(
            name: 'IELTS Simon',
            description: 'Former IELTS examiner sharing insider tips for Writing Task 1 & 2, plus Reading and Listening strategies.',
            specialty: 'Writing (Examiner)',
            channelUrl: 'https://www.youtube.com/@ieltssimon',
            subscribers: '200K+',
            avatarColor: Color(0xFF2E7D32),
            avatarEmoji: '✍️',
            tags: ['Writing Task 1', 'Writing Task 2', 'Examiner Tips'],
          ),
          StudyChannel(
            name: 'British Council',
            description: 'Official British Council IELTS channel. Authentic practice materials, exam format walkthroughs, and speaking samples.',
            specialty: 'Official Practice',
            channelUrl: 'https://www.youtube.com/@BritishCouncil',
            subscribers: '1M+',
            avatarColor: Color(0xFFB71C1C),
            avatarEmoji: '🇬🇧',
            tags: ['Official', 'Speaking', 'Listening'],
          ),
          StudyChannel(
            name: 'IELTS Advantage',
            description: 'High-quality lessons from experienced IELTS teachers. Strong focus on Writing Task 2 band 7+ strategies.',
            specialty: 'Writing Band 7+',
            channelUrl: 'https://www.youtube.com/@IELTSAdvantage',
            subscribers: '300K+',
            avatarColor: Color(0xFFE65100),
            avatarEmoji: '⭐',
            tags: ['Writing', 'Band 7', 'Band 8'],
          ),
          StudyChannel(
            name: 'Oxford Online English',
            description: 'General English & IELTS preparation. Clear grammar, vocabulary, and speaking lessons from qualified teachers.',
            specialty: 'Grammar & Speaking',
            channelUrl: 'https://www.youtube.com/@OxfordOnlineEnglish',
            subscribers: '800K+',
            avatarColor: Color(0xFF004D40),
            avatarEmoji: '📚',
            tags: ['Grammar', 'Vocabulary', 'Speaking'],
          ),
          StudyChannel(
            name: 'Asad Yaqub',
            description: 'Detailed IELTS preparation videos with focus on common mistakes, band score improvements, and practice tests.',
            specialty: 'Listening & Reading',
            channelUrl: 'https://www.youtube.com/@AsadYaqub',
            subscribers: '400K+',
            avatarColor: Color(0xFF0277BD),
            avatarEmoji: '🎧',
            tags: ['Listening', 'Reading', 'Practice Tests'],
          ),
          StudyChannel(
            name: 'IELTS Ryan',
            description: 'Focused on IELTS Speaking with real Part 1, 2, and 3 model answers, pronunciation tips, and vocabulary.',
            specialty: 'Speaking Expert',
            channelUrl: 'https://www.youtube.com/@ieltsspeakingwithRyan',
            subscribers: '150K+',
            avatarColor: Color(0xFF880E4F),
            avatarEmoji: '🎤',
            tags: ['Speaking Part 1', 'Speaking Part 2', 'Speaking Part 3'],
          ),
          StudyChannel(
            name: 'Magoosh IELTS',
            description: 'Magoosh\'s IELTS channel with expert lessons, vocabulary, and full course previews for all exam sections.',
            specialty: 'Full Course',
            channelUrl: 'https://www.youtube.com/@magoosh',
            subscribers: '1.2M+',
            avatarColor: Color(0xFF37474F),
            avatarEmoji: '🏆',
            tags: ['All Skills', 'Vocabulary', 'Test Strategy'],
          ),
          StudyChannel(
            name: 'Keith Speaking Academy',
            description: 'Expert IELTS & TOEFL speaking training. Real band 8–9 speaking samples and detailed feedback analysis.',
            specialty: 'Speaking Band 8+',
            channelUrl: 'https://www.youtube.com/results?search_query=keith+speaking+academy+ielts',
            subscribers: '200K+',
            avatarColor: Color(0xFF4527A0),
            avatarEmoji: '💬',
            tags: ['Speaking', 'Band 8', 'Band 9'],
          ),
        ];
      case 'GRE':
        return [
          StudyChannel(
            name: 'GregMAT',
            description: 'The most popular GRE prep channel. Greg Mat breaks down every GRE concept with clarity and humor. Free full course.',
            specialty: 'Full GRE Course',
            channelUrl: 'https://www.youtube.com/@GregMAT',
            subscribers: '400K+',
            avatarColor: Color(0xFF1565C0),
            avatarEmoji: '🎯',
            tags: ['Verbal', 'Quant', 'AWA', 'Full Course'],
          ),
          StudyChannel(
            name: 'Magoosh GRE',
            description: 'Expert GRE lessons covering Verbal, Quant, and Writing. High-quality free content from a top test prep company.',
            specialty: 'Quant & Verbal',
            channelUrl: 'https://www.youtube.com/@magoosh',
            subscribers: '1.2M+',
            avatarColor: Color(0xFF2E7D32),
            avatarEmoji: '📊',
            tags: ['Quant', 'Verbal', 'Vocabulary'],
          ),
          StudyChannel(
            name: 'Manhattan Prep GRE',
            description: 'Premium GRE prep content from Manhattan Prep. Strategy-focused lessons with a focus on 160+ score targets.',
            specialty: '160+ Score Strategy',
            channelUrl: 'https://www.youtube.com/results?search_query=manhattan+prep+gre+lessons',
            subscribers: '80K+',
            avatarColor: Color(0xFFB71C1C),
            avatarEmoji: '🏙️',
            tags: ['Advanced', 'Quant', 'High Score'],
          ),
          StudyChannel(
            name: 'PrepScholar GRE',
            description: 'Step-by-step GRE strategy guides with focus on efficient score improvement and common mistake avoidance.',
            specialty: 'Strategy & Tips',
            channelUrl: 'https://www.youtube.com/results?search_query=prepscholar+gre',
            subscribers: '50K+',
            avatarColor: Color(0xFFE65100),
            avatarEmoji: '📈',
            tags: ['Strategy', 'Verbal', 'Tips'],
          ),
          StudyChannel(
            name: 'ETS Official GRE',
            description: 'Official GRE channel by ETS (the exam makers). Authoritative walkthroughs of the exam format and sample questions.',
            specialty: 'Official ETS',
            channelUrl: 'https://www.youtube.com/results?search_query=ets+official+gre+prep',
            subscribers: '30K+',
            avatarColor: Color(0xFF880E4F),
            avatarEmoji: '🏛️',
            tags: ['Official', 'Practice Questions', 'Format'],
          ),
        ];
      case 'GMAT':
      default:
        return [
          StudyChannel(
            name: 'GMAT Club',
            description: 'The internet\'s largest GMAT community. Thousands of practice questions, expert explanations, and strategy videos.',
            specialty: 'All Sections',
            channelUrl: 'https://www.youtube.com/@gmatclub',
            subscribers: '100K+',
            avatarColor: Color(0xFF1565C0),
            avatarEmoji: '🏆',
            tags: ['Quant', 'Verbal', 'Community', 'Practice'],
          ),
          StudyChannel(
            name: 'Target Test Prep',
            description: 'Highly rated GMAT Quant prep. Methodical, topic-by-topic breakdown of every quantitative concept on the GMAT.',
            specialty: 'Quant Mastery',
            channelUrl: 'https://www.youtube.com/results?search_query=target+test+prep+gmat',
            subscribers: '50K+',
            avatarColor: Color(0xFFB71C1C),
            avatarEmoji: '🔢',
            tags: ['Quant', 'Data Sufficiency', 'Problem Solving'],
          ),
          StudyChannel(
            name: 'Magoosh GMAT',
            description: 'Clear GMAT lessons covering Critical Reasoning, Sentence Correction, Data Sufficiency, and more. Beginner-friendly.',
            specialty: 'Verbal & Quant',
            channelUrl: 'https://www.youtube.com/@magoosh',
            subscribers: '1.2M+',
            avatarColor: Color(0xFF2E7D32),
            avatarEmoji: '📚',
            tags: ['Verbal', 'Quant', 'Critical Reasoning'],
          ),
          StudyChannel(
            name: 'Manhattan Prep GMAT',
            description: 'Expert GMAT content from one of the most respected test prep companies. Focus on 700+ score strategies.',
            specialty: '700+ Strategy',
            channelUrl: 'https://www.youtube.com/results?search_query=manhattan+prep+gmat+lessons',
            subscribers: '60K+',
            avatarColor: Color(0xFFE65100),
            avatarEmoji: '🏙️',
            tags: ['700+', 'Strategy', 'Advanced'],
          ),
          StudyChannel(
            name: 'e-GMAT',
            description: 'e-GMAT is trusted by 100,000+ students. Structured learning for Verbal with a proven process for non-native speakers.',
            specialty: 'Verbal for Non-Native',
            channelUrl: 'https://www.youtube.com/results?search_query=e-gmat+verbal+lessons',
            subscribers: '80K+',
            avatarColor: Color(0xFF4527A0),
            avatarEmoji: '🌍',
            tags: ['Verbal', 'Non-Native', 'Sentence Correction'],
          ),
        ];
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Main Learn Screen
// ─────────────────────────────────────────────────────────────
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  late List<DailyTask> _dailyTasks;
  String _lastExamType = '';

  void _initTasksForExam(String examType) {
    if (examType != _lastExamType) {
      _lastExamType = examType;
      _dailyTasks = _ExamData.dailyTasks(examType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState is Authenticated ? authState.user : null;
    final examType = user?.examType ?? 'IELTS';
    final theme = Theme.of(context);

    _initTasksForExam(examType);

    final syllabus = _ExamData.syllabus(examType);
    final channels = _ExamData.channels(examType);

    final completedTasks = _dailyTasks.where((t) => t.completed).length;
    final totalTasks = _dailyTasks.length;
    final dailyProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Learn'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                examType,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Daily Practice Card ───
          _buildDailyPracticeCard(
            context,
            completedTasks: completedTasks,
            totalTasks: totalTasks,
            dailyProgress: dailyProgress,
          ),
          const SizedBox(height: 24),

          // ─── Today's Tasks ───
          _buildSectionHeader(context, '📅 Today\'s Practice Tasks'),
          const SizedBox(height: 12),
          ..._dailyTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            return _buildTaskCard(context, task, index);
          }),
          const SizedBox(height: 24),

          // ─── Syllabus ───
          _buildSectionHeader(context, '📚 $examType Syllabus'),
          const SizedBox(height: 4),
          Text(
            'Your progress across all ${examType} topics',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: syllabus.length,
            itemBuilder: (context, index) {
              return _buildSyllabusCard(context, syllabus[index]);
            },
          ),
          const SizedBox(height: 24),

          // ─── Top Study Channels ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📺 Top ${examType} Channels',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.smart_display, color: Colors.red.shade600, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'YouTube',
                      style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap any channel to open it on YouTube',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          ...channels.asMap().entries.map((entry) {
            return _buildChannelCard(context, entry.value, entry.key + 1);
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Daily Practice Banner ──────────────────────────────────
  Widget _buildDailyPracticeCard(
    BuildContext context, {
    required int completedTasks,
    required int totalTasks,
    required double dailyProgress,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Today's Study Goal",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completedTasks / $totalTasks tasks done',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: dailyProgress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dailyProgress == 1.0
                      ? '🎉 All done for today! Great work!'
                      : '${((1 - dailyProgress) * 100).toInt()}% remaining – keep going!',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              '${(dailyProgress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Navigate to the correct practice screen ──────────────
  void _openTask(BuildContext context, DailyTask task) {
    final examType = _lastExamType;
    Widget? screen;

    switch (task.taskType) {
      case TaskType.reading:
        screen = ReadingPracticeScreen(examType: examType);
        break;
      case TaskType.writing:
        screen = WritingPracticeScreen(examType: examType);
        break;
      case TaskType.vocabulary:
        screen = VocabularyScreen(examType: examType);
        break;
      case TaskType.listening:
        screen = ListeningPracticeScreen(examType: examType);
        break;
      case TaskType.speaking:
        screen = SpeakingPracticeScreen(examType: examType);
        break;
      case TaskType.quant:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🔢 Quantitative practice module is coming in the next update!')),
        );
        return;
      case TaskType.verbal:
        screen = ReadingPracticeScreen(examType: examType);
        break;
      case TaskType.dataInsights:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📊 Data Insights module is coming in the next update!')),
        );
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen!),
    ).then((_) {
      // Mark task completed when returning from the practice screen
      setState(() => task.completed = true);
    });
  }

  // ── Task Card (Clickable → Opens Real Practice Screen) ────
  Widget _buildTaskCard(BuildContext context, DailyTask task, int index) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          if (task.completed) {
            // Toggle back if already done
            setState(() => task.completed = false);
          } else {
            _openTask(context, task);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: task.completed
                ? theme.colorScheme.primaryContainer.withOpacity(0.6)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: task.completed
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.completed
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: task.completed
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: task.completed
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 14),
              Icon(task.icon, size: 22, color: task.completed ? theme.colorScheme.primary : Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.completed ? Colors.grey.shade500 : null,
                      ),
                    ),
                    Text(
                      task.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow to show it's tappable
              if (!task.completed)
                Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
              if (task.completed)
                Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  // ── Syllabus Grid Card ────────────────────────────────────
  Widget _buildSyllabusCard(BuildContext context, SyllabusTopic topic) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: topic.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: topic.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(topic.icon, style: const TextStyle(fontSize: 22)),
              const Spacer(),
              Text(
                '${topic.completedLessons}/${topic.totalLessons}',
                style: TextStyle(
                  fontSize: 12,
                  color: topic.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            topic.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: topic.progress,
              minHeight: 7,
              backgroundColor: topic.color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(topic.color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(topic.progress * 100).toInt()}% complete',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ── Study Channel Card ────────────────────────────────────
  Widget _buildChannelCard(BuildContext context, StudyChannel channel, int rank) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(channel.channelUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank + Avatar
              Column(
                children: [
                  // Rank badge
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: rank <= 3 ? Colors.amber : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: rank <= 3 ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Channel avatar
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: channel.avatarColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(channel.avatarEmoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Channel info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            channel.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        // Subscribers
                        Row(
                          children: [
                            Icon(Icons.people, size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 3),
                            Text(
                              channel.subscribers,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Specialty badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: channel.avatarColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        channel.specialty,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: channel.avatarColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      channel.description,
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: channel.tags.map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(tag, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Open button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.open_in_new, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
