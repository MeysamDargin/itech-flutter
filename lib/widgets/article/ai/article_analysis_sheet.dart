import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleAnalysisSheet {
  static void show(BuildContext context, {required String analysisText}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ArticleAnalysisContent(analysisText: analysisText);
      },
    );
  }
}

/// محتوای باتم شیت آنالیز مقاله
class _ArticleAnalysisContent extends StatefulWidget {
  final String analysisText;

  const _ArticleAnalysisContent({Key? key, required this.analysisText})
    : super(key: key);

  @override
  State<_ArticleAnalysisContent> createState() =>
      _ArticleAnalysisContentState();
}

class _ArticleAnalysisContentState extends State<_ArticleAnalysisContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();

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

  // کپی کردن متن آنالیز
  void _copyAnalysisText() {
    Clipboard.setData(ClipboardData(text: widget.analysisText));
    setState(() {
      _isCopied = true;
    });

    // بعد از 2 ثانیه، آیکون را به حالت اولیه برمی‌گردانیم
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
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
            height: MediaQuery.of(context).size.height * 0.8,
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
                        margin: EdgeInsets.only(top: 5, bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // عنوان و دکمه کپی
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // عنوان
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
                                "Article Analysis",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'outfit-bold',
                                ),
                              ),
                            ),

                            // دکمه کپی
                            InkWell(
                              onTap: _copyAnalysisText,
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isCopied ? Icons.check : Icons.copy,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      _isCopied ? "Copied" : "Copy",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'outfit-medium',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // خط جداکننده
                      Divider(
                        color: Colors.grey.withOpacity(0.2),
                        thickness: 1,
                        height: 1,
                      ),

                      // محتوای آنالیز (مارک‌داون)
                      Expanded(
                        child: Transform.scale(
                          scale: _animation.value,
                          child: Opacity(
                            opacity: _animation.value,
                            child: Container(
                              padding: EdgeInsets.all(16),
                              child: Markdown(
                                data: widget.analysisText,
                                styleSheet: MarkdownStyleSheet(
                                  h1: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'outfit-bold',
                                    color: Colors.black87,
                                  ),
                                  h2: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'outfit-bold',
                                    color: Colors.black87,
                                  ),
                                  h3: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'outfit-bold',
                                    color: Colors.black87,
                                  ),
                                  p: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'outfit-regular',
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                  listBullet: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'outfit-regular',
                                    color: Colors.black87,
                                  ),
                                  blockquote: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'outfit-regular',
                                    color: Colors.grey.shade700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  code: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                    color: Colors.grey.shade800,
                                    backgroundColor: Colors.grey.shade100,
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                onTapLink: (text, href, title) {
                                  if (href != null) {
                                    launchUrl(Uri.parse(href));
                                  }
                                },
                                selectable: true,
                                softLineBreak: true,
                              ),
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
        },
      ),
    );
  }
}
