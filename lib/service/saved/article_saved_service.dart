import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class ArticleSavedService {
  final String _baseUrl = '${ApiAddress.baseUrl}${ApiEndpoint.articleSave}';
  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>> saveArticle(
    String articleId, {
    String? directoryId,
  }) async {
    try {
      print(
        'Attempting to save article with ID: $articleId to directory: $directoryId',
      );
      final headers = await _loginService.getAuthHeaders();

      // Add Content-Type for consistency with backend expectations
      headers['Content-Type'] = 'application/x-www-form-urlencoded';

      print('Auth headers: $headers');

      // Format URL to match exactly with Django pattern: /articles/save/<article_id>/
      // Make sure there's no double slashes
      String urlString = _baseUrl;
      if (!urlString.endsWith('/')) urlString += '/';
      urlString += '$articleId/';

      final url = Uri.parse(urlString);
      print('Save URL: $url');

      // Create request body with directoryId if provided
      Map<String, String> body = {};
      if (directoryId != null) {
        body['directoryId'] = directoryId;
      }

      // Use a direct POST request as required by the backend
      final response = await http.post(
        url,
        headers: headers,
        body: body.isNotEmpty ? body : null,
      );

      print('Save response status: ${response.statusCode}');
      print('Save response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Article saved successfully');
        try {
          return json.decode(response.body);
        } catch (e) {
          print('Error parsing JSON response: $e');
          return {'status': 'success', 'message': 'Article saved successfully'};
        }
      } else {
        print(
          'Failed to save article: ${response.statusCode} - ${response.body}',
        );
        return {
          'status': 'error',
          'message': 'Error saving article: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Exception while saving article: $e');
      return {'status': 'error', 'message': 'Error saving article: $e'};
    }
  }
}
