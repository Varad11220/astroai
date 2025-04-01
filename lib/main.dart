import 'package:flutter/material.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_completion_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Print the current database URL to verify
    print(
      'Using database URL: ${DefaultFirebaseOptions.currentPlatform.databaseURL}',
    );
  } catch (e) {
    print('Error initializing Firebase: ${e.toString()}');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _isLoggedIn = false;
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthService.isUserLoggedIn();
    bool isProfileComplete = false;

    if (isLoggedIn) {
      isProfileComplete = await AuthService.isProfileComplete();
    }

    setState(() {
      _isLoggedIn = isLoggedIn;
      _isProfileComplete = isProfileComplete;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PAC',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(backgroundColor: Colors.indigo, elevation: 0),
      ),
      initialRoute: _getInitialRoute(),
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileCompletionScreen(),
      },
    );
  }

  String _getInitialRoute() {
    if (!_initialized) {
      // Show loading screen
      return '/';
    }

    if (!_isLoggedIn) {
      // User is not logged in, go to login screen
      return '/login';
    }

    if (!_isProfileComplete) {
      // User is logged in but profile is incomplete
      return '/profile';
    }

    // User is logged in and has a complete profile
    return '/home';
  }
}
