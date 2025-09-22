import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/models/article/article_breaking_model.dart';
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class BreakingArticleService {
  final String _baseUrl =
      '${ApiAddress.baseUrl}${ApiEndpoint.breakingArticleList}';
  final LoginService _loginService = LoginService();

  Future<ArticleBreakingModel?> getBreakingArticle() async {
    try {
      final headers = await _loginService.getAuthHeaders();

      final url = Uri.parse(_baseUrl);
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          return ArticleBreakingModel.fromJson(data);
        } catch (parseError) {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
