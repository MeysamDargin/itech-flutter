import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:itech/utils/url.dart';
import 'dart:async';

class TemporalBehaviorSocketService {
  WebSocketChannel? _channel;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Function(Map<String, dynamic>)? _messageCallback;

  Future<void> connectToWebSocket(
    Function(Map<String, dynamic>) onMessageReceived,
  ) async {
    if (_isConnected) return;

    _messageCallback = onMessageReceived;
    final sessionId = await _getSessionId();
    if (sessionId == null) return;

    final wsUrl = "${ApiAddress.baseUrlSW}ws/temporal-behavior/";

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
          _scheduleReconnect();
        },
        onDone: () {
          _isConnected = false;
          _scheduleReconnect();
        },
      );

      _sendInitialMessage();
      _startPingTimer();
      _simulateConnectionEstablished(sessionId);
    } catch (e) {
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _sendInitialMessage() {
    if (_channel != null && _isConnected) {
      final initialMessage = {'type': 'init', 'action': 'connect'};
      _channel!.sink.add(jsonEncode(initialMessage));
    }
  }

  void _simulateConnectionEstablished(String sessionId) {
    if (_messageCallback != null) {
      final now = DateTime.now();
      final connectionData = {
        'type': 'connection_established',
        'user_id': 'current_user',
        'login_time': now.toIso8601String(),
        'session_id': sessionId,
      };

      Timer(Duration(milliseconds: 500), () {
        if (_isConnected && _messageCallback != null) {
          _messageCallback!(connectionData);
        }
      });
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        sendMessage({'type': 'ping'});
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (!_isConnected && _messageCallback != null) {
        connectToWebSocket(_messageCallback!);
      }
    });
  }

  void closeConnection() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();

    if (_channel != null) {
      _channel!.sink.close(status.normalClosure);
      _isConnected = false;
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(data));
    } else if (!_isConnected && _messageCallback != null) {
      _scheduleReconnect();
    }
  }

  Future<String?> _getSessionId() async {
    return await _secureStorage.read(key: 'sessionid');
  }
}
