import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String id;
  final String uid;
  final String displayName;
  final String examType;
  final int points;
  final int mockTestsCompleted;
  final DateTime updatedAt;

  LeaderboardEntry({
    required this.id,
    required this.uid,
    required this.displayName,
    required this.examType,
    required this.points,
    required this.mockTestsCompleted,
    required this.updatedAt,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      id: map['id'] as String,
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      examType: map['examType'] as String,
      points: (map['points'] as num).toInt(),
      mockTestsCompleted: (map['mockTestsCompleted'] as num).toInt(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'displayName': displayName,
      'examType': examType,
      'points': points,
      'mockTestsCompleted': mockTestsCompleted,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
