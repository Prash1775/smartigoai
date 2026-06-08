import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/providers/auth_provider.dart';
import '../agents/agent_definitions.dart';
import '../models/ai_message.dart';
import '../providers/ai_coach_provider.dart';

class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final messageController = TextEditingController();

  // Returns suggested prompts specific to the student's exam
  List<String> _getSuggestedPrompts(String examType) {
    switch (examType.toUpperCase()) {
      case 'IELTS':
        return [
          'Give me IELTS Writing Task 2 tips',
          'Explain IELTS Band 7 criteria',
          'Generate IELTS Reading practice questions',
          'How to improve IELTS Speaking?',
          'Question: [q] User Answer: [a] Correct Answer: [c]',
        ];
      case 'GRE':
        return [
          'Explain GRE Probability concepts',
          'Give me GRE Verbal practice',
          'GRE Analytical Writing tips',
          'How to improve GRE Quantitative?',
          'Question: [q] User Answer: [a] Correct Answer: [c]',
        ];
      case 'GMAT':
        return [
          'Explain GMAT Data Sufficiency strategy',
          'Generate GMAT Critical Reasoning questions',
          'GMAT Verbal Reasoning tips',
          'How to improve GMAT Quantitative?',
          'Question: [q] User Answer: [a] Correct Answer: [c]',
        ];
      default:
        return [
          'Help me with my exam preparation',
          'Generate practice questions',
          'Create a study plan for me',
          'Explain a topic I am struggling with',
        ];
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    ref.read(aiCoachProvider.notifier).sendMessage(text);
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiCoachProvider);
    final auth = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    final examType = auth is Authenticated ? auth.user.examType : 'Exam';
    final suggestedPrompts = _getSuggestedPrompts(examType);

    return Scaffold(
      appBar: AppBar(
        title: Text('$examType AI Coach'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(examType,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Agent:',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<AgentType>(
                      initialValue: state.selectedAgent,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      items: AgentType.values.map((agent) {
                        return DropdownMenuItem(
                          value: agent,
                          child: Text(agent.displayName),
                        );
                      }).toList(),
                      onChanged: (agent) {
                        if (agent != null) {
                          ref
                              .read(aiCoachProvider.notifier)
                              .setAgent(agent);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: theme.colorScheme.primaryContainer,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: suggestedPrompts.map((prompt) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(prompt),
                        onPressed: () => _sendMessage(prompt),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (state.error != null)
              Container(
                width: double.infinity,
                color: Colors.red.shade50,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.error!.length > 150
                            ? '${state.error!.substring(0, 150)}...'
                            : state.error!,
                        style: TextStyle(color: Colors.red.shade900),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          ref.read(aiCoachProvider.notifier).clearError(),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return _buildMessageBubble(message, theme);
                },
              ),
            ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Ask your $examType AI Coach...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => _sendMessage(messageController.text),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AiMessage message, ThemeData theme) {
    final isUser = message.type == AiMessageType.user;
    final bubbleColor = isUser
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;
    final textColor =
        isUser ? Colors.white : theme.textTheme.bodyLarge?.color;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.type == AiMessageType.system)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'SmartGo AI',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                h1: theme.textTheme.titleLarge?.copyWith(color: textColor, fontWeight: FontWeight.bold),
                h2: theme.textTheme.titleMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
                h3: theme.textTheme.titleSmall?.copyWith(color: textColor, fontWeight: FontWeight.bold),
                listBullet: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                code: theme.textTheme.bodyMedium?.copyWith(
                  backgroundColor: isUser ? Colors.white24 : Colors.grey.shade200,
                  fontFamily: 'monospace',
                ),
                codeblockDecoration: BoxDecoration(
                  color: isUser ? Colors.white24 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
