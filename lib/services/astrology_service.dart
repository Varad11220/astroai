import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AstrologyService {
  static final String _baseUrl = ApiConfig.baseUrl;

  // Send a query to the astrology API
  static Future<String?> sendAstrologyQuery(
    String query,
    Map<String, dynamic>? userProfile,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/api/astrology/insight');

      // Get the birth details from the user profile if available
      String? birthDate;
      String? birthTime;
      String? birthPlace;
      String? userId;

      if (userProfile != null) {
        birthDate = userProfile['dateOfBirth'];
        birthTime = userProfile['timeOfBirth'];
        birthPlace = userProfile['placeOfBirth'];
        userId = userProfile['id'];
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': query,
          'birthDate': birthDate,
          'birthTime': birthTime,
          'birthPlace': birthPlace,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        print('Error from API: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error sending astrology query: $e');
      return null;
    }
  }
}
