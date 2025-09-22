import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:country_flags/country_flags.dart';

/// مدل زبان با کد کشور مربوطه
class LanguageModel {
  final String languageCode;
  final String countryCode;
  final String languageName;

  LanguageModel({
    required this.languageCode,
    required this.countryCode,
    required this.languageName,
  });
}

/// کلاس انتخاب‌کننده زبان در باتم شیت
class LanguageSelectorSheet {
  /// لیست زبان‌های پشتیبانی شده
  static final List<LanguageModel> supportedLanguages = [
    LanguageModel(
      languageCode: 'en',
      countryCode: 'US',
      languageName: 'English',
    ),
    LanguageModel(
      languageCode: 'fa',
      countryCode: 'IR',
      languageName: 'Persian',
    ),
    LanguageModel(
      languageCode: 'fr',
      countryCode: 'FR',
      languageName: 'French',
    ),
    LanguageModel(
      languageCode: 'de',
      countryCode: 'DE',
      languageName: 'German',
    ),
    LanguageModel(
      languageCode: 'es',
      countryCode: 'ES',
      languageName: 'Spanish',
    ),
    LanguageModel(
      languageCode: 'it',
      countryCode: 'IT',
      languageName: 'Italian',
    ),
    LanguageModel(
      languageCode: 'pt',
      countryCode: 'PT',
      languageName: 'Portuguese',
    ),
    LanguageModel(
      languageCode: 'ru',
      countryCode: 'RU',
      languageName: 'Russian',
    ),
    LanguageModel(
      languageCode: 'zh',
      countryCode: 'CN',
      languageName: 'Chinese',
    ),
    LanguageModel(
      languageCode: 'ja',
      countryCode: 'JP',
      languageName: 'Japanese',
    ),
    LanguageModel(
      languageCode: 'ko',
      countryCode: 'KR',
      languageName: 'Korean',
    ),
    LanguageModel(
      languageCode: 'ar',
      countryCode: 'SA',
      languageName: 'Arabic',
    ),
    LanguageModel(languageCode: 'hi', countryCode: 'IN', languageName: 'Hindi'),
    LanguageModel(
      languageCode: 'tr',
      countryCode: 'TR',
      languageName: 'Turkish',
    ),
    LanguageModel(languageCode: 'nl', countryCode: 'NL', languageName: 'Dutch'),
  ];

  /// نمایش باتم شیت انتخاب زبان
  static void show(
    BuildContext context, {
    required Function(LanguageModel) onLanguageSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _LanguageSelectorContent(onLanguageSelected: onLanguageSelected);
      },
    );
  }
}

/// محتوای باتم شیت انتخاب زبان
class _LanguageSelectorContent extends StatefulWidget {
  final Function(LanguageModel) onLanguageSelected;

  const _LanguageSelectorContent({Key? key, required this.onLanguageSelected})
    : super(key: key);

  @override
  State<_LanguageSelectorContent> createState() =>
      _LanguageSelectorContentState();
}

class _LanguageSelectorContentState extends State<_LanguageSelectorContent>
    with SingleTickerProviderStateMixin {
  // متغیر برای نگهداری متن جستجو
  String searchQuery = '';

  // لیست فیلتر شده زبان‌ها
  late List<LanguageModel> filteredLanguages;

  // کنترلر انیمیشن
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    filteredLanguages = LanguageSelectorSheet.supportedLanguages;

    // تنظیم انیمیشن
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // فیلتر کردن زبان‌ها بر اساس متن جستجو
  void _filterLanguages(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredLanguages = LanguageSelectorSheet.supportedLanguages;
      } else {
        filteredLanguages =
            LanguageSelectorSheet.supportedLanguages
                .where(
                  (language) =>
                      language.languageName.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      language.languageCode.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
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
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Handle bar
                      Container(
                        width: 110,
                        height: 6,
                        margin: EdgeInsets.only(top: 5, bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // عنوان
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [
                                Color(0xFF4055FF).withOpacity(0.8),
                                Color(0xFF5E6FFF).withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            "Select Language",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'outfit-bold',
                            ),
                          ),
                        ),
                      ),

                      // Search field
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search languages',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontFamily: 'a-r',
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                      top: 8,
                                      bottom: 8,
                                    ),
                                  ),
                                  onChanged: _filterLanguages,
                                ),
                              ),
                              if (searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _filterLanguages(''),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.grey[400],
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // لیست زبان‌ها
                      Expanded(
                        child:
                            filteredLanguages.isEmpty
                                ? Center(
                                  child: Text(
                                    "No languages found",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                      fontFamily: 'a-r',
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  itemCount: filteredLanguages.length,
                                  itemBuilder: (context, index) {
                                    final language = filteredLanguages[index];
                                    return Transform.scale(
                                      scale: _animation.value,
                                      child: Opacity(
                                        opacity: _animation.value,
                                        child: _buildLanguageItem(language),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ساخت آیتم زبان
  Widget _buildLanguageItem(LanguageModel language) {
    return InkWell(
      onTap: () {
        widget.onLanguageSelected(language);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            // پرچم کشور
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CountryFlag.fromCountryCode(
                language.countryCode,
                height: 24,
                width: 32,
                // borderRadius: 4,
              ),
            ),
            SizedBox(width: 16),
            // نام زبان
            Expanded(
              child: Text(
                language.languageName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  fontFamily: 'outfit-medium',
                ),
              ),
            ),
            // کد زبان
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                language.languageCode.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: 'outfit-bold',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
