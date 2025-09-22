import 'package:flutter/material.dart';
import 'package:itech/service/ws/get_myArticle_sockets.dart';

class GetMyArticleManager extends ChangeNotifier {
  final GetMyarticleSockets _getMyarticleSockets = GetMyarticleSockets();

  // Articles data
  List<Map<String, dynamic>> _articles = [];
  String _id = '...';
  String _title = '...';
  String _text = '...';
  String _likesCount = '...';
  String _commentsCount = '...';
  String _imgCover = '...';
  String _category = '...';
  int _userId = 0;
  String _createdAt = '';
  String _updatedAt = '';

  // Getters
  String get id => _id;
  String get title => _title;
  String get text => _text;
  String get likesCount => _likesCount;
  String get commentsCount => _commentsCount;
  String get imgCover => _imgCover;
  String get category => _category;
  int get userId => _userId;
  String get createdAt => _createdAt;
  String get updatedAt => _updatedAt;
  List<Map<String, dynamic>> get articles => _articles;

  GetMyArticleManager() {
    _initWebSocket();
  }

  void _initWebSocket() {
    _getMyarticleSockets.connectToWebSocket((data) {
      if (data['type'] == 'articles_list') {
        _articles = List<Map<String, dynamic>>.from(data['articles'] ?? []);
        notifyListeners();
      } else if (data['type'] == 'article_created') {
        var article = data['article'];
        if (article != null) {
          _articles.insert(0, Map<String, dynamic>.from(article));
          _updateCurrentArticle(article);
          notifyListeners();
        }
      } else if (data['type'] == 'article_updated') {
        var article = data['article'];
        if (article != null) {
          var articleId = article['_id'];
          int index = _articles.indexWhere((a) => a['_id'] == articleId);
          if (index != -1) {
            _articles[index] = Map<String, dynamic>.from(article);
            _updateCurrentArticle(article);
            notifyListeners();
          }
        }
      } else if (data['type'] == 'article_deleted') {
        var articleId = data['article_id'];
        if (articleId != null) {
          _articles.removeWhere((a) => a['_id'] == articleId);
          notifyListeners();
        }
      }
    });
  }

  void _updateCurrentArticle(Map<String, dynamic> article) {
    _id = article['_id'] ?? '...';
    _title = article['title'] ?? '...';
    _text = article['text'] ?? '...';
    _likesCount = article['likes_count'] ?? '...';
    _commentsCount = article['comments_count'] ?? '...';
    _imgCover = article['imgCover'] ?? '...';
    _category = article['category'] ?? '...';
    _userId = article['userId'] ?? 0;
    _createdAt = article['createdAt'] ?? '';
    _updatedAt = article['updatedAt'] ?? '';
  }

  void selectArticle(String articleId) {
    var article = _articles.firstWhere(
      (a) => a['_id'] == articleId,
      orElse: () => {},
    );
    if (article.isNotEmpty) {
      _updateCurrentArticle(article);
      notifyListeners();
    }
  }

  void requestArticles() {
    final message = {'type': 'get_articles'};
    _getMyarticleSockets.sendMessage(message);
  }

  void sendPing() {
    final message = {'type': 'ping'};
    _getMyarticleSockets.sendMessage(message);
  }

  void closeConnection() {
    _getMyarticleSockets.closeConnection();
  }

  void resetState() {
    _articles = [];
    _id = '...';
    _title = '...';
    _text = '...';
    _likesCount = '...';
    _commentsCount = '...';
    _imgCover = '...';
    _category = '...';
    _userId = 0;
    _createdAt = '';
    _updatedAt = '';
    notifyListeners();
  }

  Future<void> reconnectWebSocket() async {
    closeConnection();
    resetState();
    _initWebSocket();
  }
}
