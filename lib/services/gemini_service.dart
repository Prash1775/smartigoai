import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/ai_coach/models/ai_message.dart';
import '../features/ai_coach/agents/agent_definitions.dart';

abstract class AiProvider {
  final String name;
  AiProvider(this.name);

  Future<String> generate(
    String systemPrompt,
    List<AiMessage> history,
    String userPrompt,
    double temperature,
    int maxTokens,
  );

  Future<String> generateSimple(
    String prompt,
    double temperature,
    int maxTokens,
  );
}

class GroqProvider extends AiProvider {
  final String apiKey;
  final String model;
  final http.Client client;

  GroqProvider(this.apiKey, this.model, this.client) : super('Groq');

  @override
  Future<String> generate(String systemPrompt, List<AiMessage> history, String userPrompt, double temperature, int maxTokens) async {
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => {
            'role': m.type == AiMessageType.user ? 'user' : 'assistant',
            'content': m.text,
          }),
      {'role': 'user', 'content': userPrompt},
    ];
    return _callOpenAiCompatibleApi(messages, temperature, maxTokens);
  }

  @override
  Future<String> generateSimple(String prompt, double temperature, int maxTokens) {
    return _callOpenAiCompatibleApi([
      {'role': 'user', 'content': prompt}
    ], temperature, maxTokens);
  }

  Future<String> _callOpenAiCompatibleApi(List<Map<String, String>> messages, double temperature, int maxTokens) async {
    final response = await client.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode != 200) {
      throw http.ClientException('Groq API Error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'].toString().trim();
  }
}

class SarvamProvider extends AiProvider {
  final String apiKey;
  final http.Client client;

  SarvamProvider(this.apiKey, this.client) : super('Sarvam');

  @override
  Future<String> generate(String systemPrompt, List<AiMessage> history, String userPrompt, double temperature, int maxTokens) async {
    // Assuming Sarvam provides an OpenAI compatible chat completions endpoint
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => {
            'role': m.type == AiMessageType.user ? 'user' : 'assistant',
            'content': m.text,
          }),
      {'role': 'user', 'content': userPrompt},
    ];
    return _callOpenAiCompatibleApi(messages, temperature, maxTokens);
  }

  @override
  Future<String> generateSimple(String prompt, double temperature, int maxTokens) {
    return _callOpenAiCompatibleApi([
      {'role': 'user', 'content': prompt}
    ], temperature, maxTokens);
  }

  Future<String> _callOpenAiCompatibleApi(List<Map<String, String>> messages, double temperature, int maxTokens) async {
    final response = await client.post(
      Uri.parse('https://api.sarvam.ai/v1/chat/completions'), // common endpoint pattern
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'api-subscription-key': apiKey, // sometimes used by Sarvam
      },
      body: jsonEncode({
        'model': 'sarvam-2', // placeholder model name, might adapt if needed
        'messages': messages,
        'temperature': temperature,
        'max_tokens': maxTokens,
      }),
    );

    if (response.statusCode != 200) {
      throw http.ClientException('Sarvam API Error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'].toString().trim();
  }
}

class GeminiGoogleProvider extends AiProvider {
  final String apiKey;
  final String model;
  final http.Client client;

  GeminiGoogleProvider(this.apiKey, this.model, this.client) : super('Gemini');

  @override
  Future<String> generate(String systemPrompt, List<AiMessage> history, String userPrompt, double temperature, int maxTokens) async {
    final contents = history.map((message) {
      final role = message.type == AiMessageType.user ? 'user' : 'model';
      return {
        'role': role,
        'parts': [{'text': message.text}],
      };
    }).toList();

    contents.add({
      'role': 'user',
      'parts': [{'text': userPrompt}],
    });

    final payload = {
      'contents': contents,
      'systemInstruction': {
        'parts': [{'text': systemPrompt}]
      },
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
      }
    };

    return _callGeminiApi(payload);
  }

  @override
  Future<String> generateSimple(String prompt, double temperature, int maxTokens) {
    final payload = {
      'contents': [
        {'role': 'user', 'parts': [{'text': prompt}]}
      ],
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
      }
    };
    return _callGeminiApi(payload);
  }

  Future<String> _callGeminiApi(Map<String, dynamic> payload) async {
    final endpoint = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');
    final response = await client.post(
      endpoint,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw http.ClientException('Gemini request failed: ${response.statusCode} ${response.body}', endpoint);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = body['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw StateError('Gemini response contained no candidates');
    }
    final firstCandidate = candidates.first as Map<String, dynamic>;
    final content = firstCandidate['content'] as Map<String, dynamic>?;
    if (content == null || content.isEmpty) {
      throw StateError('Gemini response contained no content');
    }
    final parts = content['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw StateError('Gemini response contained no parts');
    }
    final text = (parts.first as Map<String, dynamic>)['text'] as String?;
    if (text == null || text.isEmpty) {
      throw StateError('Gemini response text is empty');
    }
    return text.trim();
  }
}

class GeminiService {
  final http.Client client;
  final List<AiProvider> _providers;

  GeminiService({http.Client? client}) 
      : client = client ?? http.Client(),
        _providers = _buildProviders(client ?? http.Client());

  static List<AiProvider> _buildProviders(http.Client client) {
    // We try Groq first (fastest, high limits)
    // Then Sarvam (user provided)
    // Then Gemini as final fallback
    
    final groqKey = const String.fromEnvironment('GROQ_API_KEY', 
        defaultValue:const apiKey = ""; );
    
    final sarvamKey = const String.fromEnvironment('SARVAM_API_KEY', 
        defaultValue:const apiKey = ""; );
        
    final geminiKey = const String.fromEnvironment('GEMINI_API_KEY',
        defaultValue:const apiKey = ""; );

    return [
      if (groqKey.isNotEmpty) GroqProvider(groqKey, 'llama3-8b-8192', client),
      if (sarvamKey.isNotEmpty) SarvamProvider(sarvamKey, client),
      if (geminiKey.isNotEmpty) GeminiGoogleProvider(geminiKey, 'gemini-2.5-flash', client),
    ];
  }

  Future<String> generateReply(
    AgentType agentType,
    List<AiMessage> history,
    AgentInputModel inputModel,
  ) async {
    final agent = AgentFactory.create(agentType);
    Exception? lastError;

    for (final provider in _providers) {
      try {
        return await provider.generate(
          agent.systemPrompt,
          history,
          inputModel.buildPrompt(),
          agent.temperature,
          agent.maxTokens,
        );
      } catch (e) {
        lastError = e as Exception;
        print('${provider.name} failed: $e. Falling back to next provider...');
        // continue to next provider
      }
    }

    throw lastError ?? Exception('All AI providers failed.');
  }

  Future<String> generateFromPrompt(
    String prompt, {
    double temperature = 0.7,
    int maxTokens = 2000,
    String? responseMimeType,
  }) async {
    Exception? lastError;

    for (final provider in _providers) {
      try {
        return await provider.generateSimple(
          prompt,
          temperature,
          maxTokens,
        );
      } catch (e) {
        lastError = e as Exception;
        print('${provider.name} failed: $e. Falling back to next provider...');
        // continue to next provider
      }
    }

    throw lastError ?? Exception('All AI providers failed.');
  }

  Stream<String> streamReply(
    AgentType agentType,
    List<AiMessage> history,
    AgentInputModel inputModel,
  ) async* {
    yield await generateReply(agentType, history, inputModel);
  }
}
