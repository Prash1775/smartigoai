import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String id;
  final String uid;
  final String plan;
  final double monthlyPrice;
  final String status;
  final DateTime startDate;
  final DateTime expiryDate;
  final List<String> features;
  final bool autoRenew;

  Subscription({
    required this.id,
    required this.uid,
    required this.plan,
    required this.monthlyPrice,
    required this.status,
    required this.startDate,
    required this.expiryDate,
    required this.features,
    required this.autoRenew,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] as String,
      uid: map['uid'] as String,
      plan: map['plan'] as String,
      monthlyPrice: (map['monthlyPrice'] as num).toDouble(),
      status: map['status'] as String,
      startDate: (map['startDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      features: List<String>.from(map['features'] as List),
      autoRenew: (map['autoRenew'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'plan': plan,
      'monthlyPrice': monthlyPrice,
      'status': status,
      'startDate': Timestamp.fromDate(startDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'features': features,
      'autoRenew': autoRenew,
    };
  }
}
