import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> sendOtpEmail(String recipient, int otp) async {
  final url = Uri.parse('https://emailer3.onrender.com/send-otp-email');

  final data = {'recipient': recipient, 'otp': otp.toString()};

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('OTP sent successfully!');
      return true;
    } else {
      print('Failed to send OTP: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}
