import 'package:cloud_firestore/cloud_firestore.dart';

class SmartGoUser {
  final String uid;
  final String name;
  final String email;
  final String examType;
  final int targetScore;
  final int studyStreak;
  final double readinessScore;
  final bool isOnboarded;
  final Timestamp createdAt;

  // New onboarding fields
  final String currentLevel; // 'beginner', 'intermediate', 'advanced'
  final String? examDate; // ISO 8601 date string e.g. '2026-09-15'
  final List<String> weakAreas; // e.g. ['Reading', 'Writing']
  final int dailyStudyMinutes; // e.g. 30, 60, 120
  final Map<String, dynamic>? studyPlan; // AI-generated study plan JSON
  final List<String> completedSyllabusTopics;
  final Map<String, String> customSyllabusVideos;

  SmartGoUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.examType,
    required this.targetScore,
    required this.studyStreak,
    required this.readinessScore,
    required this.createdAt,
    this.isOnboarded = false,
    this.currentLevel = 'beginner',
    this.examDate,
    this.weakAreas = const [],
    this.dailyStudyMinutes = 60,
    this.studyPlan,
    this.completedSyllabusTopics = const [],
    this.customSyllabusVideos = const {},
  });

  factory SmartGoUser.fromMap(Map<String, dynamic> map) {
    return SmartGoUser(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      examType: map['examType'] as String,
      targetScore: (map['targetScore'] as num).toInt(),
      studyStreak: (map['studyStreak'] as num).toInt(),
      readinessScore: (map['readinessScore'] as num).toDouble(),
      createdAt: map['createdAt'] as Timestamp,
      isOnboarded: (map['isOnboarded'] as bool?) ?? false,
      currentLevel: (map['currentLevel'] as String?) ?? 'beginner',
      examDate: map['examDate'] as String?,
      weakAreas: (map['weakAreas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dailyStudyMinutes: (map['dailyStudyMinutes'] as num?)?.toInt() ?? 60,
      studyPlan: map['studyPlan'] as Map<String, dynamic>?,
      completedSyllabusTopics: (map['completedSyllabusTopics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      customSyllabusVideos: (map['customSyllabusVideos'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value.toString()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'examType': examType,
      'targetScore': targetScore,
      'studyStreak': studyStreak,
      'readinessScore': readinessScore,
      'createdAt': createdAt,
      'isOnboarded': isOnboarded,
      'currentLevel': currentLevel,
      'examDate': examDate,
      'weakAreas': weakAreas,
      'dailyStudyMinutes': dailyStudyMinutes,
      'studyPlan': studyPlan,
      'completedSyllabusTopics': completedSyllabusTopics,
      'customSyllabusVideos': customSyllabusVideos,
    };
  }

  SmartGoUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? examType,
    int? targetScore,
    int? studyStreak,
    double? readinessScore,
    bool? isOnboarded,
    Timestamp? createdAt,
    String? currentLevel,
    String? examDate,
    List<String>? weakAreas,
    int? dailyStudyMinutes,
    Map<String, dynamic>? studyPlan,
    List<String>? completedSyllabusTopics,
    Map<String, String>? customSyllabusVideos,
  }) {
    return SmartGoUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      examType: examType ?? this.examType,
      targetScore: targetScore ?? this.targetScore,
      studyStreak: studyStreak ?? this.studyStreak,
      readinessScore: readinessScore ?? this.readinessScore,
      createdAt: createdAt ?? this.createdAt,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      currentLevel: currentLevel ?? this.currentLevel,
      examDate: examDate ?? this.examDate,
      weakAreas: weakAreas ?? this.weakAreas,
      dailyStudyMinutes: dailyStudyMinutes ?? this.dailyStudyMinutes,
      studyPlan: studyPlan ?? this.studyPlan,
      completedSyllabusTopics: completedSyllabusTopics ?? this.completedSyllabusTopics,
      customSyllabusVideos: customSyllabusVideos ?? this.customSyllabusVideos,
    );
  }

  /// Calculate days remaining until exam
  int? get daysUntilExam {
    if (examDate == null) return null;
    try {
      final exam = DateTime.parse(examDate!);
      final now = DateTime.now();
      return exam.difference(now).inDays;
    } catch (_) {
      return null;
    }
  }
}
