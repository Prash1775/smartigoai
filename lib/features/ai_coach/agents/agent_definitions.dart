enum AgentType {
  tutor,
  studyPlanner,
  questionGenerator,
  answerExplainer,
  vocabulary,
  essayEvaluator,
  performanceCoach,
}

abstract class AgentInputModel {
  const AgentInputModel();

  Map<String, dynamic> toJson();
  String buildPrompt();
}

abstract class AgentOutputModel {
  final String text;

  const AgentOutputModel(this.text);
}

class TutorInputModel extends AgentInputModel {
  final String query;

  const TutorInputModel(this.query);

  @override
  Map<String, dynamic> toJson() => {'query': query};

  @override
  String buildPrompt() {
    return 'You are a tutor for IELTS, GRE, and GMAT students. Answer the following question in a clear and supportive way:\n$query';
  }
}

class TutorOutputModel extends AgentOutputModel {
  const TutorOutputModel(String text) : super(text);
}

class StudyPlannerInputModel extends AgentInputModel {
  final String goal;

  const StudyPlannerInputModel(this.goal);

  @override
  Map<String, dynamic> toJson() => {'goal': goal};

  @override
  String buildPrompt() {
    return 'You are a study planner. Create a personalized study plan based on this request:\n$goal';
  }
}

class StudyPlannerOutputModel extends AgentOutputModel {
  const StudyPlannerOutputModel(String text) : super(text);
}

class QuestionGeneratorInputModel extends AgentInputModel {
  final String topic;

  const QuestionGeneratorInputModel(this.topic);

  @override
  Map<String, dynamic> toJson() => {'topic': topic};

  @override
  String buildPrompt() {
    return 'You are a question generator for exam preparation. Create practice questions for this topic:\n$topic';
  }
}

class QuestionGeneratorOutputModel extends AgentOutputModel {
  const QuestionGeneratorOutputModel(String text) : super(text);
}

class AnswerExplanationInputModel extends AgentInputModel {
  final String rawInput;

  const AnswerExplanationInputModel(this.rawInput);

  String _extractSection(String start, [String? end]) {
    final cleaned = rawInput.replaceAll('\r', '');
    final startIndex = cleaned.indexOf(start);
    if (startIndex < 0) return '';
    final sectionStart = startIndex + start.length;
    final sectionEnd = end == null ? cleaned.length : cleaned.indexOf(end, sectionStart);
    if (sectionEnd < 0) {
      return cleaned.substring(sectionStart).trim();
    }
    return cleaned.substring(sectionStart, sectionEnd).trim();
  }

  String get question => _extractSection('Question:', 'User Answer:')
      .isNotEmpty
      ? _extractSection('Question:', 'User Answer:')
      : rawInput.trim();

  String get userAnswer => _extractSection('User Answer:', 'Correct Answer:');

  String get correctAnswer => _extractSection('Correct Answer:');

  @override
  Map<String, dynamic> toJson() => {'input': rawInput};

  @override
  String buildPrompt() {
    return '''You are an exam answer explanation engine.

Question:
${question.isNotEmpty ? question : rawInput}

User Answer:
${userAnswer.isNotEmpty ? userAnswer : 'N/A'}

Correct Answer:
${correctAnswer.isNotEmpty ? correctAnswer : 'N/A'}

Provide a detailed explanation with the following sections:
1. Why the user answer is wrong
2. Why the correct answer is right
3. Concept explanation
4. Revision notes
5. Similar questions the user can practice

Format your response clearly with headings for each section.''';
  }
}

class AnswerExplanationOutputModel extends AgentOutputModel {
  const AnswerExplanationOutputModel(String text) : super(text);
}

class VocabularyInputModel extends AgentInputModel {
  final String request;

  const VocabularyInputModel(this.request);

  @override
  Map<String, dynamic> toJson() => {'request': request};

  @override
  String buildPrompt() {
    return 'You are a vocabulary coach. Help the user improve vocabulary for this need:\n$request';
  }
}

class VocabularyOutputModel extends AgentOutputModel {
  const VocabularyOutputModel(String text) : super(text);
}

class EssayEvaluatorInputModel extends AgentInputModel {
  final String essay;

  const EssayEvaluatorInputModel(this.essay);

  @override
  Map<String, dynamic> toJson() => {'essay': essay};

  @override
  String buildPrompt() {
    return 'You are an essay evaluator. Review and provide feedback on this writing sample:\n$essay';
  }
}

class EssayEvaluatorOutputModel extends AgentOutputModel {
  const EssayEvaluatorOutputModel(String text) : super(text);
}

class PerformanceCoachInputModel extends AgentInputModel {
  final String focusArea;

  const PerformanceCoachInputModel(this.focusArea);

  @override
  Map<String, dynamic> toJson() => {'focusArea': focusArea};

  @override
  String buildPrompt() {
    return 'You are a performance coach for exam test takers. Give actionable advice for this concern:\n$focusArea';
  }
}

class PerformanceCoachOutputModel extends AgentOutputModel {
  const PerformanceCoachOutputModel(String text) : super(text);
}

class AgentDefinition {
  final AgentType type;
  final String displayName;
  final String systemPrompt;
  final double temperature;
  final int maxTokens;
  final AgentInputModel Function(String input) inputModelFactory;
  final AgentOutputModel Function(String text) outputModelFactory;

  const AgentDefinition({
    required this.type,
    required this.displayName,
    required this.systemPrompt,
    required this.temperature,
    required this.maxTokens,
    required this.inputModelFactory,
    required this.outputModelFactory,
  });
}

extension AgentTypeExtension on AgentType {
  String get displayName {
    switch (this) {
      case AgentType.tutor:
        return 'Tutor';
      case AgentType.studyPlanner:
        return 'Study Planner';
      case AgentType.questionGenerator:
        return 'Question Generator';
      case AgentType.answerExplainer:
        return 'Answer Explanation';
      case AgentType.vocabulary:
        return 'Vocabulary';
      case AgentType.essayEvaluator:
        return 'Essay Evaluator';
      case AgentType.performanceCoach:
        return 'Performance Coach';
    }
  }
}

class AgentFactory {
  static AgentDefinition create(AgentType type) {
    switch (type) {
      case AgentType.tutor:
        return const AgentDefinition(
          type: AgentType.tutor,
          displayName: 'Tutor Agent',
          systemPrompt:
              'You are SmartGo AI Tutor. Provide clear and supportive exam tutoring for IELTS, GRE, and GMAT students.',
          temperature: 0.7,
          maxTokens: 512,
          inputModelFactory: TutorInputModel.new,
          outputModelFactory: TutorOutputModel.new,
        );
      case AgentType.studyPlanner:
        return const AgentDefinition(
          type: AgentType.studyPlanner,
          displayName: 'Study Planner Agent',
          systemPrompt:
              'You are SmartGo AI Study Planner. Create study schedules, learning milestones, and structured exam preparation plans.',
          temperature: 0.6,
          maxTokens: 600,
          inputModelFactory: StudyPlannerInputModel.new,
          outputModelFactory: StudyPlannerOutputModel.new,
        );
      case AgentType.questionGenerator:
        return const AgentDefinition(
          type: AgentType.questionGenerator,
          displayName: 'Question Generator Agent',
          systemPrompt:
              'You are SmartGo AI Question Generator. Generate realistic practice questions for IELTS, GRE, and GMAT exam preparation.',
          temperature: 0.8,
          maxTokens: 600,
          inputModelFactory: QuestionGeneratorInputModel.new,
          outputModelFactory: QuestionGeneratorOutputModel.new,
        );
      case AgentType.answerExplainer:
        return const AgentDefinition(
          type: AgentType.answerExplainer,
          displayName: 'Answer Explanation Engine',
          systemPrompt:
              'You are SmartGo AI Answer Explanation Engine. Explain why the learner answer is incorrect and why the correct answer is correct, with concept explanation, revision notes, and similar questions.',
          temperature: 0.65,
          maxTokens: 700,
          inputModelFactory: AnswerExplanationInputModel.new,
          outputModelFactory: AnswerExplanationOutputModel.new,
        );
      case AgentType.vocabulary:
        return const AgentDefinition(
          type: AgentType.vocabulary,
          displayName: 'Vocabulary Agent',
          systemPrompt:
              'You are SmartGo AI Vocabulary Coach. Help students learn, practice, and remember high-value exam vocabulary.',
          temperature: 0.6,
          maxTokens: 450,
          inputModelFactory: VocabularyInputModel.new,
          outputModelFactory: VocabularyOutputModel.new,
        );
      case AgentType.essayEvaluator:
        return const AgentDefinition(
          type: AgentType.essayEvaluator,
          displayName: 'Essay Evaluator Agent',
          systemPrompt:
              'You are SmartGo AI Essay Evaluator. Provide constructive feedback, scoring guidance, and improvement suggestions.',
          temperature: 0.5,
          maxTokens: 700,
          inputModelFactory: EssayEvaluatorInputModel.new,
          outputModelFactory: EssayEvaluatorOutputModel.new,
        );
      case AgentType.performanceCoach:
        return const AgentDefinition(
          type: AgentType.performanceCoach,
          displayName: 'Performance Coach Agent',
          systemPrompt:
              'You are SmartGo AI Performance Coach. Help users strengthen confidence, time management, and test-taking strategy.',
          temperature: 0.65,
          maxTokens: 520,
          inputModelFactory: PerformanceCoachInputModel.new,
          outputModelFactory: PerformanceCoachOutputModel.new,
        );
    }
  }
}
