import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static Future<void> initialize() async {
    try {
      // Flutter Firebase automatically finds GoogleService-Info.plist
      // if it's in ios/Runner/ and included in Xcode project
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        print('Firebase initialized successfully');
      } else {
        print('Firebase already initialized');
      }
    } catch (e) {
      print('Firebase initialization error: $e');
      print('Please ensure GoogleService-Info.plist is in ios/Runner/ and added to Xcode project');
      rethrow;
    }
  }

  static Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        await initialize();
      }
      
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please sign up first.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address. Please check your email.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Please contact support.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed login attempts. Please try again later.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message ?? e.code}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Handle platform-specific errors (like Pigeon type cast errors)
      if (e.toString().contains('Pigeon') || e.toString().contains('type cast')) {
        print('Sign in error (platform channel): $e');
        throw Exception('Authentication error. Please try again or restart the app.');
      }
      print('Sign in error: $e');
      rethrow;
    }
  }

  static Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Ensure Firebase is initialized
      if (Firebase.apps.isEmpty) {
        await initialize();
      }
      
      return await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email. Please sign in instead.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address. Please check your email.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Please choose a stronger password.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage = 'Sign up failed: ${e.message ?? e.code}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Handle platform-specific errors (like Pigeon type cast errors)
      if (e.toString().contains('Pigeon') || e.toString().contains('type cast')) {
        print('Sign up error (platform channel): $e');
        throw Exception('Authentication error. Please try again or restart the app.');
      }
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
