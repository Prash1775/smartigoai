import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String uid;
  final String subscriptionId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String transactionId;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.uid,
    required this.subscriptionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.transactionId,
    required this.createdAt,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      uid: map['uid'] as String,
      subscriptionId: map['subscriptionId'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      status: map['status'] as String,
      paymentMethod: map['paymentMethod'] as String,
      transactionId: map['transactionId'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'subscriptionId': subscriptionId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
