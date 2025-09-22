import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class HistorySearchService {
  // Changed return type to dynamic to handle both List and Map responses
  static Future<dynamic> getSearchHistory() async {
    final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

    try {
      final String? sessionId = await _secureStorage.read(key: 'sessionid');
      if (sessionId == null) {
        return {'status': 'error', 'message': 'User not authenticated'};
      }

      final response = await http.get(
        Uri.parse('${ApiAddress.baseUrl}${ApiEndpoint.getSearchHistory}'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': 'sessionid=$sessionId',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);
        final decodedResponse = json.decode(response.body);

        // Return the actual decoded response (could be List or Map)
        return decodedResponse;
      } else {
        throw Exception('Error in connection with server');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
