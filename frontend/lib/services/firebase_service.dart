import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Future<void> initialize() async {
    // Note: Firebase configuration files need to be added manually
    // For now, we'll try to initialize with default options
    // In production, you should add google-services.json and GoogleService-Info.plist
    try {
      await Firebase.initializeApp();
    } catch (e) {
      // If Firebase is not configured, this will fail
      // User needs to add configuration files
      print('Firebase initialization error: $e');
      print('Please add Firebase configuration files');
    }
  }

  static Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  static Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    // Google Sign-In implementation would go here
    // Requires additional setup with google_sign_in package
    throw UnimplementedError('Google Sign-In not yet implemented');
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static User? get currentUser => auth.currentUser;

  static Stream<User?> get authStateChanges => auth.authStateChanges();

  static Future<String?> getIdToken() async {
    final user = auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }
}
