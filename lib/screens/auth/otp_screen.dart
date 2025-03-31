// screens/auth/otp_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

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

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.verifyOtp(
        widget.email,
        widget.password,
        _otpController.text,
      );

      if (result['success']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
        // After successful verification, redirect to profile completion
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
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
