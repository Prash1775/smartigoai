import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../agents/agent_definitions.dart';
import '../models/ai_message.dart';
import '../repositories/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return GeminiAiRepository();
});

final aiCoachProvider = StateNotifierProvider<AiCoachNotifier, AiCoachState>((ref) {
  final repository = ref.watch(aiRepositoryProvider);
  return AiCoachNotifier(repository);
});

class AiCoachState {
  final List<AiMessage> messages;
  final bool isLoading;
  final String? error;
  final AgentType selectedAgent;

  const AiCoachState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.selectedAgent = AgentType.tutor,
  });

  AiCoachState copyWith({
    List<AiMessage>? messages,
    bool? isLoading,
    String? error,
    AgentType? selectedAgent,
  }) {
    return AiCoachState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAgent: selectedAgent ?? this.selectedAgent,
    );
  }
}

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  final AiRepository _aiRepository;

  AiCoachNotifier(this._aiRepository) : super(const AiCoachState()) {
    _initializeMessages();
  }

  void _initializeMessages() {
    state = state.copyWith(
      messages: [
        AiMessage.system(
          'Welcome to SmartGo AI Coach. Ask for help with exam planning, practice question generation, or reading comprehension.',
        ),
      ],
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = AiMessage.user(text.trim());
    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(messages: updatedMessages, isLoading: true, error: null);

    try {
      final assistantMessage = await _aiRepository.sendMessage(
        state.selectedAgent,
        text.trim(),
        updatedMessages,
      );
      state = state.copyWith(
        messages: [...updatedMessages, assistantMessage],
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void setAgent(AgentType agentType) {
    state = state.copyWith(selectedAgent: agentType);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
