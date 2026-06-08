import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartgo_ai/models/user_model.dart';

void main() {
  test('SmartGoUser copyWith updates onboarding details', () {
    final user = SmartGoUser(
      uid: 'user-1',
      name: 'Priya',
      email: 'priya@example.com',
      examType: 'IELTS',
      targetScore: 7,
      studyStreak: 0,
      readinessScore: 0,
      createdAt: Timestamp.fromDate(DateTime(2026, 1, 1)),
    );

    final updated = user.copyWith(
      examType: 'GRE',
      targetScore: 320,
      isOnboarded: true,
    );

    expect(updated.uid, 'user-1');
    expect(updated.examType, 'GRE');
    expect(updated.targetScore, 320);
    expect(updated.isOnboarded, isTrue);
  });
}
