import 'package:flutter/material.dart';
import 'package:itech/models/ai/article_lang_model.dart';
import 'package:itech/service/ai/lang_service.dart';
import 'dart:ui';
import 'package:itech/models/article/article_detail_model.dart';

/// کلاس مدیریت ترجمه مقاله
class ArticleLangService {
  final LanguageService _languageService = LanguageService();

  ArticleLang? _articleLang;
  bool _isShowingLang = false;
  String _currentLanguage = "en"; // زبان پیش‌فرض انگلیسی
  String _lastTranslatedLanguage = ""; // آخرین زبان ترجمه شده
  String _lastTranslatedArticleHash = ""; // هش آخرین مقاله ترجمه شده

  // Getters
  ArticleLang? get articleLang => _articleLang;
  bool get isShowingLang => _isShowingLang;
  String get currentLanguage => _currentLanguage;

  // محاسبه هش ساده برای محتوای مقاله
  String _calculateArticleHash(String articleDelta) {
    // یک هش ساده از محتوای مقاله ایجاد می‌کنیم
    int hash = 0;
    for (int i = 0; i < articleDelta.length; i++) {
      hash = (hash * 31 + articleDelta.codeUnitAt(i)) % 1000000007;
    }
    return hash.toString();
  }

  // متد ترجمه مقاله
  Future<void> translateArticle(
    Article article,
    String languageCode,
    Function setState,
  ) async {
    if (article == null) {
      return;
    }

    // ذخیره زبان انتخاب شده
    _currentLanguage = languageCode;

    // محاسبه هش مقاله فعلی
    final String articleDelta = article.delta;
    final String currentArticleHash = _calculateArticleHash(articleDelta);

    // بررسی آیا مقاله یا زبان تغییر کرده است
    bool contentOrLanguageChanged =
        _lastTranslatedArticleHash != currentArticleHash ||
        _lastTranslatedLanguage != languageCode;
    print(
      'Content or language changed: $contentOrLanguageChanged (last hash: $_lastTranslatedArticleHash, current hash: $currentArticleHash, last language: $_lastTranslatedLanguage, current language: $languageCode)',
    );

    // اگر قبلاً ترجمه نشده است یا مقاله/زبان تغییر کرده، آن را ترجمه کن
    if (_articleLang == null || contentOrLanguageChanged) {
      print('Creating new translation for article in language: $languageCode');

      setState(() {
        _articleLang = ArticleLang(
          originalDelta: article.delta,
          isLoading: true,
        );
        _isShowingLang = true;
      });

      _fetchLang(articleDelta, languageCode, setState);
      _lastTranslatedArticleHash = currentArticleHash; // به‌روزرسانی هش
      _lastTranslatedLanguage = languageCode; // به‌روزرسانی زبان
    } else {
      // اگر قبلاً به همین زبان ترجمه شده و مقاله تغییر نکرده، فقط وضعیت نمایش را تغییر بده
      print('Using cached translation');
      setState(() {
        _isShowingLang = true;
      });
    }
  }

  // متد دریافت ترجمه از سرور
  Future<void> _fetchLang(
    String articleDelta,
    String language,
    Function setState,
  ) async {
    try {
      print('Translating article to language: $language');

      // ارسال درخواست ترجمه با Delta
      final translatedDelta = await _languageService.languageArticle(
        articleDelta,
        language,
      );

      setState(() {
        if (translatedDelta != null) {
          _articleLang = _articleLang!.copyWith(
            langDelta: translatedDelta,
            isLoading: false,
          );
          print('Translation completed successfully');
        } else {
          _articleLang = _articleLang!.copyWith(
            error: "خطا در دریافت ترجمه مقاله",
            isLoading: false,
          );
          print('Translation failed: API returned null');
        }
      });
    } catch (e) {
      print('Translation error: $e');
      setState(() {
        _articleLang = _articleLang!.copyWith(
          error: "خطای غیرمنتظره: $e",
          isLoading: false,
        );
      });
    }
  }

  // متد برای تغییر حالت نمایش بین اصلی و ترجمه
  void toggleTranslationView(Function setState) {
    setState(() {
      _isShowingLang = !_isShowingLang;
    });
  }

  // پاک کردن ترجمه فعلی
  void clearTranslation() {
    _articleLang = null;
    _lastTranslatedArticleHash = "";
    _lastTranslatedLanguage = "";
    _isShowingLang = false;
  }

  // وضعیت نوار ترجمه
  Widget buildTranslationStatusBar(double screenPadding, Function setState) {
    if (_isShowingLang && _articleLang != null) {
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
                          Icons.translate,
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
                          "Translated (${_currentLanguage.toUpperCase()})",
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
                    onTap: () => toggleTranslationView(setState),
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
