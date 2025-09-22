import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class ArticleLikeService {
  final String _baseUrl = '${ApiAddress.baseUrl}${ApiEndpoint.articleLike}';
  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>> likeArticle(String articleId) async {
    try {
      print('Attempting to like article with ID: $articleId');
      final headers = await _loginService.getAuthHeaders();

      // Add Content-Type for consistency with backend expectations
      headers['Content-Type'] = 'application/x-www-form-urlencoded';

      print('Auth headers: $headers');

      // Format URL to match exactly with Django pattern: /articles/delete/<article_id>/
      // Make sure there's no double slashes
      String urlString = _baseUrl;
      if (!urlString.endsWith('/')) urlString += '/';
      urlString += '$articleId/';

      final url = Uri.parse(urlString);
      print('Like URL: $url');

      // Use a direct POST request as required by the backend
      final response = await http.post(url, headers: headers);

      print('Like response status: ${response.statusCode}');
      print('Like response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Article liked successfully');
        try {
          return json.decode(response.body);
        } catch (e) {
          print('Error parsing JSON response: $e');
          return {'status': 'success', 'message': 'Article liked successfully'};
        }
      } else {
        print(
          'Failed to like article: ${response.statusCode} - ${response.body}',
        );
        return {
          'status': 'error',
          'message': 'Error liking article: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Exception while liking article: $e');
      return {'status': 'error', 'message': 'Error liking article: $e'};
    }
  }
}
