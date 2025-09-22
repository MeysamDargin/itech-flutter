import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:itech/providers/temporal_behavior.dart';
import 'package:itech/utils/endpoint.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/service/websocket_manager_service.dart';
import 'package:itech/providers/get_myArticle_manager.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class LogoutService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// Complete logout method that manages all operations automatically
  static Future<void> completeLogout(BuildContext context) async {
    try {
      // 1. Disconnect all WebSocket connections
      await _disconnectAllWebSockets(context);

      // 2. Send logout request to server (if session exists)
      await _sendLogoutRequest();

      // 3. Clear all local storage
      await _clearAllStorage();

      // 4. Clear app cache
      await _clearAppCache();

      // 5. Reset all app states
      await _resetAppState(context);

      print('✅ Complete logout successful');
    } catch (e) {
      print('❌ Error in logout process: $e');
      // Even in case of error, continue with cleanup operations
      await _forceCleanup(context);
    }
  }

  /// Disconnect all WebSocket connections
  static Future<void> _disconnectAllWebSockets(BuildContext context) async {
    try {
      // Get all WebSocket providers
      final profileSocketManager = Provider.of<ProfileSocketManager>(
        context,
        listen: false,
      );
      final myWebsocketsManager = Provider.of<GetMyArticleManager>(
        context,
        listen: false,
      );
      final temporalBehaviorProvider = Provider.of<TemporalBehaviorProvider>(
        context,
        listen: false,
      );

      // Close all connections
      profileSocketManager.closeConnections();
      myWebsocketsManager.closeConnection();
      temporalBehaviorProvider.closeConnection();

      // Add other WebSocket providers as needed

      print('✅ All WebSocket connections closed successfully');
    } catch (e) {
      print('❌ Error disconnecting WebSockets: $e');
    }
  }

  /// Send logout request to server
  static Future<void> _sendLogoutRequest() async {
    try {
      final sessionId = await _secureStorage.read(key: 'sessionid');
      if (sessionId != null) {
        final response = await http.post(
          Uri.parse('${ApiAddress.baseUrl}${ApiEndpoint.logout}'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Cookie': 'sessionid=$sessionId',
          },
        );

        print(
          '✅ Logout request sent to server, status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('⚠️ Error sending logout request to server: $e');
    }
  }

  /// Clear all storage
  static Future<void> _clearAllStorage() async {
    try {
      await _secureStorage.deleteAll();
      print('✅ All secure storage cleared');
      // Clear other storage if needed
    } catch (e) {
      print('⚠️ Error clearing storage: $e');
    }
  }

  /// Clear app cache
  static Future<void> _clearAppCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      final appDir = await getApplicationSupportDirectory();
      if (await appDir.exists()) {
        await appDir.delete(recursive: true);
      }

      print('✅ App cache cleared');
    } catch (e) {
      print('⚠️ Error clearing cache: $e');
    }
  }

  /// Reset app states
  static Future<void> _resetAppState(BuildContext context) async {
    try {
      // Reset WebSocket states
      await WebSocketManagerService.resetAllWebSocketStates(context);

      // Reset main providers if they have reset methods
      try {
        // Example:
        // final userProvider = Provider.of<UserProvider>(context, listen: false);
        // if (userProvider != null) userProvider.reset();
      } catch (e) {
        print('⚠️ Error resetting providers: $e');
      }

      print('✅ All app states reset successfully');
    } catch (e) {
      print('⚠️ Error resetting app states: $e');
    }
  }

  /// Force cleanup in case of error
  static Future<void> _forceCleanup(BuildContext context) async {
    try {
      await _secureStorage.deleteAll();
      await _disconnectAllWebSockets(context);
      print('✅ Force cleanup completed');
    } catch (e) {
      print('⚠️ Error in force cleanup: $e');
    }
  }
}
