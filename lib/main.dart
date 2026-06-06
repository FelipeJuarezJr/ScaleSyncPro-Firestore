import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/firebase_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_app_screen.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // On Android, google-services.json auto-initializes Firebase with [DEFAULT] app
    // On Web, we need to initialize manually
    // Try to initialize [DEFAULT] app, catch duplicate error if Android already did it
    try {
      await Firebase.initializeApp(
        name: FirebaseConfig.defaultAppName,
        options: FirebaseConfig.reptiGramAuth,
      );
      debugPrint('✅ [DEFAULT] Firebase app initialized: ${FirebaseConfig.reptiGramAuth.projectId}');
    } catch (e) {
      // If duplicate app error, Android auto-initialized it from google-services.json
      if (e.toString().contains('duplicate-app') || e.toString().contains('[DEFAULT]')) {
        debugPrint('✅ [DEFAULT] Firebase app already initialized by Android (from google-services.json)');
      } else {
        // Different error, rethrow it
        debugPrint('❌ Error initializing [DEFAULT] app: $e');
        rethrow;
      }
    }
    
    // Initialize RepFiles Firebase (secondary app for data storage)
    try {
      await Firebase.initializeApp(
        name: FirebaseConfig.repFilesAppName,
        options: FirebaseConfig.repFilesData,
      );
      debugPrint('✅ RepFiles Firebase app initialized: ${FirebaseConfig.repFilesData.projectId}');
    } catch (e) {
      // If duplicate app error (shouldn't happen, but handle it)
      if (e.toString().contains('duplicate-app')) {
        debugPrint('✅ RepFiles Firebase app already exists');
      } else {
        debugPrint('❌ Error initializing RepFiles app: $e');
        rethrow;
      }
    }
    
    debugPrint('✅ All Firebase apps initialized successfully');
    debugPrint('Total Firebase apps: ${Firebase.apps.length}');
    for (var app in Firebase.apps) {
      debugPrint('  - ${app.name}: ${app.options.projectId}');
    }
  } catch (e, stackTrace) {
    // If Firebase initialization fails with unexpected error, print and rethrow
    debugPrint('❌ Unexpected Firebase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
  
  await SharedPreferences.getInstance();
  
  debugPrint('🚀 Starting RepFiles app...');
  runApp(const ProviderScope(child: RepFilesApp()));
}

class RepFilesApp extends StatelessWidget {
  const RepFilesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return legacy_provider.MultiProvider(
      providers: [
        legacy_provider.ChangeNotifierProvider(create: (_) => AuthService()),
        legacy_provider.ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: legacy_provider.Consumer2<AuthService, ThemeService>(
        builder: (context, authService, themeService, child) {
          return MaterialApp(
            title: 'RepFiles',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: authService.isAuthenticated 
                ? const MainAppScreen() 
                : const LoginScreen(),
          );
        },
      ),
    );
  }
} 