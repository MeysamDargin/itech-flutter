import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class FollowService {
  static Future<Map<String, dynamic>> followService(String user_id) async {
    final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

    try {
      final String? sessionId = await _secureStorage.read(key: 'sessionid');
      if (sessionId == null) {
        return {'status': 'error', 'message': 'User not authenticated'};
      }
      final response = await http.post(
        Uri.parse('${ApiAddress.baseUrl}${ApiEndpoint.following}'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': 'sessionid=$sessionId',
        },
        body: {'user_id': user_id},
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
