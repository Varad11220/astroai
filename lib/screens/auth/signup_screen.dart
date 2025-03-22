import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import 'otp_screen.dart';
import '../../services/email_service.dart';
import 'dart:math';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;

  void _sendOtp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    if (password != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must accept the terms')));
      return;
    }

    int otp = generateOtp();
    bool isSent = await sendOtpEmail(email, otp);

    if (isSent) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Sent Successfully')));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpScreen(email: email, otp: otp)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send OTP')));
    }
  }

  int generateOtp() {
    final random = Random();
    return 100000 + random.nextInt(900000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomTextField(controller: _emailController, hintText: 'Email'),
            const SizedBox(height: 16),
            CustomTextField(controller: _passwordController, hintText: 'Password', isPassword: true),
            const SizedBox(height: 16),
            CustomTextField(controller: _confirmPasswordController, hintText: 'Confirm Password', isPassword: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                ),
                const Expanded(child: Text('I accept the terms and conditions')),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(text: 'Send OTP', onPressed: _sendOtp),
          ],
        ),
      ),
    );
  }
}
