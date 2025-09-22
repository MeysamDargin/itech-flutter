import 'package:flutter/material.dart';
import 'package:itech/service/ws/notifications_socket_group.dart';

class NotificationsGroupProvider extends ChangeNotifier {
  final NotificationsSocketGroup _notificationsSocketGroup =
      NotificationsSocketGroup();

  // Notifications data
  List<Map<String, dynamic>> _notificationsGroup = [];
  int _unreadCount = 0;

  // Current notification details
  String _notificationType = '';
  int _actorId = 0;
  String _actorUsername = '';
  String _actorProfileImg = '';
  Map<String, dynamic> _target =
      {}; // تغییر از int به Map برای پشتیبانی از target پیچیده
  String _createdAt = '';
  bool _read = false;
  String _notificationId = '';
  bool _isFollowing = false;

  // Getters
  List<Map<String, dynamic>> get notifications => _notificationsGroup;
  int get unreadCount => _unreadCount;
  String get notificationType => _notificationType;
  int get actorId => _actorId;
  String get actorUsername => _actorUsername;
  String get actorProfileImg => _actorProfileImg;
  Map<String, dynamic> get target => _target; // تغییر getter
  int get targetId => _target['id'] ?? 0; // برای backward compatibility
  String get createdAt => _createdAt;
  bool get read => _read;
  String get notificationId => _notificationId;
  bool get isFollowing => _isFollowing;

  NotificationsGroupProvider() {
    print("NotificationsGroupProvider: Constructor called");
    _initWebSocket();
  }

  void _initWebSocket() {
    print("NotificationsProvider: Initializing WebSocket");
    _notificationsSocketGroup.connectToWebSocket((data) {
      print(
        "NotificationsProvider: Received data from WebSocket: ${data['type']}",
      );

      // Handle different types of notifications
      if (data['type'] == 'notifications_list') {
        _handleNotificationsList(data);
      } else if (data['type'] == 'initial_notifications') {
        _handleInitialNotifications(data);
      } else if (data['type'] == 'new_article_notification') {
        _handleNewNotification(data);
      } else if (data['type'] == 'notification_read') {
        _handleNotificationRead(data);
      } else if (data['type'] == 'new_article') {
        _handleSpecificNotification(data);
      }
    });

    // Request notifications immediately after connecting
    Future.delayed(Duration(seconds: 2), () {
      print("NotificationsProvider: Requesting initial notifications");
      requestNotifications();
    });
  }

  void _handleNotificationsList(Map<String, dynamic> data) {
    print("NotificationsProvider: Handling notifications list");
    if (data.containsKey('notifications')) {
      _notificationsGroup = List<Map<String, dynamic>>.from(
        data['notifications'] ?? [],
      );
      _calculateUnreadCount();
      notifyListeners();
    }
  }

  void _handleInitialNotifications(Map<String, dynamic> data) {
    print("NotificationsProvider: Handling initial notifications");
    if (data.containsKey('data')) {
      List<dynamic> rawNotifications = data['data'] ?? [];
      _notificationsGroup =
          rawNotifications.map((item) {
            Map<String, dynamic> notification = Map<String, dynamic>.from(item);

            return _normalizeNotification(notification);
          }).toList();

      _calculateUnreadCount();
      notifyListeners();

      print(
        "NotificationsProvider: Loaded ${_notificationsGroup.length} initial notifications",
      );
    }
  }

  void _handleNewNotification(Map<String, dynamic> data) {
    print("NotificationsProvider: Handling new notification");
    if (data.containsKey('notification')) {
      var rawNotification = Map<String, dynamic>.from(data['notification']);
      var notification = _normalizeNotification(rawNotification);

      _notificationsGroup.insert(0, notification);
      _updateCurrentNotification(notification);
      _calculateUnreadCount();
      notifyListeners();
    }
  }

  void _handleNotificationRead(Map<String, dynamic> data) {
    print("NotificationsProvider: Handling notification read");
    if (data.containsKey('notification_id')) {
      String notificationId = data['notification_id'].toString();
      int index = _notificationsGroup.indexWhere(
        (n) => n['notification_id'].toString() == notificationId,
      );
      if (index != -1) {
        _notificationsGroup[index]['read'] = true;
        _calculateUnreadCount();
        notifyListeners();
      }
    } else if (data.containsKey('all_read') && data['all_read'] == true) {
      for (var notification in _notificationsGroup) {
        notification['read'] = true;
      }
      _calculateUnreadCount();
      notifyListeners();
    }
  }

  void _handleSpecificNotification(Map<String, dynamic> data) {
    print(
      "NotificationsProvider: Handling specific notification: ${data['type']}",
    );
    if (data.containsKey('data')) {
      var rawNotificationData = Map<String, dynamic>.from(data['data']);
      var notificationData = _normalizeNotification(rawNotificationData);

      _notificationsGroup.insert(0, notificationData);
      _updateCurrentNotification(notificationData);
      _calculateUnreadCount();
      notifyListeners();
    }
  }

  // متد جدید برای normalize کردن notification data
  Map<String, dynamic> _normalizeNotification(
    Map<String, dynamic> rawNotification,
  ) {
    // Handle target field - می‌تواند Map باشد (برای like) یا int (برای سایر موارد)
    Map<String, dynamic> target = {};
    int targetId = 0;

    if (rawNotification['target'] != null) {
      if (rawNotification['target'] is Map) {
        // برای نوتیفیکیشن‌های like که target یک object است
        target = Map<String, dynamic>.from(rawNotification['target']);
        if (target['id'] != null) {
          targetId = int.tryParse(target['id'].toString()) ?? 0;
        }
      } else {
        // برای سایر نوتیفیکیشن‌ها که target یک int است
        targetId = int.tryParse(rawNotification['target'].toString()) ?? 0;
        target = {'id': targetId, 'type': 'unknown'};
      }
    }

    // Handle target_id field (اگر مستقیماً موجود باشد)
    if (rawNotification['target_id'] != null && targetId == 0) {
      if (rawNotification['target_id'] is Map) {
        target = Map<String, dynamic>.from(rawNotification['target_id']);
        if (target['id'] != null) {
          targetId = int.tryParse(target['id'].toString()) ?? 0;
        }
      } else {
        targetId = int.tryParse(rawNotification['target_id'].toString()) ?? 0;
        target = {'id': targetId, 'type': 'unknown'};
      }
    }

    return {
      'notification_id': rawNotification['notification_id']?.toString() ?? '',
      'user_id': rawNotification['user_id'] ?? 0,
      'type': rawNotification['type'] ?? '',
      'actor_id': rawNotification['actor_id'] ?? 0,
      'actor_username': rawNotification['actor_username'] ?? '',
      'actor_profile_img': rawNotification['actor_profile_img'] ?? '',
      'target': target, // ذخیره کامل target object
      'target_id': targetId, // برای backward compatibility
      'created_at': rawNotification['created_at'] ?? '',
      'read': rawNotification['read'] ?? (rawNotification['is_read'] ?? false),
      'is_mutual_follow': rawNotification['is_mutual_follow'] ?? false,
      'is_following': false,
      'extra_data': rawNotification['extra_data'] ?? {},
    };
  }

  void _updateCurrentNotification(Map<String, dynamic> notification) {
    _notificationType = notification['type'] ?? '';
    _actorId = notification['actor_id'] ?? 0;
    _actorUsername = notification['actor_username'] ?? '';
    _actorProfileImg = notification['actor_profile_img'] ?? '';
    _target = notification['target'] ?? {};
    _createdAt = notification['created_at'] ?? '';
    _read = notification['read'] ?? false;
    _isFollowing = notification['is_mutual_follow'] ?? false;
    _notificationId = notification['notification_id']?.toString() ?? '';
  }

  void _calculateUnreadCount() {
    _unreadCount = _notificationsGroup.where((n) => n['read'] == false).length;
    print("NotificationsProvider: Unread count updated to $_unreadCount");
  }

  // متدهای کمکی برای کار با like notifications
  String getArticleTitle(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final notification = _notificationsGroup[index];
      if (notification['type'] == 'like' &&
          notification['extra_data'] != null) {
        return notification['extra_data']['article_title'] ?? 'a post';
      }
    }
    return '';
  }

  String getArticleId(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final notification = _notificationsGroup[index];
      if (notification['type'] == 'like' && notification['target'] != null) {
        return notification['target']['id']?.toString() ?? '';
      }
    }
    return '';
  }

  String getArticleImgCover(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final notification = _notificationsGroup[index];
      if (notification['type'] == 'like' &&
          notification['extra_data'] != null) {
        return notification['extra_data']['article_img_cover'] ?? '';
      }
    }
    return '';
  }

  bool isLikeNotification(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      return _notificationsGroup[index]['type'] == 'like';
    }
    return false;
  }

  bool isArticleTarget(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final notification = _notificationsGroup[index];
      if (notification['target'] != null) {
        return notification['target']['type'] == 'article';
      }
    }
    return false;
  }

  // متدهای جدید برای کار با comment notifications
  bool isCommentCreateNotification(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      return _notificationsGroup[index]['type'] == 'comment_create';
    }
    return false;
  }

  bool isCommentReplyNotification(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      return _notificationsGroup[index]['type'] == 'comment_reply';
    }
    return false;
  }

  bool isCommentNotification(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final type = _notificationsGroup[index]['type'];
      return type == 'comment_create' || type == 'comment_reply';
    }
    return false;
  }

  String getCommentText(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final notification = _notificationsGroup[index];
      if (isCommentNotification(index) && notification['extra_data'] != null) {
        return notification['extra_data']['comment'] ?? '';
      }
    }
    return '';
  }

  String getCommentId(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final notification = _notificationsGroup[index];
      if (notification['type'] == 'comment_create' &&
          notification['target'] != null) {
        return notification['target']['id']?.toString() ?? '';
      } else if (notification['type'] == 'comment_reply' &&
          notification['target'] != null) {
        return notification['target']['new_reply_id']?.toString() ?? '';
      }
    }
    return '';
  }

  String getReplyToCommentId(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final notification = _notificationsGroup[index];
      if (notification['type'] == 'comment_reply' &&
          notification['target'] != null) {
        return notification['target']['replying_to_comment']?.toString() ?? '';
      }
    }
    return '';
  }

  // برای دریافت ID مقاله که کامنت روی آن گذاشته شده
  String getCommentArticleId(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final notification = _notificationsGroup[index];
      if (isCommentNotification(index) && notification['extra_data'] != null) {
        return notification['extra_data']['article_id']?.toString() ?? '';
      }
    }
    return '';
  }

  void markAsRead(String notificationId) {
    print(
      "NotificationsProvider: Marking notification as read: $notificationId",
    );
    final message = {'type': 'mark_read', 'notification_id': notificationId};
    _notificationsSocketGroup.sendMessage(message);
  }

  void markAllAsRead() {
    print("NotificationsProvider: Marking all notifications as read");
    final message = {'type': 'mark_all_read'};
    _notificationsSocketGroup.sendMessage(message);
  }

  void requestNotifications() {
    print("NotificationsProvider: Requesting notifications");
    final message = {'type': 'get_notifications'};
    _notificationsSocketGroup.sendMessage(message);
  }

  void closeConnection() {
    print("NotificationsProvider: Closing connection");
    _notificationsSocketGroup.closeConnection();
  }

  void updateFollowStatus(int index, bool isFollowing) {
    if (index >= 0 && index < _notificationsGroup.length) {
      _notificationsGroup[index]['is_mutual_follow'] = isFollowing;
      notifyListeners();
      print(
        "NotificationsProvider: Updated follow status for notification at index $index to $isFollowing",
      );
    }
  }

  bool getFollowStatus(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      return _notificationsGroup[index]['is_mutual_follow'] ?? false;
    }
    return false;
  }

  bool toggleFollowStatus(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      final currentStatus =
          _notificationsGroup[index]['is_mutual_follow'] ?? false;
      final newStatus = !currentStatus;
      _notificationsGroup[index]['is_mutual_follow'] = newStatus;
      notifyListeners();
      print(
        "NotificationsProvider: Toggled follow status for notification at index $index from $currentStatus to $newStatus",
      );
      return newStatus;
    }
    return false;
  }

  int? getActorId(int index) {
    if (index >= 0 && index < _notificationsGroup.length) {
      return _notificationsGroup[index]['actor_id'];
    }
    return null;
  }

  void resetState() {
    print("NotificationsProvider: Resetting state");
    _notificationsGroup = [];
    _unreadCount = 0;
    _notificationType = '';
    _actorId = 0;
    _actorUsername = '';
    _actorProfileImg = '';
    _target = {};
    _createdAt = '';
    _read = false;
    _isFollowing = false;
    _notificationId = '';
    notifyListeners();
  }

  Future<void> reconnectWebSocket() async {
    print("NotificationsProvider: Reconnecting WebSocket");
    closeConnection();
    resetState();
    _initWebSocket();
  }
}
