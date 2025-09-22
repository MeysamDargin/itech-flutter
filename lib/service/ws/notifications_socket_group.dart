import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:itech/utils/url.dart';
import 'dart:async';

class NotificationsSocketGroup {
  WebSocketChannel? _channel;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isConnected = false;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  Function(Map<String, dynamic>)? _messageCallback;

  Future<void> connectToWebSocket(
    Function(Map<String, dynamic>) onMessageReceived,
  ) async {
    print("NotificationsSocket: Attempting to connect to WebSocket"); // DEBUG

    if (_isConnected) {
      print("NotificationsSocket: Already connected"); // DEBUG
      return;
    }

    _messageCallback = onMessageReceived;
    final sessionId = await _getSessionId();

    print(
      "NotificationsSocket: SessionID retrieved: ${sessionId != null ? "Yes" : "No"}",
    ); // DEBUG

    if (sessionId == null) {
      print("NotificationsSocket: No sessionId found, cannot connect"); // DEBUG
      return;
    }

    final wsUrl = "${ApiAddress.baseUrlSW}ws/notifications/feed/";
    print("NotificationsSocket: Connecting to $wsUrl"); // DEBUG

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl).toString(),
        headers: {'Cookie': 'sessionid=$sessionId'},
      );

      print("NotificationsSocket: Connection attempt made"); // DEBUG

      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          try {
            print("NotificationsSocket: Received message: $message"); // DEBUG
            final data = Map<String, dynamic>.from(jsonDecode(message));
            onMessageReceived(data);
          } catch (e) {
            print("NotificationsSocket: Error parsing message: $e"); // DEBUG
          }
        },
        onError: (error) {
          print("NotificationsSocket: Connection error: $error"); // DEBUG
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          print("NotificationsSocket: Connection closed"); // DEBUG
          _isConnected = false;
          _scheduleReconnect();
        },
      );

      _sendInitialMessage();
      _startPingTimer();
      print("NotificationsSocket: Setup complete"); // DEBUG
    } catch (e) {
      print("NotificationsSocket: Connection exception: $e"); // DEBUG
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _sendInitialMessage() {
    if (_channel != null && _isConnected) {
      final initialMessage = {'type': 'init', 'action': 'get_notif'};
      _channel!.sink.add(jsonEncode(initialMessage));
      print("NotificationsSocket: Initial message sent"); // DEBUG
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        sendMessage({'type': 'ping'});
        print("NotificationsSocket: Ping sent"); // DEBUG
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (!_isConnected && _messageCallback != null) {
        print("NotificationsSocket: Attempting to reconnect"); // DEBUG
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
      print("NotificationsSocket: Connection closed manually"); // DEBUG
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(data));
      print("NotificationsSocket: Message sent: $data"); // DEBUG
    } else if (!_isConnected && _messageCallback != null) {
      print("NotificationsSocket: Cannot send message, not connected"); // DEBUG
      _scheduleReconnect();
    }
  }

  Future<String?> _getSessionId() async {
    String? sessionId = await _secureStorage.read(key: 'sessionid');
    print(
      "NotificationsSocket: Retrieved sessionId: ${sessionId?.substring(0, 5)}...",
    ); // DEBUG - only show first 5 chars for security
    return sessionId;
  }
}
