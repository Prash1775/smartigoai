import 'package:cloud_firestore/cloud_firestore.dart';

class DailyTask {
  final String id;
  final String planId;
  final DateTime date;
  final String category;
  final String description;
  final int quantity;
  final bool completed;
  final DateTime createdAt;

  DailyTask({
    required this.id,
    required this.planId,
    required this.date,
    required this.category,
    required this.description,
    required this.quantity,
    this.completed = false,
    required this.createdAt,
  });

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      id: map['id'] as String,
      planId: map['planId'] as String,
      date: (map['date'] as Timestamp).toDate(),
      category: map['category'] as String,
      description: map['description'] as String,
      quantity: (map['quantity'] as num).toInt(),
      completed: map['completed'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planId': planId,
      'date': Timestamp.fromDate(date),
      'category': category,
      'description': description,
      'quantity': quantity,
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
