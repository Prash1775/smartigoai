import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/exam_types.dart';

final selectedExamProvider = StateProvider<ExamType?>((ref) {
  return null;
});

final examListProvider = Provider((ref) {
  return ExamType.values;
});
