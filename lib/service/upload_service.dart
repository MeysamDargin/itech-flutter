import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:itech/utils/url.dart';
import 'package:itech/utils/endpoint.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UploadService {
  // آدرس API آپلود تصویر
  final String uploadImageUrl =
      "${ApiAddress.baseUrl}${ApiEndpoint.uploadImage}";

  // ایجاد نمونه از FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // دریافت sessionId
  Future<String?> getSessionId() async {
    return await _secureStorage.read(key: 'sessionid');
  }

  // آپلود تصویر به سرور
  Future<String?> uploadImage(File imageFile) async {
    try {
      // دریافت sessionId
      String? sessionId = await getSessionId();
      if (sessionId == null) {
        throw Exception("Session ID not found. Please login first.");
      }

      // ایجاد request با نوع multipart
      var request = http.MultipartRequest('POST', Uri.parse(uploadImageUrl));

      // اضافه کردن sessionId به هدرها
      request.headers['Cookie'] = 'sessionid=$sessionId';

      // اضافه کردن فایل تصویر به درخواست
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      // ارسال درخواست
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      // بررسی پاسخ سرور
      if (response.statusCode == 200 && jsonResponse['status'] == 'success') {
        // برگرداندن URL تصویر آپلود شده
        return jsonResponse['image_url'];
      } else {
        throw Exception("Failed to upload image: ${jsonResponse['message']}");
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
