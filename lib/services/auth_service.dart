import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/firebase_options.dart';

class AuthService {
  static final _firebaseAuth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();

  static bool get isFirebaseAvailable {
    try {
      final apiKey = DefaultFirebaseOptions.currentPlatform.apiKey;
      return !apiKey.contains('YOUR_') && apiKey.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
  static MockFirebaseUser? _mockCurrentUser;
  static final _userStreamController = StreamController<User?>.broadcast();

  /// Get current user
  static User? get currentUser {
    if (!isFirebaseAvailable) {
      return _mockCurrentUser;
    }
    try {
      return _firebaseAuth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Get user stream for auth state changes
  static Stream<User?> get userStream {
    if (!isFirebaseAvailable) {
      return _userStreamController.stream;
    }
    return _firebaseAuth.authStateChanges();
  }

  /// Email/Password Sign Up
  static Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isFirebaseAvailable) {
      final uid = 'mock_user_${DateTime.now().millisecondsSinceEpoch}';
      final user = MockFirebaseUser(uid: uid, email: email, displayName: email.split('@')[0]);
      _mockCurrentUser = user;
      _userStreamController.add(user);
      return user;
    }
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Email/Password Login
  static Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isFirebaseAvailable) {
      final uid = 'mock_user_${email.hashCode}';
      final user = MockFirebaseUser(uid: uid, email: email, displayName: email.split('@')[0]);
      _mockCurrentUser = user;
      _userStreamController.add(user);
      return user;
    }
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Google Sign-In
  static Future<User?> signInWithGoogle() async {
    if (!isFirebaseAvailable) {
      final uid = 'mock_google_user';
      final user = MockFirebaseUser(uid: uid, email: 'google@smartgo.ai', displayName: 'Google Student');
      _mockCurrentUser = user;
      _userStreamController.add(user);
      return user;
    }
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  static Future<void> logout() async {
    if (!isFirebaseAvailable) {
      _mockCurrentUser = null;
      _userStreamController.add(null);
      return;
    }
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  static Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (!isFirebaseAvailable) {
      if (_mockCurrentUser != null) {
        _mockCurrentUser = MockFirebaseUser(
          uid: _mockCurrentUser!.uid,
          email: _mockCurrentUser!.email,
          displayName: displayName ?? _mockCurrentUser!.displayName,
        );
        _userStreamController.add(_mockCurrentUser);
      }
      return;
    }
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      rethrow;
    }
  }
}

class MockFirebaseUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  MockFirebaseUser({required this.uid, this.email, this.displayName});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
