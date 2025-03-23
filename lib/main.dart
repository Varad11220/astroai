import 'package:flutter/material.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
          // Extract the email that we passed
          final email = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => OtpScreen(email: email));
        } else if (settings.name == '/login') {
          // We'll implement this later
          return MaterialPageRoute(
            builder:
                (_) => Scaffold(
                  appBar: AppBar(title: Text('Login')),
                  body: Center(child: Text('Login Screen - Coming Soon')),
                ),
          );
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
