import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/user_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/youtube_service.dart';

class SyllabusScreen extends ConsumerWidget {
  const SyllabusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState is Authenticated ? authState.user : null;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final examType = user.examType.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('$examType Syllabus'),
        centerTitle: true,
      ),
      body: _buildSyllabus(context, theme, user),
    );
  }

  Widget _buildSyllabus(BuildContext context, ThemeData theme, SmartGoUser user) {
    final examType = user.examType.toUpperCase();
    List<Map<String, dynamic>> sections = [];

    switch (examType) {
      case 'IELTS':
        sections = [
          {
            'title': 'Listening (30 minutes)',
            'items': [
              'Section 1: Conversation between two people in everyday social context',
              'Section 2: Monologue set in an everyday social context',
              'Section 3: Conversation between up to four people set in educational context',
              'Section 4: Monologue on an academic subject',
            ]
          },
          {
            'title': 'Reading (60 minutes)',
            'items': [
              'Academic: 3 long texts (descriptive, factual, analytical)',
              'General: Extracts from books, magazines, notices, guidelines',
            ]
          },
          {
            'title': 'Writing (60 minutes)',
            'items': [
              'Task 1 (Academic): Describe graph, table, chart or diagram',
              'Task 1 (General): Write a letter requesting info/explaining situation',
              'Task 2: Write an essay in response to a point of view',
            ]
          },
          {
            'title': 'Speaking (11-14 minutes)',
            'items': [
              'Part 1: Introduction and interview on familiar topics',
              'Part 2: Long turn (speak for 2 minutes on a given topic)',
              'Part 3: Two-way discussion (abstract issues linked to Part 2)',
            ]
          },
        ];
        break;
      case 'GRE':
        sections = [
          {
            'title': 'Analytical Writing (30 minutes)',
            'items': [
              'Analyze an Issue task',
              'Articulate clear and complex ideas, support with evidence',
            ]
          },
          {
            'title': 'Verbal Reasoning',
            'items': [
              'Reading Comprehension: Analyze and synthesize info',
              'Text Completion: Use context clues to complete sentences',
              'Sentence Equivalence: Select two words meaning the same thing',
            ]
          },
          {
            'title': 'Quantitative Reasoning',
            'items': [
              'Arithmetic: Number properties, percentages, ratios',
              'Algebra: Algebraic expressions, equations, inequalities',
              'Geometry: Lines, circles, triangles, 3D figures',
              'Data Analysis: Statistics, probability, data interpretation',
            ]
          },
        ];
        break;
      case 'GMAT':
        sections = [
          {
            'title': 'Quantitative Reasoning',
            'items': [
              'Problem Solving: Basic math skills and reasoning',
            ]
          },
          {
            'title': 'Verbal Reasoning',
            'items': [
              'Reading Comprehension: Logical relationships, draw inferences',
              'Critical Reasoning: Evaluate arguments, formulate action plans',
            ]
          },
          {
            'title': 'Data Insights',
            'items': [
              'Data Sufficiency: Determine if data is sufficient',
              'Multi-Source Reasoning: Examine data from multiple sources',
              'Table Analysis: Sort and analyze tables',
              'Graphics Interpretation: Interpret graphs',
              'Two-Part Analysis: Solve complex problems',
            ]
          },
        ];
        break;
      default:
        return Center(child: Text('Syllabus not available for $examType'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        return _buildSectionCard(theme, user, sections[index]);
      },
    );
  }

  Widget _buildSectionCard(ThemeData theme, SmartGoUser user, Map<String, dynamic> section) {
    final items = section['items'] as List<String>;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section['title'],
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => SyllabusTopicTile(user: user, topic: item)),
          ],
        ),
      ),
    );
  }
}

class SyllabusTopicTile extends StatefulWidget {
  final SmartGoUser user;
  final String topic;

  const SyllabusTopicTile({super.key, required this.user, required this.topic});

  @override
  State<SyllabusTopicTile> createState() => _SyllabusTopicTileState();
}

class _SyllabusTopicTileState extends State<SyllabusTopicTile> {
  bool _isExpanded = false;
  YouTubeVideo? _video;
  bool _isLoadingVideo = false;
  final TextEditingController _customSearchController = TextEditingController();

  bool get isCompleted => widget.user.completedSyllabusTopics.contains(widget.topic);

  Future<void> _toggleCompletion() async {
    final currentList = List<String>.from(widget.user.completedSyllabusTopics);
    if (isCompleted) {
      currentList.remove(widget.topic);
    } else {
      currentList.add(widget.topic);
    }
    await FirestoreService.updateUser(widget.user.uid, {
      'completedSyllabusTopics': currentList,
    });
  }

  Future<void> _loadVideo() async {
    setState(() => _isLoadingVideo = true);
    try {
      final customQuery = widget.user.customSyllabusVideos[widget.topic];
      final query = customQuery ?? '${widget.user.examType} ${widget.topic} lesson';
      final videos = await YouTubeService.searchVideos(query, maxResults: 1);
      if (videos.isNotEmpty && mounted) {
        setState(() => _video = videos.first);
      }
    } catch (e) {
      debugPrint('Error loading video: \$e');
    } finally {
      if (mounted) setState(() => _isLoadingVideo = false);
    }
  }

  Future<void> _saveCustomSearch() async {
    final query = _customSearchController.text.trim();
    if (query.isEmpty) return;

    final updatedMap = Map<String, String>.from(widget.user.customSyllabusVideos);
    updatedMap[widget.topic] = query;

    await FirestoreService.updateUser(widget.user.uid, {
      'customSyllabusVideos': updatedMap,
    });

    // Reload video with new search
    _loadVideo();
  }

  Future<void> _launchVideo() async {
    if (_video == null) return;
    final url = Uri.parse('https://www.youtube.com/watch?v=\${_video!.videoId}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Checkbox(
            value: isCompleted,
            onChanged: (val) => _toggleCompletion(),
            activeColor: Colors.green,
            shape: const CircleBorder(),
          ),
          title: Text(
            widget.topic,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? Colors.grey : null,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.ondemand_video,
              color: _isExpanded ? theme.colorScheme.primary : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded && _video == null) {
                  _loadVideo();
                }
              });
            },
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 48.0, right: 16.0, bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoadingVideo)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_video != null)
                  InkWell(
                    onTap: _launchVideo,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Image.network(
                              _video!.thumbnailUrl,
                              width: 100,
                              height: 75,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _video!.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _video!.channelTitle,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.play_circle_fill, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Text('No video found.'),
                
                const SizedBox(height: 12),
                
                // Custom Search input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customSearchController,
                        decoration: InputDecoration(
                          hintText: 'Prefer a specific channel? (e.g. "E2 IELTS")',
                          hintStyle: const TextStyle(fontSize: 12),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveCustomSearch,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 36),
                      ),
                      child: const Text('Search', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
