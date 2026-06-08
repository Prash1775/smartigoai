import 'package:cloud_firestore/cloud_firestore.dart';

class Scholarship {
  final String id;
  final String name;
  final String universityId;
  final String universityName;
  final double amount;
  final String currency;
  final String deadline;
  final List<String> eligibility;
  final String description;
  final String applicationUrl;
  final DateTime createdAt;

  Scholarship({
    required this.id,
    required this.name,
    required this.universityId,
    required this.universityName,
    required this.amount,
    required this.currency,
    required this.deadline,
    required this.eligibility,
    required this.description,
    required this.applicationUrl,
    required this.createdAt,
  });

  factory Scholarship.fromMap(Map<String, dynamic> map) {
    return Scholarship(
      id: map['id'] as String,
      name: map['name'] as String,
      universityId: map['universityId'] as String,
      universityName: map['universityName'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      deadline: map['deadline'] as String,
      eligibility: List<String>.from(map['eligibility'] as List),
      description: map['description'] as String,
      applicationUrl: map['applicationUrl'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'universityId': universityId,
      'universityName': universityName,
      'amount': amount,
      'currency': currency,
      'deadline': deadline,
      'eligibility': eligibility,
      'description': description,
      'applicationUrl': applicationUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
