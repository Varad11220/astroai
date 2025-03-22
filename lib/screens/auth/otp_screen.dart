import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final int otp;

  const OtpScreen({Key? key, required this.email, required this.otp}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  void _verifyOtp() {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the OTP')));
      return;
    }

    if (int.tryParse(_otpController.text) == widget.otp) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Verified Successfully')));
      // TODO: Navigate to home screen or next step
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'An OTP has been sent to ${widget.email}. Please check your email and verify it.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: _otpController, hintText: 'Enter OTP'),
            const SizedBox(height: 16),
            CustomButton(text: 'Verify OTP', onPressed: _verifyOtp),
          ],
        ),
      ),
    );
  }
}
