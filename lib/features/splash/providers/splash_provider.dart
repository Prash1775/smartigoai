import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashDelayProvider = FutureProvider<void>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
});
