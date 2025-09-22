import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class ChatBotArticle {
  // آدرس API آنالیز مقاله
  static const String baseUrl = "${ApiAddress.aiUrl}${ApiEndpoint.aiChat}";

  // متد ارسال درخواست آنالیز و دریافت پاسخ
  Future<String?> chatBotArticle(
    String message,
    String articleText,
    int userId,
  ) async {
    try {
      print('Sending request to chat bot article API');

      // ساخت payload درخواست - ارسال متن خام مقاله
      final Map<String, dynamic> payload = {
        "message": message,
        "article": articleText,
        "userId": userId,
      };

      // ارسال درخواست به سرور
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      // بررسی وضعیت پاسخ
      if (response.statusCode == 200) {
        try {
          // دریافت و پردازش پاسخ
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String analysisText = responseData["output"] ?? "";
          print("responseData: $responseData");
          return analysisText;
        } catch (parseError) {
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
