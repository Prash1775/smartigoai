import 'package:cloud_firestore/cloud_firestore.dart';

class Achievement {
  final String id;
  final String uid;
  final String title;
  final String description;
  final String category;
  final int points;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.category,
    required this.points,
    required this.unlockedAt,
  });

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      uid: map['uid'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      points: (map['points'] as num).toInt(),
      unlockedAt: (map['unlockedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'category': category,
      'points': points,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
    };
  }
}
