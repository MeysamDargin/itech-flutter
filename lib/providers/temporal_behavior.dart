import 'package:flutter/material.dart';
import 'package:itech/service/ws/temporal_behavior_socket.dart';
import 'dart:async';

class TemporalBehaviorProvider extends ChangeNotifier {
  final TemporalBehaviorSocketService _temporalBehaviorSocketService =
      TemporalBehaviorSocketService();

  // State variables
  bool _isConnected = false;
  DateTime? _loginTime;
  String? _userId;
  String? _username;
  String? _sessionId;
  bool _isInitialized = false;
  Timer? _initTimer;

  // Getters
  bool get isConnected => _isConnected;
  DateTime? get loginTime => _loginTime;
  String? get userId => _userId;
  String? get username => _username;
  String? get sessionId => _sessionId;
  bool get isInitialized => _isInitialized;

  TemporalBehaviorProvider() {
    print("TemporalBehaviorProvider initialized");
    // Delay initialization to ensure session is available
    _scheduleInit();
  }

  void _scheduleInit() {
    _initTimer?.cancel();
    _initTimer = Timer(Duration(seconds: 1), () {
      if (!_isInitialized) {
        _initWebSocket();
      }
    });
  }

  void _initWebSocket() {
    print("Initializing Temporal Behavior WebSocket connection");
    _isInitialized = true;

    _temporalBehaviorSocketService.connectToWebSocket((data) {
      print("Received data in provider: $data");

      // Handle different message types
      final messageType = data['type'] as String?;

      switch (messageType) {
        case 'connection_established':
          _handleConnectionEstablished(data);
          break;
        case 'echo':
          _handleEchoMessage(data);
          break;
        case 'pong':
          // Handle server pong response
          print('Received pong from server');
          break;
        default:
          // Handle any other message types
          print('Received unknown message type: $messageType');
          // Try to extract useful information anyway
          _updateStateFromData(data);
      }
    });
  }

  void _handleConnectionEstablished(Map<String, dynamic> data) {
    _isConnected = true;
    _userId = data['user_id']?.toString();
    _loginTime =
        data['login_time'] != null
            ? DateTime.parse(data['login_time'])
            : DateTime.now();
    _sessionId = data['session_id'];
    print('Connection established with user ID: $_userId at $_loginTime');
    notifyListeners();
  }

  void _handleEchoMessage(Map<String, dynamic> data) {
    print('Received echo message: ${data['message']}');
    // Additional echo handling if needed
  }

  void _updateStateFromData(Map<String, dynamic> data) {
    // Try to extract useful information from unknown message types
    bool hasUpdates = false;

    if (data['user_id'] != null) {
      _userId = data['user_id'].toString();
      hasUpdates = true;
    }

    if (data['username'] != null) {
      _username = data['username'];
      hasUpdates = true;
    }

    if (data['session_id'] != null) {
      _sessionId = data['session_id'];
      hasUpdates = true;
    }

    if (hasUpdates) {
      notifyListeners();
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    print("Sending message to Temporal Behavior WebSocket: $data");
    _temporalBehaviorSocketService.sendMessage(data);
  }

  // Send a ping to check connection
  void ping() {
    sendMessage({'type': 'ping'});
  }

  // Force a manual connection attempt
  Future<bool> forceConnect() async {
    print("Forcing connection to Temporal Behavior WebSocket");
    closeConnection();
    _resetState();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      _initWebSocket();

      // Wait a bit to see if connection is established
      await Future.delayed(Duration(seconds: 2));

      return _isConnected;
    } catch (e) {
      print("Error in force connect: $e");
      return false;
    }
  }

  // Check connection status and try to reconnect if needed
  Future<bool> checkConnection() async {
    if (_isConnected) {
      print("Temporal behavior WebSocket is connected");
      // Send a ping to verify connection
      ping();
      return true;
    } else {
      print(
        "Temporal behavior WebSocket is not connected, attempting to reconnect",
      );
      return await forceConnect();
    }
  }

  void closeConnection() {
    print("Closing Temporal Behavior WebSocket connection");
    _initTimer?.cancel();
    _temporalBehaviorSocketService.closeConnection();
    _resetState();
  }

  void _resetState() {
    _isConnected = false;
    _loginTime = null;
    _userId = null;
    _username = null;
    _sessionId = null;
    notifyListeners();
  }

  Future<void> reconnectWebSocket() async {
    print("Reconnecting Temporal Behavior WebSocket");
    closeConnection();
    _scheduleInit();
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    closeConnection();
    super.dispose();
  }
}
