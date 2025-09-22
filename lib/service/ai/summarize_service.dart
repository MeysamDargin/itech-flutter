import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class SummarizeService {
  // آدرس API خلاصه‌سازی
  static const String baseUrl = "${ApiAddress.aiUrl}${ApiEndpoint.aiSummarize}";

  // متد ارسال درخواست خلاصه‌سازی و دریافت پاسخ
  Future<String?> summarizeArticle(String articleDelta) async {
    try {
      // ساخت payload درخواست - ارسال Delta به جای HTML
      final Map<String, dynamic> payload = {"chatInput": articleDelta};

      print('Sending request to summarization API');

      // ارسال درخواست به سرور
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      // بررسی وضعیت پاسخ
      if (response.statusCode == 200) {
        print('Received 200 OK from summarization API');
        try {
          // دریافت و پردازش پاسخ
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String summaryText = responseData["text"] ?? "";

          // اطمینان از اینکه پاسخ یک JSON معتبر است
          // اگر پاسخ یک Delta JSON نیست، آن را به فرمت Delta JSON تبدیل می‌کنیم
          if (summaryText.trim().startsWith('[') &&
              summaryText.trim().endsWith(']')) {
            print('Response appears to be valid Delta JSON');
            return summaryText;
          } else {
            print(
              'Response is not valid Delta JSON, converting plain text to Delta',
            );
            // تبدیل متن ساده به Delta JSON
            final List<Map<String, dynamic>> delta = [
              {"insert": summaryText},
              {"insert": "\n"},
            ];
            return jsonEncode(delta);
          }
        } catch (parseError) {
          print('Error parsing API response: $parseError');
          print('Raw response: ${response.body}');

          // در صورت خطا در پارس کردن، یک Delta JSON ساده با پیام خطا برمی‌گردانیم
          final List<Map<String, dynamic>> errorDelta = [
            {"insert": "Error parsing summary response. Please try again."},
            {"insert": "\n"},
          ];
          return jsonEncode(errorDelta);
        }
      } else {
        print(
          'Error from summarization API: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error connecting to summarization API: $e');
      return null;
    }
  }
}
