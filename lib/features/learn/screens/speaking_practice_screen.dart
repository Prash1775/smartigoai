import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import '../../../services/gemini_service.dart';

class SpeakingPrompt {
  final String taskType;
  final String title;
  final String prompt;
  final String tips;
  final int recommendedSeconds;

  const SpeakingPrompt({
    required this.taskType,
    required this.title,
    required this.prompt,
    required this.tips,
    required this.recommendedSeconds,
  });
}

class SpeakingData {
  static SpeakingPrompt getPrompt(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return const SpeakingPrompt(
          taskType: 'IELTS Speaking Part 2',
          title: 'Cue Card: Describing a Useful Book',
          prompt: 'Describe a book you read recently that you found useful.\n\nYou should say:\n• What the book is\n• When you read it\n• What it is about\n• And explain why you found it useful.',
          tips: '✅ Take 1 minute to plan. Note down key keywords.\n✅ Structure: Introduction -> 4 prompt points -> Conclusion.\n✅ Speak continuously for 1 to 2 minutes.\n✅ Use advanced transition markers (e.g., "Furthermore", "With regard to", "Consequent to this").\n✅ Show lexical resource: use words like "instrumental", "compelling", "insightful".',
          recommendedSeconds: 120,
        );
      case 'GRE':
        return const SpeakingPrompt(
          taskType: 'GRE Verbal Speech Prep',
          title: 'Oral Issue Argument Practice',
          prompt: 'Discuss the extent to which you agree or disagree with the statement: "Schools should place equal educational funding on athletics as they do on academic departments."\n\nExplain your reasoning and provide relevant examples to support your view.',
          tips: '✅ Take a clear stance in the first 15 seconds.\n✅ Develop two distinct arguments: one athletic, one academic.\n✅ Address the counterargument (refutation).\n✅ Focus on absolute clarity of logical reasoning.\n✅ Speak for approximately 2 minutes.',
          recommendedSeconds: 120,
        );
      case 'GMAT':
      default:
        return const SpeakingPrompt(
          taskType: 'GMAT Case Presentation Prep',
          title: 'Oral Analysis of a Business Case',
          prompt: 'A local organic grocery store decides to open a gourmet sandwich bar to increase profits. Speak for 2 minutes analyzing the business assumptions of this decision, particularly regarding operational costs and customer demographic overlap.',
          tips: '✅ Focus on the core economic variables: fixed cost, variable cost, customer target.\n✅ Point out the risk of cannibalization of raw grocery sales by pre-made sandwiches.\n✅ Present your thoughts as a professional business brief.\n✅ Speak at a steady, formal pace.',
          recommendedSeconds: 120,
        );
    }
  }
}

class SpeakingPracticeScreen extends StatefulWidget {
  final String examType;
  const SpeakingPracticeScreen({super.key, required this.examType});

  @override
  State<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends State<SpeakingPracticeScreen> {
  late SpeakingPrompt _prompt;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _showReport = false;
  int _secondsRecorded = 0;
  Timer? _recordingTimer;
  final List<double> _waveHeights = List.filled(30, 0.15);
  Timer? _waveTimer;

  // Real-time transcribed text
  String _recordedText = '';
  String _analysisStatus = 'Evaluating Speech Patterns...';

  // Feedback parameters
  late double _overallScore;
  late double _fluencyScore;
  late double _lexicalScore;
  late double _grammarScore;
  late double _pronScore;
  late String _transcript;
  late List<Map<String, String>> _grammarCorrections;
  late List<Map<String, String>> _vocabularyUpgrades;
  bool _isUsingOfflineBackup = false;

  @override
  void initState() {
    super.initState();
    _prompt = SpeakingData.getPrompt(widget.examType);
    _initSimulatedFeedback();
    _injectSpeechJS();
  }

  void _injectSpeechJS() {
    try {
      js.context.callMethod('eval', ["""
        var recognition;
        var finalTranscript = '';
        window.startSpeechRecognition = function(onResult, onError, onEnd) {
          window.stopSpeechRecognition();
          var SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
          if (!SpeechRecognition) {
            if (onError) onError("Speech recognition not supported");
            return;
          }
          recognition = new SpeechRecognition();
          recognition.continuous = true;
          recognition.interimResults = true;
          recognition.lang = 'en-US';
          finalTranscript = '';
          
          recognition.onresult = function(event) {
            var interimTranscript = '';
            for (var i = event.resultIndex; i < event.results.length; ++i) {
              if (event.results[i].isFinal) {
                finalTranscript += event.results[i][0].transcript + ' ';
              } else {
                interimTranscript += event.results[i][0].transcript;
              }
            }
            if (onResult) {
              onResult(finalTranscript + interimTranscript);
            }
          };
          
          recognition.onerror = function(event) {
            if (onError) onError(event.error);
          };
          recognition.onend = function() {
            if (onEnd) onEnd();
          };
          recognition.start();
        };
        window.stopSpeechRecognition = function() {
          if (recognition) {
            recognition.stop();
            recognition = null;
          }
        };
      """]);
    } catch (e) {
      print("Speaking speech JS injection error: \$e");
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _waveTimer?.cancel();
    js.context.callMethod('stopSpeechRecognition');
    super.dispose();
  }

  void _initSimulatedFeedback() {
    // Fill in realistic feedback based on exam type
    if (widget.examType.toUpperCase() == 'IELTS') {
      _overallScore = 7.5;
      _fluencyScore = 7.5;
      _lexicalScore = 8.0;
      _grammarScore = 7.0;
      _pronScore = 7.5;
      _transcript = 'I would like to talk about a book called "Atomic Habits" which I have read about three months ago... It was extremely useful because it details how small changes, daily modifications can lead to remarkable results. I found it very instrumental in sorting my day planning and study schedule...';
      _grammarCorrections = [
        {'original': 'which I have read about three months ago', 'corrected': 'which I read about three months ago', 'reason': 'Use simple past instead of present perfect with specific past time markers ("three months ago").'},
        {'original': 'sorting my day planning', 'corrected': 'organizing my daily planning', 'reason': 'Better collocation and word choice.'},
      ];
      _vocabularyUpgrades = [
        {'original': 'very useful', 'upgrade': 'highly instrumental / invaluable'},
        {'original': 'small changes', 'upgrade': 'incremental adjustments'},
        {'original': 'remarkable results', 'upgrade': 'profound outcomes'},
      ];
    } else {
      _overallScore = 82.0;
      _fluencyScore = 80.0;
      _lexicalScore = 85.0;
      _grammarScore = 84.0;
      _pronScore = 80.0;
      _transcript = 'In analyzing the proposal, we must look at the key economic variables. Allocating matching budgets to sports departments assumes that athletics yields an equal return in student satisfaction and university brand prestige... However, cutting academic funding might compromise the core educational quality...';
      _grammarCorrections = [
        {'original': 'In analyzing the proposal, we must look', 'corrected': 'To analyze the proposal, we must evaluate', 'reason': 'More formal research presentation tone.'},
        {'original': 'brand prestige... However, cutting', 'corrected': 'brand prestige; however, reducing', 'reason': 'Smoother sentence transition.'},
      ];
      _vocabularyUpgrades = [
        {'original': 'look at', 'upgrade': 'evaluate / examine'},
        {'original': 'matching budgets', 'upgrade': 'commensurate financial resources'},
        {'original': 'cutting academic funding', 'upgrade': 'diluting academic resources'},
      ];
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _secondsRecorded = 0;
      _showReport = false;
      _recordedText = '';
    });

    // Start Web Speech Recognition via index.html helpers
    js.context.callMethod('startSpeechRecognition', [
      js.allowInterop((String text) {
        setState(() {
          _recordedText = text;
        });
      }),
      js.allowInterop((String error) {
        print("Speech recognition error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎙️ Microphone/Speech Error: $error (Make sure you allow mic access)')),
        );
      }),
      js.allowInterop(() {
        print("Speech recognition ended");
      }),
    ]);

    // Recording timer
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRecorded++;
        if (_secondsRecorded >= _prompt.recommendedSeconds) {
          _stopRecordingAndAnalyze();
        }
      });
    });

    // Waveform animation timer
    final random = Random();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      setState(() {
        for (int i = 0; i < _waveHeights.length; i++) {
          _waveHeights[i] = 0.15 + random.nextDouble() * 0.75;
        }
      });
    });
  }

  Future<void> _stopRecordingAndAnalyze() async {
    _recordingTimer?.cancel();
    _waveTimer?.cancel();
    js.context.callMethod('stopSpeechRecognition');

    setState(() {
      _isRecording = false;
    });

    final spokenText = _recordedText.trim();
    if (spokenText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No speech detected. Please speak into your microphone and try again!')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisStatus = 'Connecting to Gemini AI...';
    });

    try {
      setState(() {
        _analysisStatus = 'Analyzing pronunciation, vocabulary, and grammar...';
      });

      final prompt = '''
You are an expert ${widget.examType} Speaking Examiner and English language coach.

The suggested speaking topic for this session was:
"${_prompt.prompt}"

HOWEVER, the student may have spoken about a completely different topic. That is okay.
Your job is to evaluate the ENGLISH LANGUAGE QUALITY of whatever the student actually said — NOT whether they followed the suggested topic.

The student's raw transcribed speech (as recorded by speech recognition) is:
"$spokenText"

IMPORTANT INSTRUCTIONS:
- Evaluate only the student's English: fluency, grammar, vocabulary, and pronunciation.
- The transcript field should contain a cleaned-up, properly punctuated version of WHAT THE STUDENT ACTUALLY SAID.
- Grammar corrections should fix actual grammar issues in what the student said.
- Vocabulary upgrades should suggest advanced alternatives for simple words the student used.
- Do NOT penalize the student for not following the suggested topic.
- Scores should be on a scale of 1.0 to 9.0 for IELTS, or 0 to 100 for GMAT/GRE.

Return only a single raw JSON object (no markdown, no backticks) with this exact structure:
{
  "overallScore": 7.5,
  "fluencyScore": 7.0,
  "lexicalScore": 8.0,
  "grammarScore": 7.5,
  "pronScore": 7.5,
  "transcript": "Cleaned up and punctuated version of what the student actually said...",
  "grammarCorrections": [
    {
      "original": "incorrect fragment spoken by student",
      "corrected": "corrected version",
      "reason": "explanation"
    }
  ],
  "vocabularyUpgrades": [
    {
      "original": "simple word used",
      "upgrade": "advanced alternative"
    }
  ]
}
''';

      final responseText = await GeminiService().generateFromPrompt(
        prompt,
        temperature: 0.5,
        maxTokens: 6000,
        responseMimeType: 'application/json',
      );

      // Clean up markdown block if present
      String jsonString = responseText.trim();
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.replaceFirst(RegExp(r'^```(?:json)?'), '');
        jsonString = jsonString.replaceFirst(RegExp(r'```$'), '');
        jsonString = jsonString.trim();
      }
      final firstBrace = jsonString.indexOf('{');
      final lastBrace = jsonString.lastIndexOf('}');
      if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
        jsonString = jsonString.substring(firstBrace, lastBrace + 1);
      }

      final Map<String, dynamic> data = jsonDecode(jsonString);

      setState(() {
        _isUsingOfflineBackup = false;

        double parseDouble(dynamic val, double fallback) {
          if (val == null) return fallback;
          if (val is num) return val.toDouble();
          if (val is String) {
            return double.tryParse(val) ?? fallback;
          }
          return fallback;
        }

        _overallScore = parseDouble(data['overallScore'], 6.5);
        _fluencyScore = parseDouble(data['fluencyScore'], 6.5);
        _lexicalScore = parseDouble(data['lexicalScore'], 6.5);
        _grammarScore = parseDouble(data['grammarScore'], 6.5);
        _pronScore = parseDouble(data['pronScore'], 6.5);
        _transcript = data['transcript']?.toString() ?? spokenText;
        
        _grammarCorrections = [];
        if (data['grammarCorrections'] is List) {
          for (var item in data['grammarCorrections']) {
            if (item is Map) {
              _grammarCorrections.add({
                'original': (item['original'] ?? '').toString(),
                'corrected': (item['corrected'] ?? '').toString(),
                'reason': (item['reason'] ?? '').toString(),
              });
            }
          }
        }

        _vocabularyUpgrades = [];
        if (data['vocabularyUpgrades'] is List) {
          for (var item in data['vocabularyUpgrades']) {
            if (item is Map) {
              _vocabularyUpgrades.add({
                'original': (item['original'] ?? '').toString(),
                'upgrade': (item['upgrade'] ?? item['corrected'] ?? '').toString(),
              });
            }
          }
        }
        _isAnalyzing = false;
        _showReport = true;
      });

    } catch (e) {
      print("Gemini speech evaluation failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ AI API offline: $e. Performing local structural analysis.')),
      );
      setState(() {
        _generateLocalFeedback(spokenText);
        _isAnalyzing = false;
        _showReport = true;
      });
    }
  }

  void _generateLocalFeedback(String spokenText) {
    _isUsingOfflineBackup = true;
    final lowerText = spokenText.toLowerCase();
    final words = spokenText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final wordCount = words.length;

    double baseScore = 6.0;
    if (wordCount > 10) baseScore = 6.5;
    if (wordCount > 30) baseScore = 7.0;
    if (wordCount > 60) baseScore = 7.5;
    if (wordCount > 100) baseScore = 8.0;
    
    final fillerMatches = RegExp(r'\b(um|uh|ah|like|so|you know)\b').allMatches(lowerText).length;
    final fillerPercentage = wordCount > 0 ? (fillerMatches / wordCount) : 0.0;
    double fluencyPenalty = fillerPercentage * 4.0;
    
    _overallScore = double.parse((baseScore - fluencyPenalty / 2).clamp(4.0, 9.0).toStringAsFixed(1));
    _fluencyScore = double.parse((baseScore - fluencyPenalty).clamp(4.0, 9.0).toStringAsFixed(1));
    _lexicalScore = double.parse((baseScore + (wordCount > 70 ? 0.5 : 0.0)).clamp(4.0, 9.0).toStringAsFixed(1));
    _grammarScore = double.parse(baseScore.clamp(4.0, 9.0).toStringAsFixed(1));
    _pronScore = double.parse((baseScore - 0.2).clamp(4.0, 9.0).toStringAsFixed(1));
    
    if (widget.examType.toUpperCase() != 'IELTS') {
      _overallScore = double.parse((_overallScore * 10).clamp(40.0, 99.0).toStringAsFixed(0));
      _fluencyScore = double.parse((_fluencyScore * 10).clamp(40.0, 99.0).toStringAsFixed(0));
      _lexicalScore = double.parse((_lexicalScore * 10).clamp(40.0, 99.0).toStringAsFixed(0));
      _grammarScore = double.parse((_grammarScore * 10).clamp(40.0, 99.0).toStringAsFixed(0));
      _pronScore = double.parse((_pronScore * 10).clamp(40.0, 99.0).toStringAsFixed(0));
    }
    
    _transcript = spokenText;
    _grammarCorrections = [];
    _vocabularyUpgrades = [];
    
    final grammarRules = [
      {
        'pattern': RegExp(r'\bi is\b', caseSensitive: false),
        'corrected': 'I am',
        'reason': 'Use "am" with the first-person singular pronoun "I".'
      },
      {
        'pattern': RegExp(r'\byou is\b', caseSensitive: false),
        'corrected': 'you are',
        'reason': 'Use "are" with the second-person pronoun "you".'
      },
      {
        'pattern': RegExp(r'\b(he|she|it) are\b', caseSensitive: false),
        'corrected': r'$1 is',
        'reason': 'Use singular verb "is" with third-person singular subjects.'
      },
      {
        'pattern': RegExp(r'\b(we|they) is\b', caseSensitive: false),
        'corrected': r'$1 are',
        'reason': 'Use plural verb "are" with plural subjects.'
      },
      {
        'pattern': RegExp(r'\bhave went\b', caseSensitive: false),
        'corrected': 'have gone',
        'reason': 'The past participle of "go" is "gone", not "went".'
      },
      {
        'pattern': RegExp(r'\bmore better\b', caseSensitive: false),
        'corrected': 'better',
        'reason': 'Avoid double comparatives. "Better" is already comparative.'
      },
      {
        'pattern': RegExp(r'\bdid went\b', caseSensitive: false),
        'corrected': 'did go',
        'reason': 'Use the base form of the verb with auxiliary "did".'
      },
      {
        'pattern': RegExp(r"\b(he|she|it) don't\b", caseSensitive: false),
        'corrected': r"$1 doesn't",
        'reason': 'Use "doesn\'t" for third-person singular subjects.'
      },
      {
        'pattern': RegExp(r'\bshould of\b', caseSensitive: false),
        'corrected': 'should have',
        'reason': 'Use the modal auxiliary verb "have", not the preposition "of".'
      },
      {
        'pattern': RegExp(r'\bcould of\b', caseSensitive: false),
        'corrected': 'could have',
        'reason': 'Use the modal auxiliary verb "have", not the preposition "of".'
      },
      {
        'pattern': RegExp(r'\bcould of\b', caseSensitive: false),
        'corrected': 'could have',
        'reason': 'Use the modal auxiliary verb "have", not the preposition "of".'
      },
      {
        'pattern': RegExp(r'\bi am study\b', caseSensitive: false),
        'corrected': 'I am studying',
        'reason': 'Use present continuous form "studying" with auxiliary "am".'
      },
    ];

    for (var rule in grammarRules) {
      final pattern = rule['pattern'] as RegExp;
      if (pattern.hasMatch(spokenText)) {
        final matches = pattern.allMatches(spokenText);
        for (var match in matches) {
          final original = match.group(0)!;
          String corrected = rule['corrected'] as String;
          if (corrected.contains(r'$1')) {
            corrected = corrected.replaceAll(r'$1', match.group(1) ?? '');
          }
          if (!_grammarCorrections.any((c) => c['original'] == original)) {
            _grammarCorrections.add({
              'original': original,
              'corrected': corrected,
              'reason': rule['reason'] as String,
            });
          }
        }
      }
    }
    
    if (fillerMatches > 1) {
      _grammarCorrections.add({
        'original': 'Frequent filler words (${words.where((w) => RegExp(r'^(um|uh|ah|like)$', caseSensitive: false).hasMatch(w)).take(2).join(", ")}...)',
        'corrected': 'Pause silently or use transition words',
        'reason': 'Verbal fillers reduce fluency. Try standard markers like "specifically" or "on the other hand" instead.'
      });
    }

    final vocabUpgradesList = [
      {'pattern': RegExp(r'\bvery good\b', caseSensitive: false), 'original': 'very good', 'upgrade': 'exemplary / exceptional'},
      {'pattern': RegExp(r'\bvery bad\b', caseSensitive: false), 'original': 'very bad', 'upgrade': 'detrimental / suboptimal'},
      {'pattern': RegExp(r'\bvery useful\b', caseSensitive: false), 'original': 'very useful', 'upgrade': 'highly instrumental / invaluable'},
      {'pattern': RegExp(r'\bsmall changes\b', caseSensitive: false), 'original': 'small changes', 'upgrade': 'incremental adjustments'},
      {'pattern': RegExp(r'\bbig\b', caseSensitive: false), 'original': 'big', 'upgrade': 'substantial / significant'},
      {'pattern': RegExp(r'\bhappy\b', caseSensitive: false), 'original': 'happy', 'upgrade': 'delighted / elated'},
      {'pattern': RegExp(r'\bthink\b', caseSensitive: false), 'original': 'think', 'upgrade': 'believe / postulate / maintain'},
      {'pattern': RegExp(r'\bwant to\b', caseSensitive: false), 'original': 'want to', 'upgrade': 'aspire to / intend to'},
    ];

    for (var item in vocabUpgradesList) {
      final pattern = item['pattern'] as RegExp;
      if (pattern.hasMatch(spokenText)) {
        _vocabularyUpgrades.add({
          'original': item['original'] as String,
          'upgrade': item['upgrade'] as String,
        });
      }
    }
    
    if (_vocabularyUpgrades.isEmpty && wordCount > 0) {
      _vocabularyUpgrades.add({
        'original': 'good',
        'upgrade': 'favorable / commendable',
      });
      _vocabularyUpgrades.add({
        'original': 'get',
        'upgrade': 'acquire / obtain',
      });
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIELTS = widget.examType.toUpperCase() == 'IELTS';

    return Scaffold(
      appBar: AppBar(
        title: Text('Speaking – ${widget.examType}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _prompt.taskType,
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _prompt.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Prompt description card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Speaking Topic:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _prompt.prompt,
                    style: const TextStyle(fontSize: 15, height: 1.6, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Recording Console ───
            if (!_isAnalyzing && !_showReport) _buildRecordingConsole(theme),

            // ─── AI Analyzing Loading Indicator ───
            if (_isAnalyzing) _buildAnalyzingState(theme),

            // ─── Evaluation Report ───
            if (_showReport) _buildReportSection(theme, isIELTS),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingConsole(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _isRecording ? 'RECORDING ACTIVE' : 'PRESS RECORD TO START PRACTICE',
            style: TextStyle(
              color: _isRecording ? Colors.red.shade600 : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          // Timer display
          Text(
            _formatDuration(_secondsRecorded),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),

          // Animated waveforms during recording
          SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_waveHeights.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 3,
                  height: 48 * (_isRecording ? _waveHeights[index] : 0.08),
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red.shade600 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                );
              }),
            ),
          ),

          // Real-time transcribed text display
          if (_isRecording && _recordedText.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.hearing, size: 16, color: Colors.red.shade600),
                      const SizedBox(width: 6),
                      const Text(
                        'Live Transcription:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recordedText,
                    style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Control trigger button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRecording) ...[
                ElevatedButton.icon(
                  onPressed: _stopRecordingAndAnalyze,
                  icon: const Icon(Icons.analytics, color: Colors.white),
                  label: const Text('Stop & Analyze', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: _startRecording,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade600, Colors.red.shade800],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Start Recording',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(strokeWidth: 3),
          const SizedBox(height: 24),
          Text(
            _analysisStatus,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Analyzing syntax, fluency pauses, pronunciation accuracy, and lexical score...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(ThemeData theme, bool isIELTS) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status indicator
        if (_isUsingOfflineBackup)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Offline Analysis Active: Run the app with --dart-define=GEMINI_API_KEY=YOUR_KEY to enable live GPT-grade AI evaluations.',
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green.shade800, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✨ Advanced AI grading active powered by Gemini.',
                    style: TextStyle(color: Colors.green.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        
        // Grade card
        Container(
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
                color: theme.colorScheme.primary.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_isUsingOfflineBackup ? 'BASIC AI EVALUATION REPORT' : 'REAL-TIME AI EVALUATION REPORT', style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    Text(
                      isIELTS ? 'Overall Band Score' : 'Estimated Verbal Score',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isIELTS
                          ? '🎉 Band $_overallScore'
                          : '🏆 $_overallScore / 100',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white24,
                child: const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Subscores
        Text('Grader Sub-scores', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildSubscoreBar('Fluency & Coherence', _fluencyScore, isIELTS),
        _buildSubscoreBar('Lexical Resource', _lexicalScore, isIELTS),
        _buildSubscoreBar('Grammar Range & Accuracy', _grammarScore, isIELTS),
        _buildSubscoreBar('Pronunciation Profile', _pronScore, isIELTS),
        const SizedBox(height: 24),

        // Transcript
        Text('Speech Transcript', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '"$_transcript"',
            style: const TextStyle(fontSize: 14, height: 1.6, fontStyle: FontStyle.italic, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 24),

        // Grammar Corrections
        if (_grammarCorrections.isNotEmpty) ...[
          Text('Grammar Improvement Suggestions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._grammarCorrections.map((corr) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      const Text('You spoke:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 26, top: 4, bottom: 8),
                    child: Text(corr['original']!, style: TextStyle(color: Colors.red.shade900, decoration: TextDecoration.lineThrough, fontSize: 13)),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      const Text('Correction:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 26, top: 4, bottom: 8),
                    child: Text(corr['corrected']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.only(left: 26, top: 8),
                    child: Text('💡 ${corr['reason']}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.4)),
                  ),
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: 24),

        // Vocabulary upgrades
        Text('Lexical Upgrades (Get higher band score)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DataTable(
            columnSpacing: 16,
            headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceContainerHighest),
            columns: const [
              DataColumn(label: Text('Common Word', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Premium Upgrade', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: _vocabularyUpgrades.map((voc) {
              return DataRow(
                cells: [
                  DataCell(Text(voc['original']!)),
                  DataCell(Text(voc['upgrade']!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Retry option
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _showReport = false;
              _secondsRecorded = 0;
            });
          },
          icon: const Icon(Icons.replay),
          label: const Text('Practice Again'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscoreBar(String category, double score, bool isIELTS) {
    // IELTS scores are between 1 and 9. GRE/GMAT scores between 1 and 100.
    final double maxScore = isIELTS ? 9.0 : 100.0;
    final double percent = score / maxScore;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(
                isIELTS ? score.toString() : '${score.toInt()} / 100',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isIELTS
                    ? (score >= 8.0
                        ? Colors.green
                        : score >= 7.0
                            ? Colors.blue
                            : Colors.orange)
                    : (score >= 85.0
                        ? Colors.green
                        : score >= 75.0
                            ? Colors.blue
                            : Colors.orange),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
