/// A single practice question with 4 options, the correct answer index, and an AI explanation.
class PracticeQuestion {
  final String questionText;
  final List<String> options; // 4 options: A, B, C, D
  final int correctIndex; // 0-based index of the correct option
  final String explanation; // Why it's correct / why the others are wrong

  PracticeQuestion({
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory PracticeQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    // Normalise correctAnswer: could be 0-based int OR a letter string like "A","B"
    int correctIdx = 0;
    final raw = json['correctAnswer'];
    if (raw is int) {
      correctIdx = raw;
    } else if (raw is String) {
      final letter = raw.toUpperCase().trim();
      const letters = ['A', 'B', 'C', 'D'];
      final idx = letters.indexOf(letter);
      correctIdx = idx >= 0 ? idx : 0;
    }

    return PracticeQuestion(
      questionText: json['question']?.toString() ?? '',
      options: rawOptions,
      correctIndex: correctIdx,
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

/// Enum for the three practice modes
enum PracticeMode { topicQuiz, weakAreaReview, mockTest }

extension PracticeModeName on PracticeMode {
  String get displayName {
    switch (this) {
      case PracticeMode.topicQuiz:
        return 'Topic Quiz';
      case PracticeMode.weakAreaReview:
        return 'Weak Area Review';
      case PracticeMode.mockTest:
        return 'Full Mock Test';
    }
  }
}
