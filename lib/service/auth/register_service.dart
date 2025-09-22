import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class RegisterService {
  static Future<Map<String, dynamic>> register(
    String email,
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiAddress.baseUrl}${ApiEndpoint.registerUser}',
        ), // مطمئن شوید endpoint صحیح است
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'username': username, 'password': password},
      );

      print('Register Status: ${response.statusCode}');
      print('Register Response: ${response.body}');

      if (response.statusCode == 200) {
        try {
          return json.decode(response.body);
        } on FormatException {
          return {'message': 'Registration successful'};
        }
      } else if (response.statusCode == 400) {
        final error =
            json.decode(response.body)['error'] ?? 'Registration failed';
        throw Exception(error);
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }
}
