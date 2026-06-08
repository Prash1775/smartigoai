enum ExamType { ielts, gre, gmat }

extension ExamTypeExtension on ExamType {
  String get displayName {
    return switch (this) {
      ExamType.ielts => 'IELTS',
      ExamType.gre => 'GRE',
      ExamType.gmat => 'GMAT',
    };
  }

  String get description {
    return switch (this) {
      ExamType.ielts => 'International English Language Testing System',
      ExamType.gre => 'Graduate Record Examination',
      ExamType.gmat => 'Graduate Management Admission Test',
    };
  }

  int get defaultTargetScore {
    return switch (this) {
      ExamType.ielts => 7,
      ExamType.gre => 320,
      ExamType.gmat => 700,
    };
  }
}
