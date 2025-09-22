import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class SearchService {
  final LoginService _loginService = LoginService();

  // Changed return type to dynamic to handle Map response
  Future<dynamic> sendQuery({required String query}) async {
    try {
      final String _baseUrl =
          '${ApiAddress.baseUrl}${ApiEndpoint.getSearch}?q=$query';
      final headers = await _loginService.getAuthHeaders();
      final url = Uri.parse(_baseUrl);

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("Search response: $decoded");
        return decoded; // Return the actual response (Map in your case)
      } else {
        print('Failed to search: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('خطا در جستجو: $e');
      return null;
    }
  }
}
