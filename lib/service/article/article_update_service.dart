import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class ArticleUpdateService {
  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>?> updateArticle({
    required String articleId,
    required String title,
    required String text,
    required String delta,
    File? imgCover,
    required String category,
  }) async {
    try {
      // Get auth headers with session ID
      final headers = await _loginService.getAuthHeaders();

      // Create multipart request
      final url = Uri.parse(
        '${ApiAddress.baseUrl}${ApiEndpoint.articleUpdate}$articleId/',
      );
      final request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll(headers);

      // Add text fields
      request.fields['title'] = title;
      request.fields['text'] = text;
      request.fields['delta'] = delta;
      request.fields['category'] = category;

      // Add image file if provided
      if (imgCover != null) {
        final imageStream = http.ByteStream(imgCover.openRead());
        final imageLength = await imgCover.length();

        final multipartFile = http.MultipartFile(
          'imgCover',
          imageStream,
          imageLength,
          filename: imgCover.path.split('/').last,
        );

        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
          'Error updating article: ${response.statusCode} - ${response.body}',
        );
        return {
          'status': 'error',
          'message': 'Failed to update article: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Exception while updating article: $e');
      return {'status': 'error', 'message': 'Exception: $e'};
    }
  }
}
