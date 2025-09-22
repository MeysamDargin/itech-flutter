import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/models/article/article_detail_model.dart';
import 'package:itech/service/auth/login_service.dart';

class ArticleDetailService {
  final String _baseUrl = '${ApiAddress.baseUrl}${ApiEndpoint.articleDetail}';
  final LoginService _loginService = LoginService();

  // Fetch article details from the API
  Future<ArticleDetailModel?> getArticleDetail(String articleId) async {
    try {
      // Get auth headers with session ID
      final headers = await _loginService.getAuthHeaders();

      final url = Uri.parse('$_baseUrl$articleId');
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("fffdata: $data");
        return ArticleDetailModel.fromJson(data);
      } else {
        print(
          'Failed to fetch article details: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error fetching article details: $e');
      return null;
    }
  }
}
