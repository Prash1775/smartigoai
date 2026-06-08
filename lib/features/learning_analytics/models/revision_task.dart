import 'package:cloud_firestore/cloud_firestore.dart';

class RevisionTask {
  final String id;
  final String uid;
  final String topic;
  final String description;
  final DateTime dueDate;
  final String priority;
  final bool completed;
  final DateTime createdAt;

  RevisionTask({
    required this.id,
    required this.uid,
    required this.topic,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.completed = false,
    required this.createdAt,
  });

  factory RevisionTask.fromMap(Map<String, dynamic> map) {
    return RevisionTask(
      id: map['id'] as String,
      uid: map['uid'] as String,
      topic: map['topic'] as String,
      description: map['description'] as String,
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      priority: map['priority'] as String,
      completed: (map['completed'] as bool?) ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'topic': topic,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority,
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
