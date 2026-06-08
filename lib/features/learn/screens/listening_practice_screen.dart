import 'dart:async';
import 'dart:math';
import 'dart:js' as js;
import 'package:flutter/material.dart';

class ListeningQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const ListeningQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class ListeningPractice {
  final String title;
  final String trackName;
  final String description;
  final int durationSeconds;
  final List<ListeningQuestion> questions;
  final String transcript;
  final String examType;

  const ListeningPractice({
    required this.title,
    required this.trackName,
    required this.description,
    required this.durationSeconds,
    required this.questions,
    required this.transcript,
    required this.examType,
  });
}

class ListeningData {
  static ListeningPractice getPractice(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return const ListeningPractice(
          examType: 'IELTS',
          title: 'Section 3: University Coursework Discussion',
          trackName: 'Audio Track 12: Renewable Energy Project Discussion',
          description: 'Listen to university students Sarah and James discussing their research paper on solar panel efficiency with their academic advisor, Dr. Green.',
          durationSeconds: 90,
          questions: [
            ListeningQuestion(
              question: 'What is Sarah\'s primary concern about the current solar panel models?',
              options: [
                'The high manufacturing cost',
                'Their reduced efficiency in low-light conditions',
                'Lack of durability in extreme weather',
                'Their weight and installation difficulty'
              ],
              correctIndex: 1,
            ),
            ListeningQuestion(
              question: 'James suggests that their research focus should shift to which region?',
              options: [
                'Northern Europe',
                'North Africa',
                'Southeast Asia',
                'South America'
              ],
              correctIndex: 0,
            ),
            ListeningQuestion(
              question: 'Dr. Green advises the students to submit their initial draft by when?',
              options: [
                'By this Friday afternoon',
                'By next Monday at noon',
                'By the end of the month',
                'In exactly two weeks'
              ],
              correctIndex: 1,
            ),
            ListeningQuestion(
              question: 'What additional resource does Dr. Green recommend they consult?',
              options: [
                'A standard university physics textbook',
                'The online university publication database',
                'A recent industry journal article on photovoltaics',
                'A series of video lectures on renewable energy'
              ],
              correctIndex: 2,
            ),
          ],
          transcript: '''
[Audio Transcript]

Sarah: Thanks for meeting with us, Dr. Green. We wanted to discuss our research project on solar panels. 

Dr. Green: Of course, Sarah. How is the progress?

Sarah: Well, we've reviewed the current models. My primary concern isn't really the cost of manufacturing anymore, but rather their efficiency under low-light conditions. During winter months in colder regions, their power generation drops off far too drastically.

James: Yes, and that's why I think we should shift our focus. Instead of general global applications, we should specifically research solutions optimized for Northern Europe, where winter daylight is extremely scarce. 

Dr. Green: That makes a lot of sense, James. Focusing on a specific geographic region with high solar constraints will give your paper a strong academic edge. Now, when do you plan to have a draft ready?

Sarah: We were aiming for the end of the month.

Dr. Green: I think that might be pushing it too close to final exams. Let's aim for next Monday at noon. That way, I can review it and give you feedback with plenty of time for revisions. 

James: We can definitely make next Monday. Are there any other sources we should look into?

Dr. Green: Yes, you should check the latest issue of the Photovoltaics International Journal. There's a brilliant industry article on organic photovoltaic cells that covers exactly the low-light issues you're researching. Avoid relying just on the standard university databases, as this article is very recent.

Sarah: Perfect. We'll find that article and integrate it. Thanks, Dr. Green!
''',
        );
      case 'GRE':
        return const ListeningPractice(
          examType: 'GRE',
          title: 'Verbal Audio: Rhetorical Analysis',
          trackName: 'Audio Track 04: The Paradox of Expertise Seminar',
          description: 'Listen to a short seminar extract analyzing the cognitive limits of domain experts and how cognitive schemas impede novel problem solving.',
          durationSeconds: 75,
          questions: [
            ListeningQuestion(
              question: 'According to the speaker, what constitutes the "curse of knowledge" for experts?',
              options: [
                'Forgetting basic principles due to complex ideas',
                'Struggling to teach concepts to novices',
                'Being unable to solve problems that novices resolve easily due to rigid mental schemas',
                'Experiencing cognitive fatigue earlier than non-experts'
              ],
              correctIndex: 2,
            ),
            ListeningQuestion(
              question: 'What happens when a chess grandmaster is presented with randomly placed pieces?',
              options: [
                'Their recall advantage disappears because the random configuration cannot be integrated into existing schemas',
                'They perform slightly better than novices due to superior general memory',
                'They reject the task as being mathematically impossible',
                'They reconstruct the board into a legal position automatically'
              ],
              correctIndex: 0,
            ),
            ListeningQuestion(
              question: 'What attitude does the speaker recommend experts should cultivate?',
              options: [
                'Doubt in their own calculations',
                'A "beginner\'s mind" to look at problems with fresh eyes',
                'Continuous memorization of unrelated domains',
                'A reliance on surface-level visual features'
              ],
              correctIndex: 1,
            ),
          ],
          transcript: '''
[Audio Transcript]

Speaker: Today, we examine the paradox of expertise. While specialized training creates highly integrated mental schemas that allow experts to solve complex domain-specific problems instantly, it simultaneously introduces a cognitive liability. This liability is sometimes called the "curse of knowledge."

Essentially, when an expert faces a problem that requires departing from established, rigid frameworks, they often struggle. For instance, in memory tasks, a chess grandmaster can easily recall the positions of pieces on a standard, meaningful game board because they fit into known play schemas. However, if the pieces are scattered randomly across the board, the grandmaster's recall advantage over a novice almost entirely disappears. The random layout cannot be integrated into their pre-existing structured schemas.

The takeaway here is that high-level problem-solving requires us to occasionally abandon our learned frameworks. We must deliberately cultivate what Zen practitioners call the "beginner's mind"—the ability to set aside expertise and perceive a problem with fresh, unclouded eyes.
''',
        );
      case 'GMAT':
      default:
        return const ListeningPractice(
          examType: 'GMAT',
          title: 'Critical Reasoning Audio: Business Case Analysis',
          trackName: 'Audio Track 09: Omega Retail Renovation Analysis',
          description: 'Listen to a corporate consultant briefing on the logical flaws behind Omega Retail\'s proposed store renovation plan.',
          durationSeconds: 80,
          questions: [
            ListeningQuestion(
              question: 'Why does the consultant criticize Omega Retail\'s plan to renovate all stores?',
              options: [
                'Renovation costs are currently at an all-time high',
                'It assumes correlation implies causation regarding their competitor Apex Retail\'s success',
                'The competitor\'s stores are located in different countries',
                'Customer surveys indicate they prefer older store layouts'
              ],
              correctIndex: 1,
            ),
            ListeningQuestion(
              question: 'How is Omega Retail planning to fund the store renovations?',
              options: [
                'By issuing new corporate bonds',
                'By cutting their marketing budget',
                'By raising the prices of their high-margin items',
                'By laying off mid-level store managers'
              ],
              correctIndex: 1,
            ),
            ListeningQuestion(
              question: 'What is the consultant\'s final recommendation regarding strategic decisions?',
              options: [
                'Proceed immediately before competitors copy them',
                'Cut the marketing budget even further to save capital',
                'Evaluate options like selective acquisitions or target partnerships instead of a blanket renovation',
                'Hire a new board of directors'
              ],
              correctIndex: 2,
            ),
          ],
          transcript: '''
[Audio Transcript]

Consultant: Let's analyze the latest proposal by the board of Omega Retail. The board wants to renovate all retail stores in response to competitor Apex Retail's recent renovation, which was immediately followed by a thirty percent increase in sales.

The board's line of reasoning is fundamentally flawed. They assume that because Apex renovated and saw sales growth, the renovation directly caused the growth. This is a classic logical fallacy: correlation does not prove causation. Apex might have run a massive promotional campaign, or opened in new high-income locations, or benefitted from competitor closures.

Furthermore, Omega plans to fund this massive project by cutting its marketing budget. This is highly risky. Cutting marketing to fund physical renovations could severely reduce foot traffic, negating any benefits of the updated aesthetics. 

Instead of a blanket, high-cost renovation across all locations, I recommend a more measured approach. Omega should consider targeted partnerships, selective acquisitions, or testing the renovation model in a single pilot location before committing the entire marketing budget.
''',
        );
    }
  }
}

class ListeningPracticeScreen extends StatefulWidget {
  final String examType;
  const ListeningPracticeScreen({super.key, required this.examType});

  @override
  State<ListeningPracticeScreen> createState() => _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  late ListeningPractice _practice;
  final Map<int, int> _answers = {};
  bool _submitted = false;
  bool _showTranscript = false;

  // Audio simulation state
  bool _isPlaying = false;
  double _currentTimeDouble = 0.0;
  double _playbackSpeed = 1.0;
  Timer? _playerTimer;

  @override
  void initState() {
    super.initState();
    _practice = ListeningData.getPractice(widget.examType);
    _injectSpeechJS();
  }

  void _injectSpeechJS() {
    try {
      js.context.callMethod('eval', ["""
        window.speakText = function(text, rate) {
          window.stopSpeaking();
          if (!window.speechSynthesis) return;
          
          var cleanText = text.replace(/\\s+/g, ' ');
          var sentences = cleanText.split(/[.!?]+/);
          
          var getVoice = function() {
            var voices = window.speechSynthesis.getVoices();
            return voices.find(function(v) { 
              return v.lang.indexOf('en') === 0; 
            }) || voices[0];
          };
          
          var englishVoice = getVoice();
          
          sentences.forEach(function(sentence) {
            var trimmed = sentence.trim();
            if (trimmed.length === 0) return;
            
            var utterance = new SpeechSynthesisUtterance(trimmed + '.');
            utterance.rate = rate || 1.0;
            utterance.lang = 'en-US';
            if (englishVoice) {
              utterance.voice = englishVoice;
            }
            window.speechSynthesis.speak(utterance);
          });
        };
        window.stopSpeaking = function() {
          if (window.speechSynthesis) window.speechSynthesis.cancel();
        };
        window.pauseSpeaking = function() {
          if (window.speechSynthesis) window.speechSynthesis.pause();
        };
        window.resumeSpeaking = function() {
          if (window.speechSynthesis) window.speechSynthesis.resume();
        };
      """]);
    } catch (e) {
      print("Listening speech JS injection error: \$e");
    }
  }

  @override
  void dispose() {
    _playerTimer?.cancel();
    js.context.callMethod('stopSpeaking');
    super.dispose();
  }

  int get _score =>
      _answers.entries.where((e) => e.value == _practice.questions[e.key].correctIndex).length;

  int get _currentTime => _currentTimeDouble.toInt();

  void _togglePlay() {
    if (_isPlaying) {
      _pause();
    } else {
      _play();
    }
  }

  void _startSpeechAtCurrentTime() {
    js.context.callMethod('stopSpeaking');
    final cleanText = _practice.transcript.replaceAll('[Audio Transcript]', '').trim();
    final words = cleanText.split(RegExp(r'\s+'));
    final progress = _currentTimeDouble / _practice.durationSeconds;
    final startIndex = (words.length * progress).toInt().clamp(0, words.length - 1);
    final textToSpeak = words.sublist(startIndex).join(' ');
    if (textToSpeak.isNotEmpty) {
      js.context.callMethod('speakText', [textToSpeak, _playbackSpeed]);
    }
  }

  void _play() {
    setState(() => _isPlaying = true);
    if (_currentTimeDouble == 0.0) {
      _startSpeechAtCurrentTime();
    } else {
      js.context.callMethod('resumeSpeaking');
    }
    _playerTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentTimeDouble += 0.1 * _playbackSpeed;
        if (_currentTimeDouble >= _practice.durationSeconds) {
          _currentTimeDouble = _practice.durationSeconds.toDouble();
          _isPlaying = false;
          _playerTimer?.cancel();
          js.context.callMethod('stopSpeaking');
        }
      });
    });
  }

  void _pause() {
    setState(() => _isPlaying = false);
    _playerTimer?.cancel();
    js.context.callMethod('pauseSpeaking');
  }

  void _seekForward() {
    setState(() {
      _currentTimeDouble = min(
        _practice.durationSeconds.toDouble(),
        _currentTimeDouble + 10.0,
      );
    });
    if (_isPlaying) {
      _startSpeechAtCurrentTime();
    }
  }

  void _seekBackward() {
    setState(() {
      _currentTimeDouble = max(0.0, _currentTimeDouble - 10.0);
    });
    if (_isPlaying) {
      _startSpeechAtCurrentTime();
    }
  }

  void _changeSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    if (_isPlaying) {
      _startSpeechAtCurrentTime();
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIELTS = widget.examType.toUpperCase() == 'IELTS';

    return Scaffold(
      appBar: AppBar(
        title: Text('Listening – ${widget.examType}'),
        actions: [
          if (!_submitted)
            TextButton(
              onPressed: _answers.length == _practice.questions.length
                  ? () => setState(() => _submitted = true)
                  : null,
              child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_submitted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _score == _practice.questions.length
                  ? Colors.green.shade100
                  : _score >= 2
                      ? Colors.orange.shade100
                      : Colors.red.shade100,
              child: Text(
                'Score: $_score / ${_practice.questions.length}  ${_score == _practice.questions.length ? "🎉 Perfect Score!" : _score >= 2 ? "👍 Good job!" : "📖 Read the transcript to review!"}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _practice.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _practice.description,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),

                  // ─── Premium Simulated Audio Player ───
                  _buildAudioPlayer(theme),
                  const SizedBox(height: 28),

                  // Questions Header
                  Text(
                    'Practice Questions',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ..._practice.questions.asMap().entries.map((entry) {
                    final qi = entry.key;
                    final q = entry.value;
                    return _buildQuestion(context, qi, q);
                  }),

                  if (!_submitted && _answers.length == _practice.questions.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: () => setState(() => _submitted = true),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Submit Answers', style: TextStyle(fontSize: 16)),
                      ),
                    ),

                  // ─── Interactive Transcript Section ───
                  if (_submitted) ...[
                    const SizedBox(height: 20),
                    _buildTranscriptCard(theme),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(ThemeData theme) {
    final duration = _practice.durationSeconds;
    final progress = _currentTimeDouble / duration;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F2027),
            const Color(0xFF203A43),
            const Color(0xFF2C5364),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones, color: Colors.cyanAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _practice.trackName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'High Quality Exam Prep Audio',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Playback speed indicator
              PopupMenuButton<double>(
                initialValue: _playbackSpeed,
                onSelected: _changeSpeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Waveform visualization
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(24, (index) {
                // Generate simulated wave heights
                double heightFactor = 0.2 + (sin((index + _currentTimeDouble * 4) * 0.8) * 0.4).abs();
                if (!_isPlaying) heightFactor = 0.15 + (sin(index * 0.5) * 0.1).abs();
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 4,
                  height: 48 * heightFactor,
                  decoration: BoxDecoration(
                    color: _isPlaying
                        ? Colors.cyanAccent.withOpacity(0.3 + (heightFactor * 0.7))
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Slider scrubber
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.cyanAccent,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.cyanAccent,
              overlayColor: Colors.cyanAccent.withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: progress,
              onChanged: (val) {
                setState(() {
                  _currentTimeDouble = val * duration;
                });
              },
              onChangeEnd: (val) {
                if (_isPlaying) {
                  _startSpeechAtCurrentTime();
                }
              },
            ),
          ),

          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentTime),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
                onPressed: _seekBackward,
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.cyanAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: const Color(0xFF0F2027),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
                onPressed: _seekForward,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, int qi, ListeningQuestion q) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${qi + 1}. ${q.question}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          ...q.options.asMap().entries.map((opt) {
            final oi = opt.key;
            final label = opt.value;
            Color? bgColor;
            Color? borderColor;
            if (_submitted) {
              if (oi == q.correctIndex) {
                bgColor = Colors.green.shade100;
                borderColor = Colors.green;
              } else if (_answers[qi] == oi && oi != q.correctIndex) {
                bgColor = Colors.red.shade100;
                borderColor = Colors.red;
              }
            } else if (_answers[qi] == oi) {
              bgColor = theme.colorScheme.primaryContainer;
              borderColor = theme.colorScheme.primary;
            }
            return GestureDetector(
              onTap: _submitted ? null : () => setState(() => _answers[qi] = oi),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor ?? theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor ?? Colors.transparent, width: 1.5),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: borderColor ?? Colors.grey.shade300,
                      child: Text(
                        String.fromCharCode(65 + oi),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: borderColor != null ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
                    if (_submitted && oi == q.correctIndex)
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    if (_submitted && _answers[qi] == oi && oi != q.correctIndex)
                      const Icon(Icons.cancel, color: Colors.red, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTranscriptCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              '📝 Show Audio Transcript',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            trailing: Icon(
              _showTranscript ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onTap: () => setState(() => _showTranscript = !_showTranscript),
          ),
          if (_showTranscript)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                _practice.transcript.trim(),
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
