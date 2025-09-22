import 'package:itech/service/ai/analysis_service.dart';
import 'package:itech/models/article/article_detail_model.dart';
import 'package:itech/models/ai/article_analysis_model.dart';

/// کلاس مدیریت آنالیز مقاله
class ArticleAnalysisService {
  final AnalysisService _analysisService = AnalysisService();

  ArticleAnalysis? _articleAnalysis;
  String _lastAnalyzedArticleHash = ""; // هش آخرین مقاله آنالیز شده

  // Getters
  ArticleAnalysis? get articleAnalysis => _articleAnalysis;

  // محاسبه هش ساده برای محتوای مقاله
  String _calculateArticleHash(String articleText) {
    // یک هش ساده از محتوای مقاله ایجاد می‌کنیم
    int hash = 0;
    for (int i = 0; i < articleText.length; i++) {
      hash = (hash * 31 + articleText.codeUnitAt(i)) % 1000000007;
    }
    return hash.toString();
  }

  // متد آنالیز مقاله
  Future<String?> analyzeArticle(Article article, Function setState) async {
    if (article == null) {
      return null;
    }

    // محاسبه هش مقاله فعلی
    final String articleText = article.text;
    final String currentArticleHash = _calculateArticleHash(articleText);

    // بررسی آیا مقاله تغییر کرده است
    bool articleChanged = _lastAnalyzedArticleHash != currentArticleHash;
    print(
      'Article changed: $articleChanged (last hash: $_lastAnalyzedArticleHash, current hash: $currentArticleHash)',
    );

    // اگر قبلاً آنالیز نشده است یا مقاله تغییر کرده، آن را آنالیز کن
    if (_articleAnalysis == null || articleChanged) {
      print('Creating new analysis for article');

      setState(() {
        _articleAnalysis = ArticleAnalysis(
          originalText: article.text,
          isLoading: true,
        );
      });

      final analysisResult = await _fetchAnalysis(articleText, setState);
      _lastAnalyzedArticleHash = currentArticleHash; // به‌روزرسانی هش

      return analysisResult;
    } else {
      // اگر قبلاً آنالیز شده و مقاله تغییر نکرده، از نتیجه قبلی استفاده کن
      print('Using cached analysis');
      return _articleAnalysis?.analysisText;
    }
  }

  // متد دریافت آنالیز از سرور
  Future<String?> _fetchAnalysis(String articleText, Function setState) async {
    try {
      print('Sending article for analysis...');

      // ارسال درخواست آنالیز با متن خام
      final analysisText = await _analysisService.analyzeArticle(articleText);

      setState(() {
        if (analysisText != null) {
          print('Analysis received successfully');
          _articleAnalysis = _articleAnalysis!.copyWith(
            analysisText: analysisText,
            isLoading: false,
          );
        } else {
          print('Analysis API returned null');
          _articleAnalysis = _articleAnalysis!.copyWith(
            error: "خطا در دریافت آنالیز مقاله",
            isLoading: false,
          );
        }
      });

      return analysisText;
    } catch (e) {
      print('Error in analysis: $e');
      setState(() {
        _articleAnalysis = _articleAnalysis!.copyWith(
          error: "خطای غیرمنتظره: $e",
          isLoading: false,
        );
      });

      return null;
    }
  }

  // پاک کردن آنالیز فعلی
  void clearAnalysis() {
    _articleAnalysis = null;
    _lastAnalyzedArticleHash = "";
  }
}
