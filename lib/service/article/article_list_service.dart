import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/models/article/article_list_model.dart';
import 'package:itech/service/auth/login_service.dart';

class ArticleService {
  final String _baseUrl = '${ApiAddress.baseUrl}${ApiEndpoint.articleList}';
  final LoginService _loginService = LoginService();

  // Fetch articles from the API
  Future<ArticleListModel?> getArticles() async {
    try {
      print('Fetching articles from: $_baseUrl');

      // Get auth headers with session ID
      final headers = await _loginService.getAuthHeaders();
      print('Auth headers: $headers');

      final url = Uri.parse(_baseUrl);
      final response = await http.get(url, headers: headers);

      print('Article list response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Article list response received successfully');

        try {
          final data = json.decode(response.body);
          print('Article list response parsed successfully');
          print('Article count: ${data["articles"]?.length ?? "unknown"}');

          // لاگ کردن بخشی از ریسپانس برای بررسی
          final String truncatedResponse =
              response.body.length > 500
                  ? '${response.body.substring(0, 500)}... (truncated)'
                  : response.body;
          print('Article list response (truncated): $truncatedResponse');

          return ArticleListModel.fromJson(data);
        } catch (parseError) {
          print('Error parsing article list response: $parseError');
          print('Raw response: ${response.body}');
          return null;
        }
      } else {
        print(
          'Failed to fetch articles: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching articles: $e');
      return null;
    }
  }
}
