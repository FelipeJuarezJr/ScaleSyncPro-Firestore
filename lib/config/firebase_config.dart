import 'package:firebase_core/firebase_core.dart';

/// Firebase Configuration for dual Firebase setup
/// - ReptiGram Firebase: Used for authentication only
/// - RepFiles Firebase: Used for all data operations (Firestore, Storage)

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

  // RepFiles Firebase - Data storage (Firestore & Storage)
  static const FirebaseOptions repFilesData = FirebaseOptions(
    apiKey: 'AIzaSyBq4XiO6Ivp5eCuZtLWeBHmXF19kjtA_X4',
    appId: '1:551254748034:web:532aba0df880b84542fd9b',
    messagingSenderId: '551254748034',
    projectId: 'repfiles-prototype',
    authDomain: 'repfiles-prototype.firebaseapp.com',
    storageBucket: 'repfiles-prototype.firebasestorage.app',
  );

  // App names for Firebase instances
  static const String reptiGramAppName = 'reptiGramAuth';
  static const String repFilesAppName = 'repFilesData';
  static const String defaultAppName = '[DEFAULT]';
}

