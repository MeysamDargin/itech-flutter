import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/auth/login_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class ProfileService {
  final String _baseUrl = '${ApiAddress.baseUrl}${ApiEndpoint.profilePut}';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Update profile data
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    final url = Uri.parse(_baseUrl);

    try {
      // Get auth headers with session ID from LoginService
      final sessionId = await _secureStorage.read(key: 'sessionid');

      // Send POST request with form-data for Django
      final response = await http.post(
        url,
        headers: {'Cookie': 'sessionid=$sessionId'},
        body: profileData,
      );

      // Check response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Profile updated successfully: ${response.body}');
        return true;
      } else {
        print(
          'Profile update failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Update profile with images
  Future<bool> updateProfileWithImages({
    required Map<String, dynamic> profileData,
    File? profileImage,
    File? coverImage,
  }) async {
    final url = Uri.parse(_baseUrl);

    try {
      // Get auth headers with session ID from LoginService
      final sessionId = await _secureStorage.read(key: 'sessionid');

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add session ID cookie
      if (sessionId != null) {
        request.headers['Cookie'] = 'sessionid=$sessionId';
      }

      // Add form data
      profileData.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add profile image if selected
      if (profileImage != null) {
        final profileImageField = await http.MultipartFile.fromPath(
          'profile_picture',
          profileImage.path,
          contentType: MediaType('image', _getImageType(profileImage.path)),
        );
        request.files.add(profileImageField);
      }

      // Add cover image if selected
      if (coverImage != null) {
        final coverImageField = await http.MultipartFile.fromPath(
          'profile_caver',
          coverImage.path,
          contentType: MediaType('image', _getImageType(coverImage.path)),
        );
        request.files.add(coverImageField);
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Check response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Profile updated successfully: ${response.body}');
        return true;
      } else {
        print(
          'Profile update failed: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error updating profile with images: $e');
      return false;
    }
  }

  // Helper to get image MIME type
  String _getImageType(String path) {
    final ext = extension(path).toLowerCase().replaceAll('.', '');
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      default:
        return 'jpeg'; // Default to jpeg if unknown
    }
  }

  // Get profile data
  Future<Map<String, dynamic>?> getProfile() async {
    final url = Uri.parse(_baseUrl);

    try {
      final sessionId = await _secureStorage.read(key: 'sessionid');

      // Send GET request
      final response = await http.get(
        url,
        headers: {'Cookie': 'sessionid=$sessionId'},
      );

      // Check response status
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Profile data retrieved: ${response.body}');
        return data;
      } else {
        print(
          'Failed to get profile: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }
}
