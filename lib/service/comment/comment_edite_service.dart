import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class CommentEditeService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// ایجاد کامنت جدید
  Future<Map<String, dynamic>> editeComment(
    String message,
    String commentId,
  ) async {
    if (message.isEmpty) {
      return {'status': 'error', 'message': 'Message cannot be empty'};
    }

    try {
      final String? sessionId = await _secureStorage.read(key: 'sessionid');
      if (sessionId == null) {
        return {'status': 'error', 'message': 'User not authenticated'};
      }

      // ساخت پارامترهای درخواست
      Map<String, String> formData = {'message': message};

      // ارسال درخواست
      final response = await http.post(
        Uri.parse(
          '${ApiAddress.baseUrl}${ApiEndpoint.commentEdite}$commentId/',
        ),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': 'sessionid=$sessionId',
        },
        body: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Comment updated successfully: $data');
        return {'status': 'success', 'data': data};
      } else {
        print('Error updating comment: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'status': 'error',
          'message': 'Failed to updated comment',
          'code': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception updating comment: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
