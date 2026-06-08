import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if keys are placeholders
  final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
  final isPlaceholder = apiKey.contains('YOUR_') || apiKey.isEmpty;

  if (!isPlaceholder) {
    // Initialize Firebase in the background so it does not block the UI startup
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((_) {
      debugPrint('Firebase initialized successfully');
    }).catchError((e) {
      debugPrint('Firebase initialization error: $e');
    });
  } else {
    debugPrint('Firebase placeholder keys detected. Running in offline simulation mode.');
  }

  runApp(const ProviderScope(child: SmartGoApp()));
}

class SmartGoApp extends ConsumerWidget {
  const SmartGoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SmartGo AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: goRouter,
    );
  }
}
