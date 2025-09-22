import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/models/article/article_recommended_model.dart';
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';

class RecommendedArticleService {
  final String _baseUrl =
      '${ApiAddress.baseUrl}${ApiEndpoint.recommendedArticleList}';
  final LoginService _loginService = LoginService();

  Future<ArticleRecommendedModel?> getRecommendedArticle() async {
    try {
      final headers = await _loginService.getAuthHeaders();

      final url = Uri.parse(_baseUrl);
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);

          return ArticleRecommendedModel.fromJson(data);
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
