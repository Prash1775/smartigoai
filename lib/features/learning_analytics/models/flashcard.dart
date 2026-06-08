import 'package:cloud_firestore/cloud_firestore.dart';

class Flashcard {
  final String id;
  final String uid;
  final String front;
  final String back;
  final String category;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final int reviewCount;

  Flashcard({
    required this.id,
    required this.uid,
    required this.front,
    required this.back,
    required this.category,
    required this.createdAt,
    this.reviewedAt,
    this.reviewCount = 0,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      uid: map['uid'] as String,
      front: map['front'] as String,
      back: map['back'] as String,
      category: map['category'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reviewedAt: map['reviewedAt'] != null ? (map['reviewedAt'] as Timestamp).toDate() : null,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'front': front,
      'back': back,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewCount': reviewCount,
    };
  }
}
