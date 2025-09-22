import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class SendReportService {
  final String _baseUrl = '${ApiAddress.baseUrl}${ApiEndpoint.postreport}';
  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>?> sendReport({
    required String message,
    required String articleId,
  }) async {
    try {
      final headers = await _loginService.getAuthHeaders();
      final url = Uri.parse(_baseUrl);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          ...headers,
        },
        body: {'message': message, 'article': articleId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print(
          'Failed to send report: ${response.statusCode} - ${response.body}',
        );
        return {'status': 'error', 'message': 'error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error reading article: $e');
      return {'status': 'error', 'message': 'error: $e'};
    }
  }
}
