import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReport {
  final String id;
  final String uid;
  final DateTime date;
  final String summary;
  final int eventsLogged;
  final double readinessScore;
  final int vocabularyLearned;
  final DateTime createdAt;

  DailyReport({
    required this.id,
    required this.uid,
    required this.date,
    required this.summary,
    required this.eventsLogged,
    required this.readinessScore,
    required this.vocabularyLearned,
    required this.createdAt,
  });

  factory DailyReport.fromMap(Map<String, dynamic> map) {
    return DailyReport(
      id: map['id'] as String,
      uid: map['uid'] as String,
      date: (map['date'] as Timestamp).toDate(),
      summary: map['summary'] as String,
      eventsLogged: (map['eventsLogged'] as num).toInt(),
      readinessScore: (map['readinessScore'] as num).toDouble(),
      vocabularyLearned: (map['vocabularyLearned'] as num).toInt(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'date': Timestamp.fromDate(date),
      'summary': summary,
      'eventsLogged': eventsLogged,
      'readinessScore': readinessScore,
      'vocabularyLearned': vocabularyLearned,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
