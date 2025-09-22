import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class SendArticleService {
  final String _baseUrl = '${ApiAddress.baseUrl}${ApiEndpoint.sendArticle}';
  final LoginService _loginService = LoginService();

  Future<Map<String, dynamic>?> createArticle({
    required String title,
    required String text,
    required String delta,
    required File imgCover,
    required String category,
  }) async {
    try {
      final headers = await _loginService.getAuthHeaders();
      final url = Uri.parse(_baseUrl);

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);

      request.fields['title'] = title;
      request.fields['text'] = text;
      request.fields['delta'] = delta;
      request.fields['category'] = category;

      var coverFile = await http.MultipartFile.fromPath(
        'imgCover',
        imgCover.path,
      );
      request.files.add(coverFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print(
          'Failed to create article: ${response.statusCode} - ${response.body}',
        );
        return {
          'status': 'error',
          'message': 'خطا در ایجاد مقاله: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error creating article: $e');
      return {'status': 'error', 'message': 'خطا در ارسال مقاله: $e'};
    }
  }
}
