import 'package:flutter/material.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Signup',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => SignupScreen());
        } else if (settings.name == '/otp') {
          // We're now handling OTP navigation directly in the signup screen
          // using MaterialPageRoute instead of named routes
          return null;
        } else if (settings.name == '/login') {
          // We'll implement this later
          return MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  appBar: AppBar(title: Text('Login')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Login Screen - Coming Soon'),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed('/home');
                          },
                          child: Text('Proceed to Home'),
                        ),
                      ],
                    ),
                  ),
                ),
          );
        } else if (settings.name == '/home') {
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        }
        // If no match was found, show 404
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                appBar: AppBar(title: Text('Page Not Found')),
                body: Center(child: Text('Route ${settings.name} not found')),
              ),
        );
      },
    );
  }
}
