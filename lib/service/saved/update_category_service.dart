import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class UpdateCategoryService {
  final String _baseUrl =
      '${ApiAddress.baseUrl}${ApiEndpoint.updateSaveDirectory}';
  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>?> updateSaveDirectory({
    required String name,
    required String directoryId,
  }) async {
    try {
      final headers = await _loginService.getAuthHeaders();
      // Add directoryId to the URL
      final url = Uri.parse('$_baseUrl$directoryId/');

      print('Updating save directory: $url');
      print('New name: $name');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          ...headers,
        },
        body: {'name': name},
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print(
          'Failed to update save directory: ${response.statusCode} - ${response.body}',
        );
        return {'status': 'error', 'message': 'error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error updating directory: $e');
      return {'status': 'error', 'message': 'error: $e'};
    }
  }
}
