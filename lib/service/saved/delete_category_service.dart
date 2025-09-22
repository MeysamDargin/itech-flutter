import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class DeleteCategoryService {
  final String _baseUrl =
      '${ApiAddress.baseUrl}${ApiEndpoint.deleteSaveDirectory}';
  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>?> deleteSaveDirectory({
    required String directoryId,
  }) async {
    try {
      final headers = await _loginService.getAuthHeaders();
      // Add directoryId to the URL
      final url = Uri.parse('$_baseUrl$directoryId/');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          ...headers,
        },
      );

      print('delete response status: ${response.statusCode}');
      print('delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print(
          'Failed to delete save directory: ${response.statusCode} - ${response.body}',
        );
        return {'status': 'error', 'message': 'error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error updating directory: $e');
      return {'status': 'error', 'message': 'error: $e'};
    }
  }
}
