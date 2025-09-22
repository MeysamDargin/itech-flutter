import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:itech/service/ai/summarize_service.dart';
import 'package:itech/models/article/article_detail_model.dart';
import 'package:itech/models/ai/article_summary_model.dart';

/// کلاس مدیریت خلاصه‌سازی مقاله
class ArticleSummaryService {
  final SummarizeService _summarizeService = SummarizeService();

  ArticleSummary? _articleSummary;
  bool _isShowingSummary = false;
  String _lastSummarizedArticleHash = ""; // هش آخرین مقاله خلاصه شده

  // Getters
  ArticleSummary? get articleSummary => _articleSummary;
  bool get isShowingSummary => _isShowingSummary;

  // محاسبه هش ساده برای محتوای مقاله
  String _calculateArticleHash(String articleDelta) {
    // یک هش ساده از محتوای مقاله ایجاد می‌کنیم
    int hash = 0;
    for (int i = 0; i < articleDelta.length; i++) {
      hash = (hash * 31 + articleDelta.codeUnitAt(i)) % 1000000007;
    }
    return hash.toString();
  }

  // متد خلاصه‌سازی مقاله
  Future<void> summarizeArticle(Article article, Function setState) async {
    if (article == null) {
      return;
    }

    // محاسبه هش مقاله فعلی
    final String articleDelta = article.delta;
    final String currentArticleHash = _calculateArticleHash(articleDelta);

    // بررسی آیا مقاله تغییر کرده است
    bool articleChanged = _lastSummarizedArticleHash != currentArticleHash;
    print(
      'Article changed: $articleChanged (last hash: $_lastSummarizedArticleHash, current hash: $currentArticleHash)',
    );

    // اگر قبلاً خلاصه نشده است یا مقاله تغییر کرده، آن را خلاصه کن
    if (_articleSummary == null || articleChanged) {
      print('Creating new summary for article');

      setState(() {
        _articleSummary = ArticleSummary(
          originalDelta: article.delta,
          isLoading: true,
        );
        _isShowingSummary = true;
      });

      _fetchSummary(articleDelta, setState);
      _lastSummarizedArticleHash = currentArticleHash; // به‌روزرسانی هش
    } else {
      // اگر قبلاً خلاصه شده و مقاله تغییر نکرده، فقط وضعیت نمایش را تغییر بده
      print('Using cached summary');
      setState(() {
        _isShowingSummary = !_isShowingSummary;
      });
    }
  }

  // متد دریافت خلاصه از سرور
  Future<void> _fetchSummary(String articleDelta, Function setState) async {
    try {
      print('Sending article for summarization...');

      // ارسال درخواست خلاصه‌سازی با Delta
      final summaryDelta = await _summarizeService.summarizeArticle(
        articleDelta,
      );

      setState(() {
        if (summaryDelta != null) {
          print('Summary received successfully');
          _articleSummary = _articleSummary!.copyWith(
            summaryDelta: summaryDelta,
            isLoading: false,
          );
        } else {
          print('Summary API returned null');
          _articleSummary = _articleSummary!.copyWith(
            error: "خطا در دریافت خلاصه مقاله",
            isLoading: false,
          );
        }
      });
    } catch (e) {
      print('Error in summarization: $e');
      setState(() {
        _articleSummary = _articleSummary!.copyWith(
          error: "خطای غیرمنتظره: $e",
          isLoading: false,
        );
      });
    }
  }

  // متد برای تغییر حالت نمایش بین اصلی و خلاصه
  void toggleSummaryView(Function setState) {
    setState(() {
      _isShowingSummary = !_isShowingSummary;
    });
  }

  // پاک کردن خلاصه فعلی
  void clearSummary() {
    _articleSummary = null;
    _lastSummarizedArticleHash = "";
    _isShowingSummary = false;
  }

  // وضعیت نوار خلاصه
  Widget buildSummaryStatusBar(double screenPadding, Function setState) {
    if (_isShowingSummary && _articleSummary != null) {
      return Padding(
        padding: EdgeInsets.only(
          top: 16,
          bottom: 8,
          left: screenPadding,
          right: screenPadding,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8E8E8),
                    Color(0xFFF5F5F5),
                    Color(0xFFFFFFFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 5,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [
                              Color(0xFF8A2BE2).withOpacity(0.7),
                              Color(0xFF4169E1).withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Icon(
                          Icons.summarize_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: 8),
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [
                              Color(0xFF8A2BE2).withOpacity(0.8),
                              Color(0xFF4169E1).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          "Summary Mode",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'outfit-bold',
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => toggleSummaryView(setState),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF8A2BE2).withOpacity(0.7),
                            Color(0xFF4169E1).withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF8A2BE2).withOpacity(0.2),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        "View Original",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'outfit-medium',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }
}
