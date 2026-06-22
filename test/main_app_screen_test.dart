import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scalesync_pro_ecosystem/screens/main_app_screen.dart';
import 'package:scalesync_pro_ecosystem/screens/auth/login_screen.dart';
import 'package:scalesync_pro_ecosystem/services/auth_service.dart';
import 'package:scalesync_pro_ecosystem/services/theme_service.dart';

class FakeUser implements User {
  @override
  final String uid;
  @override
  final String? displayName;
  @override
  final String? email;

  FakeUser({required this.uid, this.displayName, this.email});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends ChangeNotifier implements AuthService {
  bool _authenticated = false;
  Map<String, dynamic>? _userData;
  User? _currentUser;

  void setAuthenticated(bool val, {Map<String, dynamic>? data}) {
    _authenticated = val;
    _userData = data;
    if (val) {
      _currentUser = FakeUser(
        uid: 'test_uid_123',
        displayName: data?['name'] ?? 'Test User',
        email: data?['email'] ?? 'test@example.com',
      );
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }

  @override
  User? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  Map<String, dynamic>? get userData => _userData;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {}

  @override
  Future<void> createUserWithEmailAndPassword(String name, String email, String password) async {}

  @override
  Future<void> signOut() async {
    setAuthenticated(false);
  }

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> resetPassword(String email) async {}
}

class MockThemeService extends ChangeNotifier implements ThemeService {
  @override
  bool get isDarkMode => true;

  @override
  Future<void> toggleTheme() async {}

  @override
  Future<void> setThemeMode(bool isDark) async {}
}

void main() {
  late MockAuthService mockAuthService;
  late MockThemeService mockThemeService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockThemeService = MockThemeService();
  });

  testWidgets('MainAppScreen redirects unauthenticated user to LoginScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Force unauthenticated state
    mockAuthService.setAuthenticated(false);

    await tester.pumpWidget(
      ProviderScope(
        child: legacy_provider.MultiProvider(
          providers: [
            legacy_provider.ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
            legacy_provider.ChangeNotifierProvider<ThemeService>.value(value: mockThemeService),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaleFactor: 0.6),
              child: MainAppScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Verify we are redirected to LoginScreen (showing "Welcome Back" and "Sign in to manage your reptile collection")
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to manage your reptile collection'), findsOneWidget);
  });

  testWidgets('MainAppScreen renders dashboard for authenticated user', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Force authenticated state
    mockAuthService.setAuthenticated(true, data: {'name': 'Pro Breeder', 'email': 'pro@scalesync.com'});

    await tester.pumpWidget(
      ProviderScope(
        child: legacy_provider.MultiProvider(
          providers: [
            legacy_provider.ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
            legacy_provider.ChangeNotifierProvider<ThemeService>.value(value: mockThemeService),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaleFactor: 0.6),
              child: MainAppScreen(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Verify MainAppScreen itself is shown, containing the Pro badge and user name
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Pro Breeder'), findsOneWidget);
    expect(find.text('Pro'), findsOneWidget);
  });
}
