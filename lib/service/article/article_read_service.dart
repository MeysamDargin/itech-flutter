import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class ArticleReadService {
  final String _baseUrl = '${ApiAddress.baseUrl}${ApiEndpoint.articleRead}';
  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>?> readArticle({
    required String article_id,
    required String source,
    required String device,
    required int duration,
    required int read_percentage,
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
        body: {
          'article_id': article_id,
          'source': source,
          'device': device,
          'duration': duration.toString(), // Convert to string
          'read_percentage': read_percentage.toString(), // Convert to string
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print(
          'Failed to read article: ${response.statusCode} - ${response.body}',
        );
        return {
          'status': 'error',
          'message': 'خطا در خواندن مقاله: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error reading article: $e');
      return {'status': 'error', 'message': 'خطا در خواندن مقاله: $e'};
    }
  }
}
