import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = "https://md-panel.invisofts.in";

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/login"),
        body: {'email': email, 'password': password},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['auth_token']);
        await prefs.setString('user_data', json.encode(data['data']['user']));

        return {
          'status': true,
          'message': data['message'],
          'user': User.fromJson(data['data']['user']),
        };
      } else {
        return {'status': false, 'message': data['message'] ?? "Login failed"};
      }
    } catch (e) {
      return {'status': false, 'message': "An error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/register"),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'gender': gender,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // As per requirement, don't auto-login here.
        return {
          'status': true,
          'message': data['message'] ?? "Registered Successfully!",
        };
      } else {
        return {
          'status': false,
          'message': data['message'] ?? "Registration failed",
        };
      }
    } catch (e) {
      return {'status': false, 'message': "An error occurred: $e"};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return User.fromJson(json.decode(userData));
    }
    return null;
  }
}
