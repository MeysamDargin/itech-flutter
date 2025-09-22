import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';

class CommentService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// ایجاد کامنت جدید
  Future<Map<String, dynamic>> createComment(
    String articleId,
    String message, {
    String? replyToId,
  }) async {
    if (message.isEmpty) {
      return {'status': 'error', 'message': 'Message cannot be empty'};
    }

    try {
      final String? sessionId = await _secureStorage.read(key: 'sessionid');
      if (sessionId == null) {
        return {'status': 'error', 'message': 'User not authenticated'};
      }

      // ساخت پارامترهای درخواست
      Map<String, String> formData = {
        'article_id': articleId,
        'message': message,
      };

      // اضافه کردن reply_to اگر وجود داشته باشد
      if (replyToId != null && replyToId.isNotEmpty) {
        formData['reply_to'] = replyToId;
      }

      // ارسال درخواست
      final response = await http.post(
        Uri.parse('${ApiAddress.baseUrl}${ApiEndpoint.commentCreate}'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': 'sessionid=$sessionId',
        },
        body: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Comment created successfully: $data');
        return {'status': 'success', 'data': data};
      } else {
        print('Error creating comment: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'status': 'error',
          'message': 'Failed to create comment',
          'code': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception creating comment: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// ارسال درخواست برای علامت‌گذاری کامنت‌ها به عنوان خوانده شده
  Future<Map<String, dynamic>> markCommentsAsSeen(
    String articleId,
    List<String> commentIds,
  ) async {
    if (commentIds.isEmpty) {
      return {'status': 'error', 'message': 'No comments to mark as seen'};
    }

    try {
      final String? sessionId = await _secureStorage.read(key: 'sessionid');
      if (sessionId == null) {
        return {'status': 'error', 'message': 'User not authenticated'};
      }

      // ساخت بدنه درخواست به صورت دستی برای پشتیبانی از آرایه‌ها
      final List<String> bodyParts = [];
      bodyParts.add('article_id=$articleId');

      // اضافه کردن آیدی کامنت‌ها با همان نام پارامتر
      for (String commentId in commentIds) {
        bodyParts.add('comment_ids=$commentId');
      }

      // ترکیب پارامترها با &
      String body = bodyParts.join('&');

      print('Request body: $body');

      // ارسال درخواست
      final response = await http.post(
        Uri.parse('${ApiAddress.baseUrl}/comments/seen/'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Cookie': 'sessionid=$sessionId',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Comments marked as seen: $commentIds');
        return {'status': 'success', 'data': data};
      } else {
        print('Error marking comments as seen: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'status': 'error',
          'message': 'Failed to mark comments as seen',
          'code': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception marking comments as seen: $e');
      return {'status': 'error', 'message': e.toString()};
    }
  }
}
