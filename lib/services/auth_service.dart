import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/firebase_config.dart';

/// AuthService uses ReptiGram Firebase for authentication
/// Authentication is handled through ReptiGram's Firebase project
/// This allows users to log in with their existing ReptiGram credentials
class AuthService extends ChangeNotifier {
  // Use default Firebase app (ReptiGram) for authentication
  FirebaseAuth get _auth => FirebaseAuth.instanceFor(
    app: Firebase.app(FirebaseConfig.defaultAppName),
  );
  
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  /// Get user data from Firebase Auth user
  /// Note: This extracts data from the authenticated user (ReptiGram Firebase)
  /// We don't store user data in Firestore since we only use ReptiGram for auth
  Map<String, dynamic>? get userData {
    final user = currentUser;
    if (user == null) return null;
    
    return {
      'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
      'email': user.email ?? '',
      'uid': user.uid,
      'photoURL': user.photoURL,
    };
  }

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new user account in ReptiGram Firebase
  /// Note: This creates accounts in ReptiGram's Firebase project, not RepFiles
  Future<void> createUserWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name in ReptiGram Firebase Auth
      if (userCredential.user != null && name.isNotEmpty) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sign in with Google using ReptiGram Firebase
  /// Note: This authenticates users with Google through ReptiGram's Firebase project
  /// Compatible with both Web PWA and Android mobile
  Future<void> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('Starting Google Sign-In... (Platform: ${kIsWeb ? 'Web' : 'Android'})');
      }

      if (kIsWeb) {
        // For Web PWA: Use Firebase Auth's native Google Sign-In (same as ReptiGram)
        // This uses Firebase Auth's web implementation which handles OAuth natively
        // No need for google_sign_in package on web - Firebase Auth handles it all
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        
        if (kDebugMode) {
          print('Using Firebase Auth native Google Sign-In for web (same as ReptiGram)...');
        }

        // Firebase Auth web uses signInWithPopup internally via the web implementation
        // This is the native method that ReptiGram uses - no People API needed
        await _auth.signInWithPopup(googleProvider);
        
        if (kDebugMode) {
          print('Google Sign-In successful via Firebase Auth native!');
        }
      } else {
        // For Android: Use google_sign_in package (works well on mobile)
        // Must provide serverClientId (OAuth 2.0 Web Client ID) for Firebase Auth integration
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId: FirebaseConfig.googleWebClientId,
        );

        if (kDebugMode) {
          print('Using google_sign_in package for Android...');
        }

        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          if (kDebugMode) {
            print('Google Sign-In cancelled by user');
          }
          return;
        }

        if (kDebugMode) {
          print('Google Sign-In account obtained: ${googleUser.email}');
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        if (kDebugMode) {
          print('Google authentication tokens obtained');
        }

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        if (kDebugMode) {
          print('Signing in to Firebase with Google credential...');
        }

        // Sign in to Firebase with the Google credential
        await _auth.signInWithCredential(credential);

        if (kDebugMode) {
          print('Google Sign-In successful!');
        }
      }

      // The auth state listener will automatically update the UI
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In error: $e');
        print('Error type: ${e.runtimeType}');
        if (e is FirebaseAuthException) {
          print('Firebase Auth Error Code: ${e.code}');
          print('Firebase Auth Error Message: ${e.message}');
        } else if (e.toString().contains('ApiException: 10')) {
          print('⚠️ DEVELOPER_ERROR (10): This usually means:');
          print('   1. SHA-1 fingerprint is not registered in Firebase Console');
          print('   2. Package name mismatch');
          print('   3. OAuth client not configured correctly');
          print('   SHA-1 to register: EF:C5:C4:AE:3A:DF:A6:DA:9E:63:D8:0D:2F:88:9E:44:85:1A:F4:74');
          print('   Package name: com.example.repfiles_firestore');
          print('   Make sure both are registered in ReptiGram Firebase (reptigramfirestore) project');
        }
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
} 