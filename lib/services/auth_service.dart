import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/dashboard_model.dart';

class AuthService {
  static const String baseUrl = "https://md-panel.invisofts.in";
  static final ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);
  static final ValueNotifier<int> notificationCountNotifier =
      ValueNotifier<int>(0);

  Future<DashboardData?> getDashboardData() async {
    try {
      final token = await getToken();
      print("Fetching dashboard data with token: $token");

      final url = "$baseUrl/api/dashboard";
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      print("POST Request: $url");
      print("Headers: $headers");

      final response = await http.post(Uri.parse(url), headers: headers);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final dashboard = DashboardData.fromJson(data['data']);
          notificationCountNotifier.value = dashboard.notificationCount;
          return dashboard;
        }
      } else {
        print("Failed to fetch dashboard: ${response.body}");
      }
      return null;
    } catch (e) {
      print("Error fetching dashboard data: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = "$baseUrl/api/login";
      final body = {'email': email, 'password': password};
      print("POST Request: $url");
      print("Payload: $body");

      final response = await http.post(Uri.parse(url), body: body);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['auth_token']);
        await prefs.setString('user_data', json.encode(data['data']['user']));

        final user = User.fromJson(data['data']['user']);
        userNotifier.value = user;

        return {'status': true, 'message': data['message'], 'user': user};
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
      final url = "$baseUrl/api/register";
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'gender': gender,
      };
      print("POST Request: $url");
      print("Payload: $body");

      final response = await http.post(Uri.parse(url), body: body);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

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

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final url = "$baseUrl/api/forgot-password";
      final body = {'email': email};
      print("POST Request: $url");
      print("Payload: $body");

      final response = await http.post(Uri.parse(url), body: body);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final data = json.decode(response.body);

      return {
        'status': data['status'] == true,
        'message': data['message'] ?? "Password reset request failed",
      };
    } catch (e) {
      print("Error in forgotPassword: $e");
      return {'status': false, 'message': "An error occurred: $e"};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
    required String bio,
    required String profession,
    required String address,
    required String dob,
    File? image,
  }) async {
    try {
      final token = await getToken();

      final url = "$baseUrl/api/update-profile";
      var request = http.MultipartRequest('POST', Uri.parse(url));

      print("POST Multipart Request: $url");

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['phone'] = phone;
      request.fields['gender'] = gender;
      request.fields['bio'] = bio;
      request.fields['profession'] = profession;
      request.fields['address'] = address;
      request.fields['dob'] = dob;

      print("Fields: ${request.fields}");

      if (image != null) {
        print("Uploading Image: ${image.path}");
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        // Update local user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(data['data']['user']));

        final user = User.fromJson(data['data']['user']);
        userNotifier.value = user;

        return {'status': true, 'message': data['message'], 'user': user};
      } else {
        return {'status': false, 'message': data['message'] ?? "Update failed"};
      }
    } catch (e) {
      return {'status': false, 'message': "An error occurred: $e"};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    userNotifier.value = null;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      final user = User.fromJson(json.decode(userData));
      userNotifier.value = user;
      return user;
    }
    userNotifier.value = null;
    return null;
  }

  Future<List<CategoryModel>> getCategoriesList() async {
    try {
      final token = await getToken();
      final url = "$baseUrl/api/categories-list";
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      print("POST Request: $url");
      print("Headers: $headers");

      final response = await http.post(Uri.parse(url), headers: headers);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return (data['data'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPrivacyPolicy() async {
    try {
      final url = "$baseUrl/api/privacy-policy";
      print("GET Request: $url");

      final response = await http.get(Uri.parse(url));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching privacy policy: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTermsConditions() async {
    try {
      final url = "$baseUrl/api/term-and-condition";
      print("GET Request: $url");

      final response = await http.get(Uri.parse(url));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error fetching terms and conditions: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> toggleFavorite(int designId) async {
    try {
      final token = await getToken();
      final url = "$baseUrl/api/toggle-favorite";
      final body = {'design_id': designId.toString()};

      print("POST Request: $url");
      print("Payload: $body");
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      print("Headers: $headers");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      final data = json.decode(response.body);
      return {
        'status': data['status'] == true,
        'message': data['message'] ?? "Action failed",
      };
    } catch (e) {
      print("Error toggling favorite: $e");
      return {'status': false, 'message': "An error occurred: $e"};
    }
  }

  Future<List<DesignModel>> getFavorites() async {
    try {
      final token = await getToken();
      final url = "$baseUrl/api/my-favorites";

      print("POST Request: $url");
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      print("Headers: $headers");

      final response = await http.post(Uri.parse(url), headers: headers);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return (data['data'] as List)
              .map((e) => DesignModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching favorites: $e");
      return [];
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final token = await getToken();
      final url = "$baseUrl/api/notification-list";

      print("POST Request: $url");
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      print("Headers: $headers");

      final response = await http.post(Uri.parse(url), headers: headers);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return (data['data'] as List)
              .map((e) => NotificationModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }

  Future<List<SubCategoryModel>> getSubCategoriesList(int categoryId) async {
    try {
      final token = await getToken();
      final url = "$baseUrl/api/sub-categories-list";
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      final body = {'category_id': categoryId.toString()};

      print("POST Request: $url");
      print("Payload: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return (data['data'] as List)
              .map((e) => SubCategoryModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching sub-categories: $e");
      return [];
    }
  }

  Future<List<DesignModel>> getDesignsList({
    int? categoryId,
    int? subCategoryId,
  }) async {
    try {
      final token = await getToken();
      final url = "$baseUrl/api/designs-list";
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };
      final body = <String, String>{};
      if (categoryId != null) body['category_id'] = categoryId.toString();
      if (subCategoryId != null) {
        body['sub_category_id'] = subCategoryId.toString();
      }

      print("POST Request: $url");
      print("Payload: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          return (data['data'] as List)
              .map((e) => DesignModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching designs: $e");
      return [];
    }
  }
}
