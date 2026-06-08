import 'package:flutter/material.dart';

class VocabWord {
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String definition;
  final String example;
  final String memoryTip;

  const VocabWord({
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    required this.memoryTip,
  });
}

class VocabData {
  static List<VocabWord> getWords(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return const [
          VocabWord(word: 'Ubiquitous', pronunciation: '/juːˈbɪk.wɪ.təs/', partOfSpeech: 'adjective', definition: 'Present, appearing, or found everywhere.', example: 'Mobile phones have become ubiquitous in modern society.', memoryTip: 'Think: "You-be-QUIT-us" — it\'s everywhere, you can\'t quit it!'),
          VocabWord(word: 'Mitigate', pronunciation: '/ˈmɪt.ɪ.ɡeɪt/', partOfSpeech: 'verb', definition: 'To make less severe, serious, or painful.', example: 'Governments must mitigate the effects of climate change.', memoryTip: '"Mitt-i-gate" — a mitt (glove) reduces the pain of catching a ball.'),
          VocabWord(word: 'Pragmatic', pronunciation: '/præɡˈmæt.ɪk/', partOfSpeech: 'adjective', definition: 'Dealing with things sensibly and realistically, rather than ideally.', example: 'A pragmatic approach to solving poverty is needed.', memoryTip: '"Practical" = pragmatic. Both start with "pra."'),
          VocabWord(word: 'Proliferation', pronunciation: '/prəˌlɪf.əˈreɪ.ʃən/', partOfSpeech: 'noun', definition: 'Rapid increase in the number or amount of something.', example: 'The proliferation of social media has changed communication.', memoryTip: 'Pro + life + ration — pro-life in large rations = lots of growth!'),
          VocabWord(word: 'Substantiate', pronunciation: '/səbˈstæn.ʃi.eɪt/', partOfSpeech: 'verb', definition: 'To provide evidence to support or prove the truth of.', example: 'The researcher could not substantiate her claims.', memoryTip: '"Sub-STANCE" — to substantiate is to give something substance/proof.'),
          VocabWord(word: 'Discrepancy', pronunciation: '/dɪˈskrep.ən.si/', partOfSpeech: 'noun', definition: 'A lack of compatibility or similarity between two or more facts.', example: 'There was a discrepancy between the two reports.', memoryTip: '"Dis-crep" sounds like "disagree" — two things don\'t agree.'),
          VocabWord(word: 'Inherent', pronunciation: '/ɪnˈhɪər.ənt/', partOfSpeech: 'adjective', definition: 'Existing as a natural or permanent quality; built-in.', example: 'There are inherent risks in any investment.', memoryTip: '"In-HERE-nt" — it\'s already IN here (inside the thing).'),
          VocabWord(word: 'Exacerbate', pronunciation: '/ɪɡˈzæs.ə.beɪt/', partOfSpeech: 'verb', definition: 'To make a problem, bad situation, or negative feeling worse.', example: 'Stress can exacerbate health problems.', memoryTip: 'Ex + ACERB (sharp/bitter) + ate — make things MORE bitter/sharp.'),
          VocabWord(word: 'Concede', pronunciation: '/kənˈsiːd/', partOfSpeech: 'verb', definition: 'To admit that something is true after first denying or resisting it.', example: 'The politician had to concede that he had made an error.', memoryTip: '"Con-CEDE" — to cede (give up) to what someone else says.'),
          VocabWord(word: 'Scrutiny', pronunciation: '/ˈskruː.tɪ.ni/', partOfSpeech: 'noun', definition: 'Critical observation or examination.', example: 'The CEO\'s decisions were under intense public scrutiny.', memoryTip: '"Scru-TINY" — looking at tiny details very carefully.'),
        ];
      case 'GRE':
        return const [
          VocabWord(word: 'Garrulous', pronunciation: '/ˈɡær.ʊ.ləs/', partOfSpeech: 'adjective', definition: 'Excessively talkative, especially on trivial matters.', example: 'The garrulous professor exceeded the lecture time by 30 minutes.', memoryTip: '"Garru-LOUS" sounds like "gargle" — a garrulous person garbles on endlessly.'),
          VocabWord(word: 'Laconic', pronunciation: '/ləˈkɒn.ɪk/', partOfSpeech: 'adjective', definition: 'Using very few words; brief and concise.', example: 'His laconic reply of "Fine" revealed nothing about his feelings.', memoryTip: 'Opposite of garrulous. "La-CON-ic" — con-cise!'),
          VocabWord(word: 'Sycophant', pronunciation: '/ˈsɪk.ə.fənt/', partOfSpeech: 'noun', definition: 'A person who acts obsequiously towards someone to gain advantage; a flatterer.', example: 'Surrounded by sycophants, the CEO rarely heard honest feedback.', memoryTip: '"Syco-PHANT" — a phantom (fake) friend who says what you want to hear.'),
          VocabWord(word: 'Equivocate', pronunciation: '/ɪˈkwɪv.ə.keɪt/', partOfSpeech: 'verb', definition: 'To use ambiguous language so as to conceal the truth or avoid committing oneself.', example: 'The politician equivocated when asked about his tax policies.', memoryTip: '"Equi-VOC-ate" — equi (equal) + vocal — saying equally weighted things to avoid taking a side.'),
          VocabWord(word: 'Perfidious', pronunciation: '/pəˈfɪd.i.əs/', partOfSpeech: 'adjective', definition: 'Deceitful and untrustworthy.', example: 'The perfidious advisor secretly worked against the king.', memoryTip: '"Per-FID" — per-fidelity broken. Per-FID-ious = per-faithless!'),
          VocabWord(word: 'Pellucid', pronunciation: '/pəˈluː.sɪd/', partOfSpeech: 'adjective', definition: 'Translucently clear; easily understood.', example: 'Her pellucid explanation made the difficult concept accessible to all.', memoryTip: '"Pel-LUCID" — lucid means clear. Pellucid is extra clear, like lucid crystal!'),
          VocabWord(word: 'Obdurate', pronunciation: '/ˈɒb.djʊ.rɪt/', partOfSpeech: 'adjective', definition: 'Stubbornly refusing to change one\'s opinion or course of action.', example: 'Despite the evidence, he remained obdurate in his refusal.', memoryTip: '"Ob-DUR-ate" — DUR = hard/enduring. Hard-headed!'),
          VocabWord(word: 'Diffident', pronunciation: '/ˈdɪf.ɪ.dənt/', partOfSpeech: 'adjective', definition: 'Modest or shy due to a lack of self-confidence.', example: 'The diffident student rarely raised her hand in class.', memoryTip: '"Dif-FID-ent" — DIF-ficult to have fidelity (confidence) in yourself.'),
          VocabWord(word: 'Enervate', pronunciation: '/ˈen.ə.veɪt/', partOfSpeech: 'verb', definition: 'To cause someone to feel drained of energy or vitality.', example: 'The summer heat enervated the marathon runners.', memoryTip: '"E-NERVE-ate" — to remove your nerve/energy.'),
          VocabWord(word: 'Tendentious', pronunciation: '/tenˈden.ʃəs/', partOfSpeech: 'adjective', definition: 'Promoting a particular cause or point of view; biased.', example: 'The editorial was criticised for its tendentious reporting.', memoryTip: '"TEND-entious" — tending strongly toward one opinion.'),
        ];
      case 'GMAT':
      default:
        return const [
          VocabWord(word: 'Preclude', pronunciation: '/prɪˈkluːd/', partOfSpeech: 'verb', definition: 'To prevent from happening; make impossible in advance.', example: 'The strict budget precluded any investment in new technology.', memoryTip: '"Pre-CLUDE" — pre (before) + clude (close). Close the door BEFORE it happens.'),
          VocabWord(word: 'Ostensibly', pronunciation: '/ɒˈsten.sɪ.bli/', partOfSpeech: 'adverb', definition: 'Apparently or purportedly, but perhaps not actually.', example: 'The merger was ostensibly about cost savings, but was really about market control.', memoryTip: '"Ostensibly" sounds like "obvious" — what\'s obvious on the surface (but maybe not true).'),
          VocabWord(word: 'Mitigate', pronunciation: '/ˈmɪt.ɪ.ɡeɪt/', partOfSpeech: 'verb', definition: 'To lessen the severity, seriousness, or painfulness of something.', example: 'Diversification can mitigate investment risk.', memoryTip: '"Mitt-i-gate" — a glove (mitt) protects and reduces impact.'),
          VocabWord(word: 'Caveat', pronunciation: '/ˈkæv.i.æt/', partOfSpeech: 'noun', definition: 'A warning or qualification attached to an agreement or statement.', example: 'The analyst endorsed the strategy with one important caveat.', memoryTip: '"CAV-eat" — a cave-eat: something that could eat you if you\'re not careful. A warning!'),
          VocabWord(word: 'Intransigent', pronunciation: '/ɪnˈtræn.zɪ.dʒənt/', partOfSpeech: 'adjective', definition: 'Unwilling to change one\'s views or to agree about something.', example: 'The intransigent union refused all proposed compromises.', memoryTip: '"In-TRANS-igent" — refuses to TRANSIT or move to the other side.'),
          VocabWord(word: 'Extrapolate', pronunciation: '/ɪkˈstræp.ə.leɪt/', partOfSpeech: 'verb', definition: 'To extend the application of data to an unknown situation by assuming that trends continue.', example: 'From one year\'s data, we cannot extrapolate a decade-long trend.', memoryTip: '"Extra-POLATE" — extra information + pollinate (spread). Spreading data beyond its known range.'),
          VocabWord(word: 'Contention', pronunciation: '/kənˈten.ʃən/', partOfSpeech: 'noun', definition: 'A point of view held or expressed in an argument; dispute.', example: 'The central contention of the argument is flawed.', memoryTip: '"Con-TENSION" — tension between two sides = contention.'),
          VocabWord(word: 'Analogous', pronunciation: '/əˈnæl.ə.ɡəs/', partOfSpeech: 'adjective', definition: 'Similar in certain respects, allowing a comparison to be made.', example: 'The structure of atoms is analogous to a miniature solar system.', memoryTip: '"Ana-LOGO-us" — similar logos (symbols). Two things with similar "shapes" of meaning.'),
          VocabWord(word: 'Precipitate', pronunciation: '/prɪˈsɪp.ɪ.teɪt/', partOfSpeech: 'verb/adj', definition: 'To cause an event to happen suddenly or prematurely; done hastily.', example: 'The scandal precipitated the CEO\'s resignation.', memoryTip: '"Pre-CIPITATE" — like precipitation (rain) falling fast and suddenly.'),
          VocabWord(word: 'Circumvent', pronunciation: '/ˌsɜː.kəmˈvent/', partOfSpeech: 'verb', definition: 'To find a way around an obstacle; to overcome by cleverness.', example: 'The company circumvented regulations by operating offshore.', memoryTip: '"Circum-VENT" — circumference (go around) + vent (get out). Go around to get out.'),
        ];
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Vocabulary Flashcard Screen
// ─────────────────────────────────────────────────────────────
class VocabularyScreen extends StatefulWidget {
  final String examType;
  const VocabularyScreen({super.key, required this.examType});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> with TickerProviderStateMixin {
  late List<VocabWord> _words;
  int _currentIndex = 0;
  bool _isFlipped = false;
  final Set<int> _known = {};
  final Set<int> _learning = {};
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _words = VocabData.getWords(widget.examType);
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  void _markKnown() {
    setState(() {
      _known.add(_currentIndex);
      _learning.remove(_currentIndex);
      _nextCard();
    });
  }

  void _markLearning() {
    setState(() {
      _learning.add(_currentIndex);
      _known.remove(_currentIndex);
      _nextCard();
    });
  }

  void _nextCard() {
    if (_currentIndex < _words.length - 1) {
      _flipController.reset();
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      _flipController.reset();
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final word = _words[_currentIndex];
    final done = _known.length + _learning.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Vocabulary – ${widget.examType}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${_words.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _words.length,
            minHeight: 5,
            backgroundColor: Colors.grey.shade200,
          ),
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('✅ Know', _known.length, Colors.green),
                _buildStat('📖 Learning', _learning.length, Colors.orange),
                _buildStat('⏭ Remaining', _words.length - done, Colors.grey),
              ],
            ),
          ),
          // Flashcard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * 3.14159;
                    final isFront = _flipAnimation.value < 0.5;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: isFront
                          ? _buildFront(context, word)
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(3.14159),
                              child: _buildBack(context, word),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Buttons
          if (_isFlipped)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _markLearning,
                      icon: const Icon(Icons.replay, color: Colors.orange),
                      label: const Text('Still Learning', style: TextStyle(color: Colors.orange)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _markKnown,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('I Know This!', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentIndex > 0 ? _prevCard : null,
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Text(
                    'Tap card to reveal definition',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  IconButton(
                    onPressed: _currentIndex < _words.length - 1 ? _nextCard : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildFront(BuildContext context, VocabWord word) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(word.partOfSpeech, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ),
          const SizedBox(height: 20),
          Text(
            word.word,
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            word.pronunciation,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 30),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, color: Colors.white54),
              SizedBox(width: 6),
              Text('Tap to see definition', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context, VocabWord word) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(word.word, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _backSection('📖 Definition', word.definition),
            const SizedBox(height: 14),
            _backSection('✏️ Example', word.example),
            const SizedBox(height: 14),
            _backSection('💡 Memory Tip', word.memoryTip, highlight: true),
          ],
        ),
      ),
    );
  }

  Widget _backSection(String label, String content, {bool highlight = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight ? Colors.amber.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: highlight ? Border.all(color: Colors.amber.shade300) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}
