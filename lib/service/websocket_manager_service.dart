import 'package:flutter/material.dart';
import 'package:itech/providers/get_myArticle_manager.dart';
import 'package:itech/providers/chat/notifications_socket.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:itech/providers/temporal_behavior.dart';
import 'package:provider/provider.dart';

class WebSocketManagerService {
  static Future<void> reconnectAllWebSockets(BuildContext context) async {
    try {
      final webSocketManager = Provider.of<ProfileSocketManager>(
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

      final notificationsProvider = Provider.of<NotificationsProvider>(
        context,
        listen: false,
      );

      await webSocketManager.reconnectWebSockets();
      await myWebsocketsManager.reconnectWebSocket();
      await temporalBehaviorProvider.reconnectWebSocket();
      await notificationsProvider.reconnectWebSocket();
    } catch (e) {
      // Silent error handling
    }
  }

  static Future<void> resetAllWebSocketStates(BuildContext context) async {
    try {
      final webSocketManager = Provider.of<ProfileSocketManager>(
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

      final notificationsProvider = Provider.of<NotificationsProvider>(
        context,
        listen: false,
      );

      webSocketManager.resetState();
      myWebsocketsManager.resetState();
      // temporalBehaviorProvider.resetState();
      notificationsProvider.resetState();
    } catch (e) {
      // Silent error handling
    }
  }
}
