import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:itech/utils/url.dart';

class ArticleCommentsSocket {
  WebSocketChannel? _channel;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isConnected = false;

  Future<void> connectToWebSocket(
    Function(Map<String, dynamic>) onMessageReceived,
    String articleId,
  ) async {
    if (_isConnected) return;

    final sessionId = await _getSessionId();
    if (sessionId == null) return;

    final wsUrl = "${ApiAddress.baseUrlSW}ws/comments/?article_id=${articleId}";

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl).toString(),
        headers: {'Cookie': 'sessionid=$sessionId'},
      );

      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          try {
            final data = Map<String, dynamic>.from(jsonDecode(message));
            onMessageReceived(data);
          } catch (e) {
            // Silent error handling
          }
        },
        onError: (error) {
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
    }
  }

  void closeConnection() {
    if (_channel != null) {
      _channel!.sink.close(status.normalClosure);
      _isConnected = false;
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  Future<String?> _getSessionId() async {
    return await _secureStorage.read(key: 'sessionid');
  }
}
