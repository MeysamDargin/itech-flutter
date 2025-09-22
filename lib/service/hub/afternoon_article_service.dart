import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/models/hub/morning_article_model.dart'; // مدل جدید
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class AfternoonArticleService {
  final String _baseUrl =
      '${ApiAddress.baseUrl}${ApiEndpoint.afternoonArticleList}';
  final LoginService _loginService = LoginService();

  Future<NewsDayArticleModel?> getAfternoonArticles() async {
    try {
      final headers = await _loginService.getAuthHeaders();
      final url = Uri.parse(_baseUrl);
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return NewsDayArticleModel.fromJson(data); // مدل درست اینجا
        } catch (parseError) {
          print('Error parsing afternoon articles response: $parseError');
          print('Raw response: ${response.body}');
          return null;
        }
      } else {
        print(
          'Failed to fetch afternoon articles: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching afternoon articles: $e');
      return null;
    }
  }
}
