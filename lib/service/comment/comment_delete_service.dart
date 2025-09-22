import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class CommentDeleteService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// ایجاد کامنت جدید
  Future<Map<String, dynamic>> editeComment(String commentId) async {
    try {
      final String? sessionId = await _secureStorage.read(key: 'sessionid');
      if (sessionId == null) {
        return {'status': 'error', 'message': 'User not authenticated'};
      }

      // ارسال درخواست
      final response = await http.post(
        Uri.parse(
          '${ApiAddress.baseUrl}${ApiEndpoint.commentDelete}$commentId/',
        ),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': 'sessionid=$sessionId',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Comment Delete successfully: $data');
        return {'status': 'success', 'data': data};
      } else {
        print('Error Deleting comment: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'status': 'error',
          'message': 'Failed to deleted comment',
          'code': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception Deleting comment: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
