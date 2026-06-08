import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides app-level state and configuration
final appStateProvider = StateProvider<AppState>((ref) {
  return AppState();
});

class AppState {
  final bool isDarkMode;
  final String locale;

  AppState({
    this.isDarkMode = false,
    this.locale = 'en',
  });

  AppState copyWith({
    bool? isDarkMode,
    String? locale,
  }) {
    return AppState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
    );
  }
}
