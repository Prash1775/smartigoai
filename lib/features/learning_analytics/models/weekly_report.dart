import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyReport {
  final String id;
  final String uid;
  final DateTime weekStart;
  final DateTime weekEnd;
  final String summary;
  final int tasksCompleted;
  final int flashcardsReviewed;
  final double averageReadiness;
  final DateTime createdAt;

  WeeklyReport({
    required this.id,
    required this.uid,
    required this.weekStart,
    required this.weekEnd,
    required this.summary,
    required this.tasksCompleted,
    required this.flashcardsReviewed,
    required this.averageReadiness,
    required this.createdAt,
  });

  factory WeeklyReport.fromMap(Map<String, dynamic> map) {
    return WeeklyReport(
      id: map['id'] as String,
      uid: map['uid'] as String,
      weekStart: (map['weekStart'] as Timestamp).toDate(),
      weekEnd: (map['weekEnd'] as Timestamp).toDate(),
      summary: map['summary'] as String,
      tasksCompleted: (map['tasksCompleted'] as num).toInt(),
      flashcardsReviewed: (map['flashcardsReviewed'] as num).toInt(),
      averageReadiness: (map['averageReadiness'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'weekStart': Timestamp.fromDate(weekStart),
      'weekEnd': Timestamp.fromDate(weekEnd),
      'summary': summary,
      'tasksCompleted': tasksCompleted,
      'flashcardsReviewed': flashcardsReviewed,
      'averageReadiness': averageReadiness,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
