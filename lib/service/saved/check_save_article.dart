import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class CheckSaveArticle {
  static Future<Map<String, dynamic>> checkSaveArticle(String articleId) async {
    final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

    try {
      final String? sessionId = await _secureStorage.read(key: 'sessionid');
      if (sessionId == null) {
        return {'status': 'error', 'message': 'User not authenticated'};
      }

      // Format URL to include article ID
      String url = '${ApiAddress.baseUrl}${ApiEndpoint.checkSaveArticle}';
      if (!url.endsWith('/')) url += '/';
      url += '$articleId/';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': 'sessionid=$sessionId',
        },
      );

      if (response.statusCode == 200) {
        print('Check save response: ${response.body}');
        return json.decode(response.body);
      } else {
        print('Check save error: ${response.statusCode} - ${response.body}');
        return {
          'status': 'error',
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Check save exception: $e');
      return {'status': 'error', 'message': 'Error: ${e.toString()}'};
    }
  }
}
