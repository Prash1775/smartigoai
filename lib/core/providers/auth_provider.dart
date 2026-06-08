import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/exam_types.dart';

// Stream provider for Firebase auth state
final authStreamProvider = StreamProvider<User?>((ref) {
  return AuthService.userStream;
});

// State notifier for auth state
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.loading()) {
    checkAuthState();
  }

  Future<void> signupWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      state = const AuthState.loading();
      
      // Sign up with Firebase
      final user = await AuthService.signUpWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        // Create user in Firestore with default values
        // User will complete onboarding to select exam and target score
        final smartGoUser = SmartGoUser(
          uid: user.uid,
          name: name,
          email: email,
          examType: ExamType.ielts.displayName,
          targetScore: ExamType.ielts.defaultTargetScore,
          studyStreak: 0,
          readinessScore: 0.0,
          createdAt: Timestamp.now(),
          isOnboarded: false,
        );

        await FirestoreService.createUser(smartGoUser);

        state = AuthState.authenticated(smartGoUser);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = const AuthState.loading();

      // Login with Firebase
      final user = await AuthService.loginWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        // Get user from Firestore
        final smartGoUser = await FirestoreService.getUser(user.uid);

        if (smartGoUser != null) {
          state = AuthState.authenticated(smartGoUser);
        } else {
          state = const AuthState.error('User profile not found. Please sign up first.');
        }
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      state = const AuthState.loading();

      final user = await AuthService.signInWithGoogle();

      if (user != null) {
        // Check if user exists in Firestore
        var smartGoUser = await FirestoreService.getUser(user.uid);

        // If not exists, create new user
        if (smartGoUser == null) {
          smartGoUser = SmartGoUser(
            uid: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            examType: ExamType.ielts.displayName,
            targetScore: ExamType.ielts.defaultTargetScore,
            studyStreak: 0,
            readinessScore: 0.0,
            createdAt: Timestamp.now(),
            isOnboarded: false,
          );
          await FirestoreService.createUser(smartGoUser);
        }

        state = AuthState.authenticated(smartGoUser);
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> checkAuthState() async {
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final smartGoUser = await FirestoreService.getUser(user.uid);
        if (smartGoUser != null) {
          state = AuthState.authenticated(smartGoUser);
        } else {
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  void loginWithDemoUser() {
    final demoUser = SmartGoUser(
      uid: 'demo_user_123',
      name: 'Demo Student',
      email: 'student@smartgo.ai',
      examType: ExamType.ielts.displayName,
      targetScore: ExamType.ielts.defaultTargetScore,
      studyStreak: 5,
      readinessScore: 82.0,
      createdAt: Timestamp.now(),
      isOnboarded: true,
    );
    state = AuthState.authenticated(demoUser);
  }
}

sealed class AuthState {
  const AuthState();

  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.authenticated(SmartGoUser user) = Authenticated;
  const factory AuthState.loading() = Loading;
  const factory AuthState.error(String message) = Error;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticated extends AuthState {
  final SmartGoUser user;
  const Authenticated(this.user);
}

class Loading extends AuthState {
  const Loading();
}

class Error extends AuthState {
  final String message;
  const Error(this.message);
}
