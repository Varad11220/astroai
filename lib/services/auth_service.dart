import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String userLoggedInKey = 'isLoggedIn';
  static const String userEmailKey = 'userEmail';
  static const String userIdKey = 'userId';

  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedInKey) ?? false;
  }

  // Get current user email
  static Future<String?> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  // Get current user ID
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  // Save login information
  static Future<void> saveUserLoginInfo(String email) async {
    final prefs = await SharedPreferences.getInstance();
    String userId = email.replaceAll('.', '_').replaceAll('@', '_');

    await prefs.setBool(userLoggedInKey, true);
    await prefs.setString(userEmailKey, email);
    await prefs.setString(userIdKey, userId);
  }

  // Check if user profile is complete
  static Future<bool> isProfileComplete() async {
    final userId = await getCurrentUserId();
    if (userId == null) return false;

    try {
      final snapshot = await _database.child('users').child(userId).get();
      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        return userData['accountStatus'] == 1;
      }
      return false;
    } catch (e) {
      print('Error checking profile completion: ${e.toString()}');
      return false;
    }
  }

  // Get user profile data
  static Future<Map?> getUserProfile() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    try {
      final snapshot = await _database.child('users').child(userId).get();
      if (snapshot.exists) {
        return snapshot.value as Map;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: ${e.toString()}');
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile({
    required String fullName,
    required String dateOfBirth,
    String? timeOfBirth,
    String? placeOfBirth,
  }) async {
    final userId = await getCurrentUserId();
    if (userId == null) return false;

    try {
      await _database.child('users').child(userId).update({
        'fullName': fullName,
        'dateOfBirth': dateOfBirth,
        'timeOfBirth': timeOfBirth ?? '',
        'placeOfBirth': placeOfBirth ?? '',
        'accountStatus': 1,
        'profileCompletedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating user profile: ${e.toString()}');
      return false;
    }
  }

  // Sign up with email and password
  static Future<Map<String, dynamic>> signUp(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://emailer3.onrender.com/api/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'OTP sent successfully'};
      } else {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'message': errorResponse['error'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String password,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://emailer3.onrender.com/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        // Save user to Firebase
        await _saveUserToFirebase(email, password);

        // Save login state
        await saveUserLoginInfo(email);

        return {'success': true, 'message': 'OTP verified successfully'};
      } else {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'message': errorResponse['error'] ?? 'Invalid OTP',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Login with email and password
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      String userId = email.replaceAll('.', '_').replaceAll('@', '_');

      // Check if user exists in Firebase
      DataSnapshot snapshot =
          await _database.child('users').child(userId).get();

      if (snapshot.exists) {
        Map userData = snapshot.value as Map;

        // Verify password
        if (userData['password'] == password) {
          // Save login state
          await saveUserLoginInfo(email);

          return {
            'success': true,
            'message': 'Login successful',
            'profileComplete': userData['accountStatus'] == 1,
          };
        } else {
          return {'success': false, 'message': 'Invalid password'};
        }
      } else {
        return {'success': false, 'message': 'User not found. Please sign up.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(userLoggedInKey, false);
    await prefs.remove(userEmailKey);
    await prefs.remove(userIdKey);
  }

  // Save user to Firebase
  static Future<void> _saveUserToFirebase(String email, String password) async {
    try {
      String userId = email.replaceAll('.', '_').replaceAll('@', '_');

      await _database.child('users').child(userId).set({
        'email': email,
        'password': password,
        'accountStatus': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving user to Firebase: ${e.toString()}');
    }
  }
}
