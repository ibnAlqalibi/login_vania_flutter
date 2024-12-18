import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const secureStorage = FlutterSecureStorage();

const String baseUrl =
    'http://192.168.234.234:8000/api'; 

// Future<Map<String, String>> getDefaultHeaders() async {
//   final accessToken = await secureStorage.read(key: 'access_token');
//   return {
//     'Content-Type': 'application/json',
//     if (accessToken != null) 'Authorization': 'Bearer $accessToken',
//   };
// }

Future<void> login(String email, String password) async {
  final url = Uri.parse('$baseUrl/auth/login');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final accessToken = data['token']['access_token'];

      await secureStorage.write(key: 'access_token', value: accessToken);
      print('Access token successfully stored!');
    } else {
      final error = json.decode(response.body);
      throw Exception('Login failed: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    throw Exception('Login failed: $e');
  }
}

Future<void> fetchProtectedData() async {
  final url = Uri.parse('$baseUrl/user/me');
  final accessToken = await secureStorage.read(key: 'access_token');

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      print('Data retrieved successfully: ${response.body}');
    } else if (response.statusCode == 401) {
      print('Invalid or expired access token. Please log in again.');
    } else {
      final error = json.decode(response.body);
      print('Error: ${error['message'] ?? 'Server error'}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}

Future<void> logout() async {
  await secureStorage.delete(key: 'access_token');
  print('Access token successfully deleted.');
}