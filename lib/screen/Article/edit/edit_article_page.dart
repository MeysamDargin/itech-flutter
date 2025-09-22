import 'package:flutter/material.dart';
import 'package:itech/service/article/article_detail_service.dart';
import 'package:itech/models/article/article_detail_model.dart';
import 'package:itech/screen/Article/edit/edit_article.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditArticlePage extends StatefulWidget {
  final String articleId;

  const EditArticlePage({Key? key, required this.articleId}) : super(key: key);

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
  final ArticleDetailService _articleDetailService = ArticleDetailService();
  bool _isLoading = true;
  String? _errorMessage;
  ArticleDetailModel? _articleData;

  @override
  void initState() {
    super.initState();
    _loadArticleData();
  }

  Future<void> _loadArticleData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final articleData = await _articleDetailService.getArticleDetail(
        widget.articleId,
      );

      if (articleData != null) {
        setState(() {
          _articleData = articleData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load article data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Article...'),
          backgroundColor: const Color(0xFFf2f2f2),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: SpinKitThreeBounce(color: Color(0xFF3E48DF), size: 30.0),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: const Color(0xFFf2f2f2),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadArticleData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E48DF),
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // اطلاعات مقاله برای ویرایش
    final article = _articleData!.article;
    final String deltaContent = article.delta;

    // انتقال به صفحه ویرایش با داده‌های موجود
    return EditArticle(
      initialDeltaContent: deltaContent,
      articleId: widget.articleId,
    );
  }
}
