// screens/auth/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String password;

  OtpScreen({required this.email, required this.password});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  late final DatabaseReference _database;

  @override
  void initState() {
    super.initState();
    // Initialize database with explicit URL to ensure correct region
    _database = FirebaseDatabase.instance.ref();

    // Set database persistence to true to enable offline capabilities
    FirebaseDatabase.instance.setPersistenceEnabled(true);
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://emailer3.onrender.com/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': widget.email, 'otp': _otpController.text}),
      );

      if (response.statusCode == 200) {
        // Save user data to Firebase Realtime Database
        await _saveUserToFirebase();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP Verified. Account created successfully!'),
          ),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final errorResponse = json.decode(response.body);
        String errorMessage =
            errorResponse['error'] ?? 'Invalid OTP. Please try again.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserToFirebase() async {
    try {
      // Create a unique user ID based on email (or you could use a UUID)
      String userId = widget.email.replaceAll('.', '_').replaceAll('@', '_');

      // Print debug information
      print('Attempting to save user data to Firebase path: users/$userId');

      // Save user data to users/{userId} in the Realtime Database
      await _database.child('users').child(userId).set({
        'email': widget.email,
        'password': widget.password,
        'createdAt': DateTime.now().toIso8601String(),
      });

      print('Successfully saved user data to Firebase');
    } catch (e) {
      print('Error saving user to Firebase: ${e.toString()}');
      // Handle error but don't stop the flow
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('An OTP has been sent to ${widget.email}'),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _verifyOtp,
                  child: Text('Verify OTP'),
                ),
          ],
        ),
      ),
    );
  }
}
