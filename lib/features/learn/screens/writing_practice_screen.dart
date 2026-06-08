import 'package:flutter/material.dart';

class WritingPrompt {
  final String taskType;
  final String instruction;
  final String prompt;
  final String tips;
  final int minWords;

  const WritingPrompt({
    required this.taskType,
    required this.instruction,
    required this.prompt,
    required this.tips,
    required this.minWords,
  });
}

class WritingData {
  static List<WritingPrompt> getPrompts(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return const [
          WritingPrompt(
            taskType: 'IELTS Writing Task 2',
            instruction: 'Write at least 250 words. You have 40 minutes.',
            prompt: 'Some people believe that unpaid community service should be a compulsory part of high school programmes. To what extent do you agree or disagree with this statement?\n\nGive reasons for your answer and include any relevant examples from your own knowledge or experience.',
            tips: '✅ State your position clearly in the introduction.\n✅ Write 2–3 body paragraphs — each with one main idea, an explanation, and an example.\n✅ Use linking words: Furthermore, However, In contrast, As a result.\n✅ Aim for 250–300 words.\n✅ End with a clear conclusion that restates your view.',
            minWords: 250,
          ),
          WritingPrompt(
            taskType: 'IELTS Writing Task 1',
            instruction: 'Write at least 150 words. You have 20 minutes.',
            prompt: 'The bar chart below shows the percentage of people in three countries (UK, USA, and Australia) who used the internet for different purposes in 2022 — entertainment, shopping, and education.\n\n[Imagine UK: Entertainment 75%, Shopping 65%, Education 45%. USA: Entertainment 80%, Shopping 70%, Education 55%. Australia: Entertainment 70%, Shopping 60%, Education 50%.]\n\nSummarise the information by selecting and reporting the main features, and make comparisons where relevant.',
            tips: '✅ Start with an overview (the most obvious trend).\n✅ Don\'t give your opinion — describe facts only.\n✅ Group related data together.\n✅ Use language like: rose significantly, remained stable, was approximately, in contrast.\n✅ Aim for exactly 150–180 words.',
            minWords: 150,
          ),
        ];
      case 'GRE':
        return const [
          WritingPrompt(
            taskType: 'GRE Issue Essay',
            instruction: 'Write a well-reasoned essay in 30 minutes. There is no word limit, but aim for 500–600 words.',
            prompt: '"It is more important to allocate financial resources to addressing immediate human needs than to long-term scientific research."\n\nWrite a response in which you discuss the extent to which you agree or disagree with the recommendation and explain your reasoning for the position you take.',
            tips: '✅ Take a clear, definite position — don\'t try to "both sides" it too much.\n✅ Use 3 well-developed body paragraphs with concrete examples.\n✅ Acknowledge the opposing view and refute it in one paragraph.\n✅ Use sophisticated vocabulary and varied sentence structure.\n✅ Strong conclusion: restate thesis and implications.',
            minWords: 400,
          ),
          WritingPrompt(
            taskType: 'GRE Argument Essay',
            instruction: 'Write a critical analysis in 30 minutes. Aim for 450–550 words.',
            prompt: '"The following appeared in a memo from the director of a large chain of coffee shops:\n\n\'Last year, our coffee shop in downtown Milltown had the highest profit of any location in our chain. The manager of the Milltown location instituted a policy of offering free samples of new products every Saturday morning. Therefore, to increase profits at all our other locations, we should require that all managers implement the same policy.\' "\n\nWrite a response in which you examine the stated and/or unstated assumptions of the argument.',
            tips: '✅ Do NOT give your own opinion on the topic — critique the ARGUMENT\'s logic.\n✅ Identify specific logical flaws (e.g., correlation vs. causation, hasty generalisation).\n✅ Explain what evidence would be needed to strengthen the argument.\n✅ Aim for 3 paragraphs — each targeting a different flaw.\n✅ End by summarising the argument\'s overall weakness.',
            minWords: 350,
          ),
        ];
      case 'GMAT':
      default:
        return const [
          WritingPrompt(
            taskType: 'GMAT Analytical Writing Assessment',
            instruction: 'Critically analyse the following argument in 30 minutes. Aim for 500+ words.',
            prompt: '"The following appeared in a report from the board of directors of Omega Retail:\n\n\'Our competitors, Apex Retail, recently renovated their flagship store and immediately saw a 30% increase in sales. We should therefore renovate all our stores to achieve similar growth. The renovation will be fully funded by cutting our marketing budget, which has grown significantly over the past three years without a corresponding increase in sales.\' "\n\nDiscuss how well-reasoned you find this argument. In your discussion, analyse the argument\'s line of reasoning and how well it uses evidence. Also point out what, if anything, would make the argument more sound.',
            tips: '✅ Do not argue for or against renovating — evaluate the LOGIC.\n✅ Identify at least 3 flaws: correlation vs causation, faulty analogy, unwarranted assumptions.\n✅ Use business reasoning: "The argument assumes X, but fails to consider Y."\n✅ Structure: Intro → Flaw 1 → Flaw 2 → Flaw 3 → What would strengthen it → Conclusion.\n✅ GMAT graders value precision and analytical depth over creativity.',
            minWords: 400,
          ),
        ];
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Writing Practice Screen
// ─────────────────────────────────────────────────────────────
class WritingPracticeScreen extends StatefulWidget {
  final String examType;
  const WritingPracticeScreen({super.key, required this.examType});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  late List<WritingPrompt> _prompts;
  int _selectedPrompt = 0;
  final TextEditingController _textController = TextEditingController();
  bool _submitted = false;
  bool _showTips = true;

  @override
  void initState() {
    super.initState();
    _prompts = WritingData.getPrompts(widget.examType);
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _textController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length;
  }

  WritingPrompt get _currentPrompt => _prompts[_selectedPrompt];
  bool get _meetsMinWords => _wordCount >= _currentPrompt.minWords;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Writing – ${widget.examType}'),
        actions: [
          IconButton(
            icon: Icon(_showTips ? Icons.lightbulb : Icons.lightbulb_outline),
            tooltip: 'Toggle Tips',
            onPressed: () => setState(() => _showTips = !_showTips),
          ),
        ],
      ),
      body: Column(
        children: [
          // Prompt selector (if multiple prompts)
          if (_prompts.length > 1)
            Container(
              color: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _prompts.asMap().entries.map((e) {
                  final selected = e.key == _selectedPrompt;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedPrompt = e.key;
                        _textController.clear();
                        _submitted = false;
                      }),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? theme.colorScheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          e.value.taskType,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentPrompt.taskType,
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentPrompt.instruction,
                    style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),

                  // Prompt box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      _currentPrompt.prompt,
                      style: const TextStyle(fontSize: 15, height: 1.65),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tips
                  if (_showTips)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              const Text('Writing Tips', style: TextStyle(fontWeight: FontWeight.bold)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => setState(() => _showTips = false),
                                child: const Icon(Icons.close, size: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_currentPrompt.tips, style: const TextStyle(fontSize: 13, height: 1.6)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Text editor
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Your Response', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _meetsMinWords ? Colors.green.shade100 : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_wordCount / ${_currentPrompt.minWords} words',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _meetsMinWords ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_submitted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Response Submitted!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Word count: $_wordCount words. In the full app, your essay will be analysed by AI for band score estimation, grammar feedback, and vocabulary suggestions.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => setState(() {
                              _submitted = false;
                              _textController.clear();
                            }),
                            child: const Text('Try Another Response'),
                          ),
                        ],
                      ),
                    )
                  else
                    TextField(
                      controller: _textController,
                      maxLines: 18,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                      decoration: InputDecoration(
                        hintText: 'Start writing your response here...',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  if (!_submitted)
                    ElevatedButton.icon(
                      onPressed: _wordCount > 20
                          ? () => setState(() => _submitted = true)
                          : null,
                      icon: const Icon(Icons.send),
                      label: Text(_meetsMinWords
                          ? 'Submit Response ($_wordCount words)'
                          : 'Submit (need ${_currentPrompt.minWords - _wordCount} more words)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
