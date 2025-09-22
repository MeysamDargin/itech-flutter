import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class VerifyCodeService {
  static Future<Map<String, dynamic>> verifyCode(
    String email,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiAddress.baseUrl}${ApiEndpoint.verifyOtpCode}'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'otp': otp},
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      // حالت‌های مختلف پاسخ
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          // اگر پاسخ خالی است (مثل تأیید OTP)
          return {'success': true};
        } else {
          // اگر پاسخ JSON دارد (مثل ارسال مجدد کد)
          try {
            final decoded = json.decode(response.body);
            return decoded is Map
                ? decoded.cast<String, dynamic>()
                : {'success': true};
          } on FormatException {
            return {'success': true, 'message': response.body};
          }
        }
      } else {
        // پردازش خطاها
        final error =
            response.body.isNotEmpty
                ? json.decode(response.body)['error'] ?? 'Invalid OTP'
                : 'Server error';
        throw Exception(error);
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Verification failed: ${e.toString()}');
    }
  }
}
