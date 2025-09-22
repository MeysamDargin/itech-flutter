import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class LanguageService {
  // آدرس API خلاصه‌سازی
  static const String baseUrl = "${ApiAddress.aiUrl}${ApiEndpoint.aiLanguage}";

  // متد ارسال درخواست خلاصه‌سازی و دریافت پاسخ
  Future<String?> languageArticle(String articleDelta, String language) async {
    try {
      // ساخت payload درخواست - ارسال Delta به جای HTML
      final Map<String, dynamic> payload = {
        "chatInput": articleDelta,
        "lang": language,
      };

      print('Sending Delta for summarization: $articleDelta');

      // ارسال درخواست به سرور
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      // بررسی وضعیت پاسخ
      if (response.statusCode == 200) {
        // دریافت و پردازش پاسخ
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Received summary response: ${responseData["text"]}');
        return responseData["text"];
      } else {
        print('خطا در خلاصه‌سازی: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('خطای ارتباط با سرور: $e');
      return null;
    }
  }
}
