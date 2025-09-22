import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class AnalysisService {
  // آدرس API آنالیز مقاله
  static const String baseUrl = "${ApiAddress.aiUrl}${ApiEndpoint.aiAnalysis}";

  // متد ارسال درخواست آنالیز و دریافت پاسخ
  Future<String?> analyzeArticle(String articleText) async {
    try {
      print('Sending request to analysis API');

      // ساخت payload درخواست - ارسال متن خام مقاله
      final Map<String, dynamic> payload = {"chatInput": articleText};

      // ارسال درخواست به سرور
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      // بررسی وضعیت پاسخ
      if (response.statusCode == 200) {
        print('Received 200 OK from analysis API');
        try {
          // دریافت و پردازش پاسخ
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String analysisText = responseData["output"] ?? "";

          print('Analysis received successfully');
          return analysisText;
        } catch (parseError) {
          print('Error parsing API response: $parseError');
          print('Raw response: ${response.body}');

          return "Error parsing analysis response. Please try again.";
        }
      } else {
        print(
          'Error from analysis API: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error connecting to analysis API: $e');
      return null;
    }
  }
}
