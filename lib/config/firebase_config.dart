import 'package:firebase_core/firebase_core.dart';

/// Firebase Configuration for dual Firebase setup
/// - ReptiGram Firebase: Used for authentication only
/// - ScaleSyncPro Firebase: Used for all data operations (Firestore, Storage)

class FirebaseConfig {
  // ReptiGram Firebase - Authentication only
  static const FirebaseOptions reptiGramAuth = FirebaseOptions(
    apiKey: 'AIzaSyDiT-1kdubTNYLe2waeCIYvGDx5nakKyh0',
    appId: '1:373955522567:web:7163187c33d378455bbaa2',
    messagingSenderId: '373955522567',
    projectId: 'reptigramfirestore',
    authDomain: 'reptigramfirestore.firebaseapp.com',
    storageBucket: 'reptigramfirestore.firebasestorage.app',
    measurementId: 'G-H7FDWLXW64',
  );

  // Google OAuth Web Client ID for Google Sign-In on Web PWA
  // This can be found in Firebase Console > Authentication > Sign-in method > Google
  // Or in Google Cloud Console > APIs & Services > Credentials > OAuth 2.0 Client IDs
  // For web application type
  static const String googleWebClientId = '373955522567-qr8497a63r5g1dn6nn5hufmluldrp1kl.apps.googleusercontent.com';

  // ScaleSyncPro Firebase - Data storage (Firestore & Storage)
  static const FirebaseOptions scaleSyncProData = FirebaseOptions(
    apiKey: 'AIzaSyCgE2e8RPN0JOWR8MFA1HTfDos3qmmkmEg',
    appId: '1:123833527982:web:36b21425fc1127c290473f',
    messagingSenderId: '123833527982',
    projectId: 'scalesync-pro',
    authDomain: 'scalesync-pro.firebaseapp.com',
    storageBucket: 'scalesync-pro.firebasestorage.app',
    measurementId: 'G-9BCWD33SRY',
  );

  // App names for Firebase instances
  static const String reptiGramAppName = 'reptiGramAuth';
  static const String scaleSyncProAppName = 'scaleSyncProData';
  static const String defaultAppName = '[DEFAULT]';
}

