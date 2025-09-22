import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class CheckUsernameService {
  static Future<Map<String, dynamic>> checkUsername(String username) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiAddress.baseUrl}${ApiEndpoint.checkUsername}'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error in connection with server');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
