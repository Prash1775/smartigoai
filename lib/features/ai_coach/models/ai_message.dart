enum AiMessageType { user, assistant, system }

class AiMessage {
  final String id;
  final AiMessageType type;
  final String text;
  final DateTime timestamp;

  const AiMessage({
    required this.id,
    required this.type,
    required this.text,
    required this.timestamp,
  });

  factory AiMessage.user(String text) {
    return AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AiMessageType.user,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  factory AiMessage.assistant(String text) {
    return AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AiMessageType.assistant,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  factory AiMessage.system(String text) {
    return AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AiMessageType.system,
      text: text,
      timestamp: DateTime.now(),
    );
  }
}
