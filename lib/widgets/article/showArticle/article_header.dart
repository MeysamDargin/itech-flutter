import 'package:flutter/material.dart';
import 'package:itech/main.dart';
import 'dart:ui';
import 'package:itech/service/saved/article_saved_service.dart';
import 'package:http/http.dart' as http;
import 'package:itech/widgets/saved/save_to_bookmark_sheet.dart';

/// ویجت نوار بالایی صفحه مقاله
class ArticleHeaderWidget extends StatefulWidget {
  final Function() onBackPressed;
  final String articleid;
  final Function() onAIButtonPressed;
  final Function() onSharePressed;
  final Function() onBookmarkPressed;
  final bool articleSaved;
  final Function(bool)? onSavedStatusChanged;

  const ArticleHeaderWidget({
    Key? key,
    required this.onBackPressed,
    required this.articleid,
    required this.onAIButtonPressed,
    required this.onSharePressed,
    required this.onBookmarkPressed,
    required this.articleSaved,
    this.onSavedStatusChanged,
  }) : super(key: key);

  @override
  State<ArticleHeaderWidget> createState() => _ArticleHeaderWidgetState();
}

class _ArticleHeaderWidgetState extends State<ArticleHeaderWidget> {
  bool _isAIButtonPressed = false;
  late bool _isSaved;
  final ArticleSavedService _articleSavedService = ArticleSavedService();

  @override
  void initState() {
    super.initState();
    _isSaved = widget.articleSaved;
  }

  @override
  void didUpdateWidget(ArticleHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.articleSaved != widget.articleSaved) {
      _isSaved = widget.articleSaved;
    }
  }

  void _showAIButtonEffect() {
    setState(() {
      _isAIButtonPressed = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isAIButtonPressed = false;
        });
      }
    });
  }

  void _toggleSaveStatus() async {
    // ابتدا وضعیت را به صورت خوش‌بینانه تغییر می‌دهیم
    setState(() {
      _isSaved = !_isSaved;
    });

    // اطلاع به والد در مورد تغییر وضعیت
    if (widget.onSavedStatusChanged != null) {
      widget.onSavedStatusChanged!(_isSaved);
    }

    try {
      // ارسال درخواست به سرور
      final response = await _articleSavedService.saveArticle(widget.articleid);

      // بررسی پاسخ سرور
      if (response['status'] == 'error') {
        // در صورت خطا، برگرداندن وضعیت به حالت قبلی
        setState(() {
          _isSaved = !_isSaved;
        });

        // اطلاع به والد در مورد برگشت وضعیت
        if (widget.onSavedStatusChanged != null) {
          widget.onSavedStatusChanged!(_isSaved);
        }

        // نمایش پیام خطا
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save article. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // در صورت خطای ارتباط با سرور، برگرداندن وضعیت به حالت قبلی
      setState(() {
        _isSaved = !_isSaved;
      });

      // اطلاع به والد در مورد برگشت وضعیت
      if (widget.onSavedStatusChanged != null) {
        widget.onSavedStatusChanged!(_isSaved);
      }

      // نمایش پیام خطا
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).size.width * 0.03;
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).extension<IconColors>()!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenPadding, vertical: 10),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: widget.onBackPressed,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: ImageIcon(
                          AssetImage("assets/icons/back-svgrepo-com.png"),
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right side icons (share, bookmark and AI)
            Container(
              height: 53,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  // Share icon
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: widget.onSharePressed,
                        child: const Center(
                          child: ImageIcon(
                            AssetImage("assets/icons/share.png"),
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Bookmark icon
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color:
                          _isSaved ? Color(0xFF123fdb) : colorScheme.background,
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap:
                            _isSaved
                                ? _toggleSaveStatus
                                : () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder:
                                        (context) => SaveToBookmarkSheet(
                                          articleId: widget.articleid,
                                          onSaveStateChanged: (newSavedState) {
                                            setState(() {
                                              _isSaved = newSavedState;
                                            });
                                            // اطلاع به والد در مورد تغییر وضعیت
                                            if (widget.onSavedStatusChanged !=
                                                null) {
                                              widget.onSavedStatusChanged!(
                                                newSavedState,
                                              );
                                            }
                                          },
                                        ),
                                  );
                                },
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ImageIcon(
                                AssetImage("assets/icons/bookmark.512x510.png"),
                                color:
                                    _isSaved
                                        ? Colors.white
                                        : iconColor.iconColor,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // AI Mode button
                  Container(
                    width: 120,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(99)),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE8E8E8),
                          Color(0xFFF5F5F5),
                          Color(0xFFFFFFFF),
                        ],
                      ),
                      border: Border.all(
                        color: colorScheme.background.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            _isAIButtonPressed ? 0.15 : 0.08,
                          ),
                          blurRadius: _isAIButtonPressed ? 10 : 5,
                          spreadRadius: _isAIButtonPressed ? 1 : 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showAIButtonEffect();
                          widget.onAIButtonPressed();
                        },
                        borderRadius: BorderRadius.all(Radius.circular(99)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(99)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                      Icons.auto_awesome,
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
                                      "AI Mode",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'outfit-bold',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
