import 'package:cloud_firestore/cloud_firestore.dart';

class VocabularyEntry {
  final String id;
  final String uid;
  final String word;
  final String meaning;
  final String example;
  final bool mastered;
  final DateTime createdAt;

  VocabularyEntry({
    required this.id,
    required this.uid,
    required this.word,
    required this.meaning,
    required this.example,
    required this.mastered,
    required this.createdAt,
  });

  factory VocabularyEntry.fromMap(Map<String, dynamic> map) {
    return VocabularyEntry(
      id: map['id'] as String,
      uid: map['uid'] as String,
      word: map['word'] as String,
      meaning: map['meaning'] as String,
      example: map['example'] as String,
      mastered: (map['mastered'] as bool?) ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'word': word,
      'meaning': meaning,
      'example': example,
      'mastered': mastered,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
