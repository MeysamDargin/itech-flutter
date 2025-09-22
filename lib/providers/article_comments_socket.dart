import 'package:flutter/material.dart';
import 'package:itech/service/ws/article_comments_socket.dart';

class ArticleCommentsSocketProvider extends ChangeNotifier {
  final ArticleCommentsSocket _articleCommentsSocket = ArticleCommentsSocket();

  // لیست کامنت‌های مقاله
  List<Map<String, dynamic>> _comments = [];

  // مقاله فعلی
  String _currentArticleId = '';

  // تعریف متغیرهای اولیه کامنت
  String _id = '...';
  String _articleId = '...';
  String _userId = '...';
  String _message = '...';
  bool _seen = false;
  String _createdAt = '';
  Map<String, dynamic>? _replyTo;
  Map<String, dynamic>? _userInfo;

  // Getterها
  String get id => _id;
  String get articleId => _articleId;
  bool get seen => _seen;
  String get userId => _userId;
  String get message => _message;
  String get createdAt => _createdAt;
  Map<String, dynamic>? get replyTo => _replyTo;
  Map<String, dynamic>? get userInfo => _userInfo;
  List<Map<String, dynamic>> get comments => _comments;
  String get currentArticleId => _currentArticleId;

  // اتصال به وب سوکت برای مقاله مشخص
  void connectToArticleComments(String articleId) {
    print(
      "Provider: connectToArticleComments called with articleId: $articleId",
    );
    _currentArticleId = articleId;
    _initWebSocket(articleId);
  }

  void _initWebSocket(String articleId) {
    print("Provider: _initWebSocket called with articleId: $articleId");
    _articleCommentsSocket.connectToWebSocket((data) {
      print("Provider: Received websocket data: $data");
      // وقتی لیست کامنت‌ها دریافت می‌شود
      if (data['type'] == 'comments_list') {
        print("Provider: Processing comments_list");
        _comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
        notifyListeners();
      }
      // وقتی کامنت جدید ایجاد می‌شود
      else if (data['type'] == 'comment_created') {
        print("Provider: Processing comment_created");
        var comment = data['comment'];
        if (comment != null) {
          _comments.add(Map<String, dynamic>.from(comment));
          _updateCurrentComment(comment);
          notifyListeners();
        }
      }
      // وقتی کامنت به‌روزرسانی می‌شود
      else if (data['type'] == 'comment_updated') {
        print("Provider: Processing comment_updated");
        var comment = data['comment'];
        if (comment != null) {
          var commentId = comment['_id'];
          int index = _comments.indexWhere((c) => c['_id'] == commentId);
          if (index != -1) {
            _comments[index] = Map<String, dynamic>.from(comment);
            _updateCurrentComment(comment);
            notifyListeners();
          }
        }
      }
      // وقتی کامنت حذف می‌شود
      else if (data['type'] == 'comment_deleted') {
        print("Provider: Processing comment_deleted");
        var commentId = data['comment']['_id'];
        if (commentId != null) {
          _comments.removeWhere((c) => c['_id'] == commentId);
          notifyListeners();
        }
      }
      // وقتی کامنت‌ها خوانده شده‌اند
      else if (data['type'] == 'comments_seen') {
        print("Provider: Processing comments_seen");
        var commentIds = data['comment']['comment_ids'];
        if (commentIds != null && commentIds is List) {
          bool updated = false;

          // به‌روزرسانی وضعیت خوانده شدن کامنت‌ها
          for (var commentId in commentIds) {
            int index = _comments.indexWhere((c) => c['_id'] == commentId);
            if (index != -1) {
              _comments[index]['seen'] = true;
              updated = true;
            }
          }

          // اگر حداقل یک کامنت به‌روزرسانی شده باشد، اطلاع‌رسانی می‌کنیم
          if (updated) {
            print(
              "Provider: Updated seen status for ${commentIds.length} comments",
            );
            notifyListeners();
          }
        }
      }
    }, articleId);
  }

  // به‌روزرسانی کامنت فعلی
  void _updateCurrentComment(Map<String, dynamic> comment) {
    _id = comment['_id'] ?? '...';
    _articleId = comment['article_id'] ?? '...';
    _seen = comment['seen'] ?? false;
    _userId = comment['user_id'] ?? '...';
    _message = comment['message'] ?? '...';
    _createdAt = comment['created_at'] ?? '';
    _replyTo = comment['reply_to'];
    _userInfo = comment['user_info'];
  }

  // انتخاب یک کامنت به عنوان کامنت فعلی
  void selectComment(String commentId) {
    var comment = _comments.firstWhere(
      (c) => c['_id'] == commentId,
      orElse: () => {},
    );
    if (comment.isNotEmpty) {
      _updateCurrentComment(comment);
      notifyListeners();
    }
  }

  // دریافت اطلاعات کاربر برای یک کامنت
  Map<String, dynamic>? getUserInfo(String commentId) {
    var comment = _comments.firstWhere(
      (c) => c['_id'] == commentId,
      orElse: () => {},
    );
    return comment.isNotEmpty ? comment['user_info'] : null;
  }

  // ارسال کامنت جدید
  void sendComment(String message, {String? replyToId}) {
    final data = {
      'type': 'new_comment',
      'article_id': _currentArticleId,
      'message': message,
      'seen': false, // کامنت جدید هنوز خوانده نشده است
      'reply_to': replyToId,
    };
    _articleCommentsSocket.sendMessage(data);
  }

  // ارسال درخواست برای دریافت کامنت‌ها
  void requestComments() {
    _articleCommentsSocket.sendMessage({
      'type': 'get_comments',
      'article_id': _currentArticleId,
    });
  }

  // ارسال پیام ping برای نگه داشتن اتصال
  void sendPing() {
    _articleCommentsSocket.sendMessage({'type': 'ping'});
  }

  void closeConnection() {
    _articleCommentsSocket.closeConnection();
  }
}
