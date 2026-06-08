import 'package:flutter/material.dart';

class ReadingPractice {
  final String title;
  final String passage;
  final List<ReadingQuestion> questions;
  final String examType;

  const ReadingPractice({
    required this.title,
    required this.passage,
    required this.questions,
    required this.examType,
  });
}

class ReadingQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const ReadingQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// Real practice data
class ReadingData {
  static ReadingPractice getPassage(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return const ReadingPractice(
          examType: 'IELTS',
          title: 'The Effects of Sleep Deprivation',
          passage: '''
Sleep is a fundamental biological necessity, yet in modern society, it is frequently sacrificed in favour of productivity. Research consistently demonstrates that adults require between seven and nine hours of sleep per night to maintain optimal cognitive and physical health. When this requirement is not met, a cascade of negative consequences follows.

The most immediate effect of sleep deprivation is impaired cognitive function. Studies conducted at the University of Pennsylvania found that individuals restricted to six hours of sleep per night for two weeks showed performance deficits equivalent to those seen after 24 hours of complete sleep loss. Critically, these individuals were largely unaware of how impaired they had become — a phenomenon researchers call "subjective normalisation."

Beyond cognition, chronic sleep deprivation has been linked to a range of serious health conditions. The immune system is significantly compromised; one landmark study found that people who slept fewer than seven hours a night were three times more likely to develop a cold when exposed to a rhinovirus than those who slept eight hours or more. Cardiovascular health is also affected, with sleep-deprived individuals showing elevated blood pressure and increased risk of heart disease.

Perhaps most concerning is the impact on mental health. The relationship between sleep and mood is bidirectional: while anxiety and depression can disrupt sleep, poor sleep also exacerbates both conditions. Emerging research suggests that during sleep, the brain's glymphatic system actively clears metabolic waste, including proteins associated with Alzheimer's disease. Habitually short sleepers may therefore be at higher long-term neurological risk.

Despite overwhelming evidence, many cultures continue to glorify minimal sleep as a sign of dedication. A shift in societal attitudes — treating adequate sleep as a pillar of health rather than a luxury — is urgently needed.
          ''',
          questions: [
            ReadingQuestion(
              question: 'According to the passage, how many hours of sleep do adults need per night?',
              options: ['5–6 hours', '6–7 hours', '7–9 hours', '9–10 hours'],
              correctIndex: 2,
            ),
            ReadingQuestion(
              question: 'What does "subjective normalisation" refer to in the passage?',
              options: [
                'Getting used to less sleep over time',
                'Being unaware of one\'s own impairment',
                'Adjusting work schedules to allow more sleep',
                'A medical treatment for sleep disorders',
              ],
              correctIndex: 1,
            ),
            ReadingQuestion(
              question: 'People who slept fewer than 7 hours were how much more likely to catch a cold?',
              options: ['Twice as likely', 'Three times as likely', 'Four times as likely', 'Five times as likely'],
              correctIndex: 1,
            ),
            ReadingQuestion(
              question: 'The relationship between sleep and mood is described as:',
              options: ['Unidirectional', 'Bidirectional', 'Negligible', 'Inconsistent'],
              correctIndex: 1,
            ),
            ReadingQuestion(
              question: 'What does the brain\'s glymphatic system do during sleep?',
              options: [
                'Stores new memories',
                'Regulates heart rate',
                'Clears metabolic waste',
                'Produces melatonin',
              ],
              correctIndex: 2,
            ),
          ],
        );
      case 'GRE':
        return const ReadingPractice(
          examType: 'GRE',
          title: 'The Paradox of Expertise',
          passage: '''
Expertise is widely regarded as an unambiguous good — a state of mastery that confers both professional advantages and cognitive sophistication. However, a growing body of research suggests that expertise carries with it a subtle but significant cognitive liability: the expert's tendency to be confounded by problems that novices solve with ease.

This phenomenon, sometimes called the "curse of knowledge," arises because experts organise information into highly integrated mental schemas. While such schemas enable rapid, accurate processing within familiar domains, they can paradoxically impede performance on tasks that require abandoning established frameworks. A chess grandmaster, for instance, will recall the positions of pieces on a meaningful game board with extraordinary accuracy. Present the same master with a board containing randomly placed pieces, and their recall advantage nearly vanishes — because the random configuration resists integration into the existing schemas.

Similarly, Wieman and colleagues found that physics professors, when shown diagrams of physical systems, categorised them by deep structural features — the underlying principles at work. Novice students, by contrast, categorised the same diagrams by surface features, such as the presence of a pulley or inclined plane. The experts' deep-structure orientation, while generally advantageous, led them to miss certain surface-level patterns that novices readily detected.

The implication is not that expertise is undesirable — its benefits far outweigh its costs. Rather, the research suggests that optimal problem-solving may require the deliberate cultivation of "beginner's mind": the willingness to set aside established frameworks and perceive a problem with fresh eyes. This capacity, paradoxically, may be one of the hardest things for an expert to develop.
          ''',
          questions: [
            ReadingQuestion(
              question: 'The "curse of knowledge" refers to:',
              options: [
                'Knowing too many facts to focus',
                'Experts struggling with problems novices solve easily',
                'Novices being overconfident',
                'The difficulty of teaching expertise to others',
              ],
              correctIndex: 1,
            ),
            ReadingQuestion(
              question: 'The chess grandmaster example illustrates that:',
              options: [
                'Grandmasters have perfect memory',
                'Random configurations are easier to recall',
                'Expert recall depends on meaningful patterns',
                'Chess skills transfer to all memory tasks',
              ],
              correctIndex: 2,
            ),
            ReadingQuestion(
              question: 'How did expert physicists categorise diagrams differently from novices?',
              options: [
                'By surface features like pulleys',
                'By the colour of the diagrams',
                'By deep structural principles',
                'By the number of objects shown',
              ],
              correctIndex: 2,
            ),
            ReadingQuestion(
              question: 'The passage\'s overall tone toward expertise is best described as:',
              options: [
                'Entirely critical',
                'Entirely celebratory',
                'Nuanced — acknowledging both benefits and costs',
                'Indifferent',
              ],
              correctIndex: 2,
            ),
            ReadingQuestion(
              question: 'According to the passage, "beginner\'s mind" is:',
              options: [
                'A state of ignorance',
                'Hard for experts to develop',
                'Automatically achieved with experience',
                'Irrelevant to problem-solving',
              ],
              correctIndex: 1,
            ),
          ],
        );
      case 'GMAT':
      default:
        return const ReadingPractice(
          examType: 'GMAT',
          title: 'Market Disruption and Incumbent Response',
          passage: '''
Disruptive innovation, a term coined by Clayton Christensen, describes a process by which a product or service initially takes root in simple applications at the bottom of a market and then relentlessly moves upmarket, eventually displacing established competitors. This model has proved remarkably predictive: it correctly anticipated the decline of integrated steel mills before minimill competitors like Nucor were widely recognised as threats.

The theory's central insight is that established companies are rational actors who fail not because of poor management but because they listen too closely to their most demanding customers. Incumbents focus resources on sustaining innovations that serve high-margin segments, while dismissing disruptive entrants as serving only low-end or non-consuming customers. By the time the disruption becomes apparent, the incumbent faces a competitor that has climbed the market ladder and is serving mainstream customers at dramatically lower cost.

Critics, however, argue that Christensen's framework has been applied too broadly, lending a veneer of inevitability to business failures that had more mundane causes. Jill Lepore, in a widely cited 2014 essay, argued that the theory's historical examples are selectively chosen and that its predictive power is overstated. She noted that companies cited as victims of disruption were sometimes struggling for reasons unrelated to the phenomenon — regulatory changes, managerial failures, or macroeconomic shifts.

This debate matters practically because the prescribed responses differ. If disruption is inevitable, incumbents should cannibalise their own products proactively, spinning off independent units to pursue disruptive trajectories. If disruption is merely one of many competitive dynamics, more targeted responses — selective acquisition, partnership, or portfolio diversification — may be more appropriate than wholesale strategic transformation.
          ''',
          questions: [
            ReadingQuestion(
              question: 'According to Christensen\'s theory, why do established companies fail?',
              options: [
                'They employ poor managers',
                'They listen too closely to demanding customers',
                'They over-invest in low-end markets',
                'They ignore high-margin segments',
              ],
              correctIndex: 1,
            ),
            ReadingQuestion(
              question: 'Jill Lepore\'s criticism of disruption theory is that:',
              options: [
                'It applies only to steel companies',
                'Its predictive power is understated',
                'Examples are selectively chosen and causation overstated',
                'Incumbents should move faster to disrupt themselves',
              ],
              correctIndex: 2,
            ),
            ReadingQuestion(
              question: 'The word "cannibalise" in the final paragraph most nearly means:',
              options: [
                'Destroy competitor products',
                'Sell unprofitable divisions',
                'Compete with one\'s own existing products',
                'Acquire smaller companies',
              ],
              correctIndex: 2,
            ),
            ReadingQuestion(
              question: 'Nucor is mentioned in the passage as an example of:',
              options: [
                'A company that failed due to disruption',
                'A disruptive entrant in the steel industry',
                'A company that acquired an incumbent',
                'A firm that ignored disruptive threats',
              ],
              correctIndex: 1,
            ),
            ReadingQuestion(
              question: 'The passage suggests that the appropriate response to disruption depends on:',
              options: [
                'The size of the incumbent company',
                'The geographic market involved',
                'Whether disruption is viewed as inevitable or situational',
                'The age of the incumbent company',
              ],
              correctIndex: 2,
            ),
          ],
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Reading Practice Screen
// ─────────────────────────────────────────────────────────────
class ReadingPracticeScreen extends StatefulWidget {
  final String examType;
  const ReadingPracticeScreen({super.key, required this.examType});

  @override
  State<ReadingPracticeScreen> createState() => _ReadingPracticeScreenState();
}

class _ReadingPracticeScreenState extends State<ReadingPracticeScreen> {
  late ReadingPractice _practice;
  final Map<int, int> _answers = {};
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _practice = ReadingData.getPassage(widget.examType);
  }

  int get _score =>
      _answers.entries.where((e) => e.value == _practice.questions[e.key].correctIndex).length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading – ${widget.examType}'),
        actions: [
          if (!_submitted)
            TextButton(
              onPressed: _answers.length == _practice.questions.length
                  ? () => setState(() => _submitted = true)
                  : null,
              child: const Text('Submit'),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_submitted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _score >= 4
                  ? Colors.green.shade100
                  : _score >= 2
                      ? Colors.orange.shade100
                      : Colors.red.shade100,
              child: Text(
                'Score: $_score / ${_practice.questions.length}  ${_score >= 4 ? "🎉 Excellent!" : _score >= 2 ? "👍 Good effort!" : "📖 Keep practicing!"}',
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
                  // Passage
                  Text(
                    _practice.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${widget.examType} Academic Reading',
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _practice.passage.trim(),
                      style: const TextStyle(fontSize: 15, height: 1.7),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Questions
                  Text(
                    'Questions',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, int qi, ReadingQuestion q) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Q${qi + 1}. ${q.question}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
                  borderRadius: BorderRadius.circular(10),
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: borderColor != null ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label)),
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
}
