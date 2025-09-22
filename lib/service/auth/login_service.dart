import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart'; // اضافه کردن پکیج
import 'package:itech/service/websocket_manager_service.dart';

class LoginService {
  final String _baseUrl =
      '${ApiAddress.baseUrl}${ApiEndpoint.login}'; // آدرس پایه سرور

  // ایجاد نمونه از FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // متد ورود
  Future<bool> login(String username, String password) async {
    final url = Uri.parse(_baseUrl); // آدرس لاگین API

    try {
      // ارسال درخواست POST با فرمت form-data مناسب برای جنگو
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username, 'password': password},
      );

      // بررسی وضعیت پاسخ
      if (response.statusCode == 200) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Response headers: ${response.headers}');

        try {
          final responseData = json.decode(response.body);
          // بررسی وضعیت کاربر جدید
          if (responseData['newUser'] != null) {
            await _secureStorage.write(
              key: 'newUser',
              value: responseData['newUser'].toString(),
            );
            print('newUser value set to: ${responseData['newUser']}');
          } else if (responseData['is_new_user'] != null) {
            await _secureStorage.write(
              key: 'newUser',
              value: responseData['is_new_user'].toString(),
            );
            print('newUser value set to: ${responseData['is_new_user']}');
          } else {
            // اگر هیچ اطلاعاتی در مورد جدید بودن کاربر نبود، فرض می‌کنیم کاربر جدید نیست
            await _secureStorage.write(key: 'newUser', value: 'false');
            print('No newUser info in response, defaulting to false');
          }
        } catch (e) {
          print('Error parsing response JSON: $e');
          // در صورت خطا در پارس کردن JSON، فرض می‌کنیم کاربر جدید نیست
          await _secureStorage.write(key: 'newUser', value: 'false');
        }

        // ذخیره توکن‌ها در FlutterSecureStorage
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          final sessionIdMatch = RegExp(
            r'sessionid=([^;]+)',
          ).firstMatch(cookies);
          if (sessionIdMatch != null && sessionIdMatch.groupCount >= 1) {
            final sessionId = sessionIdMatch.group(1);
            if (sessionId != null) {
              await _secureStorage.write(key: 'sessionid', value: sessionId);
              print('Session ID stored: $sessionId');
              return true;
            }
          }
        }

        // اگر در هدرها session ID پیدا نشد، سعی می‌کنیم از body بخوانیم (احتمالاً نخواهد بود)
        try {
          final data = jsonDecode(response.body);
          if (data != null && data.containsKey('sessionid')) {
            await _secureStorage.write(
              key: 'sessionid',
              value: data['sessionid'],
            );
            print('Session ID from body stored: ${data['sessionid']}');
            return true;
          }
        } catch (e) {
          print('Body is not valid JSON, but login was successful');
        }

        // اگر وضعیت 200 باشد اما sessionId نتوانیم پیدا کنیم، هنوز ورود موفق است
        return true;
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  // متد بازیابی توکن
  Future<String?> getSessionId() async {
    return await _secureStorage.read(key: 'sessionid');
  }

  // متد خروج
  Future<void> logout() async {
    await _secureStorage.delete(key: 'sessionid'); // حذف توکن دسترسی
  }

  // Method to add session ID to requests
  Future<Map<String, String>> getAuthHeaders() async {
    final sessionId = await getSessionId();
    Map<String, String> headers = {};

    if (sessionId != null) {
      headers['Cookie'] = 'sessionid=$sessionId';
    }

    return headers;
  }

  // Method to check if user is logged in
  Future<bool> isLoggedIn() async {
    final sessionId = await getSessionId();
    return sessionId != null;
  }

  // متد ورود با اتصال مجدد وب‌سوکت‌ها
  Future<bool> loginWithReconnect(
    BuildContext context,
    String username,
    String password,
  ) async {
    // انجام عملیات لاگین
    final loginSuccess = await login(username, password);

    if (loginSuccess) {
      // اتصال مجدد وب‌سوکت‌ها با اطلاعات جدید
      await WebSocketManagerService.reconnectAllWebSockets(context);
    }

    return loginSuccess;
  }
}
