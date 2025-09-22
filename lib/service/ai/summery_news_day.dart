import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class SummeryNewsDay {
  // آدرس API خلاصه‌سازی
  static const String baseUrl =
      "${ApiAddress.aiUrl}${ApiEndpoint.newsDaySummarize}";

  Future<String?> summarizeArticle(String articleDelta) async {
    try {
      final Map<String, dynamic> payload = {"chatInput": articleDelta};

      print('Sending request to summarization API');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Received 200 OK from summarization API');
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final String summaryText = responseData["text"] ?? "";

          if (summaryText.trim().startsWith('[') &&
              summaryText.trim().endsWith(']')) {
            print('Response appears to be valid Delta JSON');
            return summaryText;
          } else {
            print(
              'Response is not valid Delta JSON, converting plain text to Delta',
            );
            final List<Map<String, dynamic>> delta = [
              {"insert": summaryText},
              {"insert": "\n"},
            ];
            return jsonEncode(delta);
          }
        } catch (parseError) {
          print('Error parsing API response: $parseError');
          print('Raw response: ${response.body}');

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
