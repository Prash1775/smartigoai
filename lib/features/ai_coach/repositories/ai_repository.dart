import '../../ai_coach/agents/agent_definitions.dart';
import '../../ai_coach/models/ai_message.dart';
import '../../../services/gemini_service.dart';

abstract class AiRepository {
  Future<AiMessage> sendMessage(
    AgentType agentType,
    String text,
    List<AiMessage> history,
  );
}

class GeminiAiRepository implements AiRepository {
  final GeminiService _service;

  GeminiAiRepository({GeminiService? service}) : _service = service ?? GeminiService();

  @override
  Future<AiMessage> sendMessage(
    AgentType agentType,
    String text,
    List<AiMessage> history,
  ) async {
    final agent = AgentFactory.create(agentType);
    final inputModel = agent.inputModelFactory(text);
    final response = await _service.generateReply(agentType, history, inputModel);
    final outputModel = agent.outputModelFactory(response);
    return AiMessage.assistant(outputModel.text);
  }
}
