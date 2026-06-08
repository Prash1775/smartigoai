import 'package:cloud_firestore/cloud_firestore.dart';

class GeneratedNote {
  final String id;
  final String uid;
  final String title;
  final String content;
  final String sourceTopics;
  final DateTime createdAt;

  GeneratedNote({
    required this.id,
    required this.uid,
    required this.title,
    required this.content,
    required this.sourceTopics,
    required this.createdAt,
  });

  factory GeneratedNote.fromMap(Map<String, dynamic> map) {
    return GeneratedNote(
      id: map['id'] as String,
      uid: map['uid'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      sourceTopics: map['sourceTopics'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'content': content,
      'sourceTopics': sourceTopics,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
