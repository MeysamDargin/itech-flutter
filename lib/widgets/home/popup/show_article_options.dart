import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // برای HapticFeedback
import 'package:itech/main.dart';
import 'package:itech/service/saved/article_saved_service.dart';
import 'package:itech/service/saved/check_save_article.dart';
import 'package:itech/widgets/saved/save_to_bookmark_sheet.dart';
import 'package:itech/widgets/feedback/send_feedback_sheet.dart';
import 'package:itech/widgets/report/send_report_sheet.dart';

// Custom Glassmorphism Widget
class ShowArticleOptions extends StatelessWidget {
  const ShowArticleOptions({
    Key? key,
    required this.child,
    required this.blur,
    required this.opacity,
    required this.color,
    this.borderRadius,
  }) : super(key: key);
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// Custom Popup Menu with Glassmorphism
class PopupMenuButton extends StatefulWidget {
  final String? articleId;
  final bool? isSaved;
  final Function(bool)? onSavedStatusChanged;

  const PopupMenuButton({
    Key? key,
    this.articleId,
    this.isSaved = false,
    this.onSavedStatusChanged,
  }) : super(key: key);

  @override
  _PopupMenuButtonState createState() => _PopupMenuButtonState();
}

class _PopupMenuButtonState extends State<PopupMenuButton>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isMenuOpen = false;
  final GlobalKey _buttonKey = GlobalKey();
  final ArticleSavedService _articleSavedService = ArticleSavedService();
  late bool _isSaved;
  bool _isCheckingSaveStatus = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved ?? false;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void didUpdateWidget(PopupMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSaved != widget.isSaved) {
      _isSaved = widget.isSaved ?? false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _checkSaveStatus() async {
    if (widget.articleId == null) return;

    setState(() {
      _isCheckingSaveStatus = true;
    });

    try {
      print('Checking save status for article: ${widget.articleId}');
      final response = await CheckSaveArticle.checkSaveArticle(
        widget.articleId!,
      );
      print('Check save response: $response');

      if (mounted) {
        setState(() {
          // Check if response contains is_saved field
          if (response.containsKey('is_saved')) {
            _isSaved = response['is_saved'] == true;

            // اطلاع به والد در مورد وضعیت سیو
            if (widget.onSavedStatusChanged != null) {
              widget.onSavedStatusChanged!(_isSaved);
            }
          }
          _isCheckingSaveStatus = false;
        });
      }
    } catch (e) {
      print('Error checking save status: $e');
      if (mounted) {
        setState(() {
          _isCheckingSaveStatus = false;
        });
      }
    }
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _controller.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        setState(() {
          _isMenuOpen = false;
        });
      });
    } else {
      // بررسی وضعیت سیو قبل از باز کردن منو
      if (widget.articleId != null) {
        // ابتدا منو را باز کنیم
        final RenderBox? buttonBox =
            _buttonKey.currentContext?.findRenderObject() as RenderBox?;
        if (buttonBox == null) return;

        final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
        _overlayEntry = _createOverlayEntry(buttonPosition);
        Overlay.of(context).insert(_overlayEntry!);
        _controller.forward();
        setState(() {
          _isMenuOpen = true;
        });

        // سپس وضعیت سیو را بررسی کنیم
        _checkSaveStatus().then((_) {
          // بازسازی منو با وضعیت جدید
          if (_isMenuOpen && _overlayEntry != null) {
            _overlayEntry!.markNeedsBuild();
          }
        });
      } else {
        final RenderBox? buttonBox =
            _buttonKey.currentContext?.findRenderObject() as RenderBox?;
        if (buttonBox == null) return;

        final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
        _overlayEntry = _createOverlayEntry(buttonPosition);
        Overlay.of(context).insert(_overlayEntry!);
        _controller.forward();
        setState(() {
          _isMenuOpen = true;
        });
      }
    }
  }

  void _toggleSaveStatus() async {
    _toggleMenu();

    setState(() {
      _isSaved = !_isSaved;
    });

    if (widget.onSavedStatusChanged != null) {
      widget.onSavedStatusChanged!(_isSaved);
    }

    try {
      final response = await _articleSavedService.saveArticle(
        widget.articleId!,
      );

      if (response['status'] == 'error') {
        setState(() {
          _isSaved = !_isSaved;
        });

        if (widget.onSavedStatusChanged != null) {
          widget.onSavedStatusChanged!(_isSaved);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save article. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaved = !_isSaved;
      });

      if (widget.onSavedStatusChanged != null) {
        widget.onSavedStatusChanged!(_isSaved);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSaveDirectorySheet() {
    if (widget.articleId != null) {
      _toggleMenu();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => SaveToBookmarkSheet(
              articleId: widget.articleId!,
              onSaveStateChanged: (newSavedState) {
                setState(() {
                  _isSaved = newSavedState;
                });
                // اطلاع به والد در مورد تغییر وضعیت
                if (widget.onSavedStatusChanged != null) {
                  widget.onSavedStatusChanged!(newSavedState);
                }
              },
            ),
      );
    }
  }

  void _showCreateFeedbackSheet() {
    if (widget.articleId != null) {
      _toggleMenu(); // بستن منو

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CreateFeedbackSheet(articleId: widget.articleId!),
      );
    }
  }

  void _showSendReportSheet() {
    if (widget.articleId != null) {
      _toggleMenu(); // بستن منو

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SendReportSheet(articleId: widget.articleId!),
      );
    }
  }

  OverlayEntry _createOverlayEntry(Offset buttonPosition) {
    // محاسبه ارتفاع صفحه
    final screenHeight = MediaQuery.of(context).size.height;

    // محاسبه فضای باقیمانده در پایین دکمه
    final bottomSpace = screenHeight - buttonPosition.dy - 50;

    // ارتفاع تقریبی منو (تعداد آیتم‌ها × ارتفاع هر آیتم)
    final menuHeight = 4 * 44.0; // تعداد آیتم‌ها × ارتفاع تقریبی هر آیتم

    // تصمیم‌گیری برای باز شدن منو به سمت بالا یا پایین
    final showBelow =
        bottomSpace >= menuHeight || buttonPosition.dy < menuHeight;

    return OverlayEntry(
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final textTheme = Theme.of(context).textTheme;
              final colorScheme = Theme.of(context).colorScheme;
              return Stack(
                children: [
                  // Background overlay to dismiss on tap
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _toggleMenu,
                      child: Container(color: Colors.black.withOpacity(0.1)),
                    ),
                  ),
                  // Glassmorphic Menu
                  Positioned(
                    right: 15,
                    // اگر فضای کافی در پایین نباشد، منو را بالای دکمه نمایش بده
                    top: showBelow ? buttonPosition.dy + 50 : null,
                    bottom:
                        !showBelow
                            ? screenHeight - buttonPosition.dy + 10
                            : null,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _opacityAnimation,
                        child: ShowArticleOptions(
                          blur: 15,
                          opacity: 0.7,
                          color: colorScheme.background,
                          borderRadius: BorderRadius.circular(16),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 160,
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildMenuItem(
                                    icon: AssetImage(
                                      "assets/icons/info-circle-svgrepo-com.png",
                                    ),
                                    text: 'Report',
                                    color_text: Color.fromARGB(
                                      255,
                                      255,
                                      52,
                                      52,
                                    ),
                                    color_icon: Color.fromARGB(
                                      255,
                                      255,
                                      52,
                                      52,
                                    ),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _showSendReportSheet();
                                      _toggleMenu();
                                    },
                                  ),
                                  _buildMenuItem(
                                    icon: AssetImage(
                                      "assets/icons/user-speak-rounded-svgrepo-com.png",
                                    ),
                                    text: 'Feedback',
                                    onTap: () {
                                      // HapticFeedback.lightImpact();
                                      print(
                                        'Feedback for article: ${widget.articleId}',
                                      );
                                      _showCreateFeedbackSheet();
                                      _toggleMenu();
                                    },
                                  ),
                                  _buildMenuItem(
                                    icon: AssetImage(
                                      "assets/icons/archive-minus-svgrepo-com (1).png",
                                    ),
                                    text:
                                        _isCheckingSaveStatus
                                            ? 'Checking...'
                                            : (_isSaved ? 'Unsave' : 'Save'),
                                    color_text:
                                        _isSaved ? Color(0xff123fdb) : null,
                                    color_icon:
                                        _isSaved ? Color(0xff123fdb) : null,
                                    onTap: () {
                                      if (_isCheckingSaveStatus)
                                        return; // اگر در حال بررسی وضعیت است، کاری انجام نده

                                      HapticFeedback.lightImpact();
                                      if (_isSaved) {
                                        _toggleSaveStatus(); // اگر قبلاً سیو شده، وضعیت را تغییر بده
                                      } else {
                                        _showSaveDirectorySheet(); // اگر سیو نشده، باتم شیت را نمایش بده
                                      }
                                    },
                                  ),
                                  _buildMenuItem(
                                    icon: AssetImage(
                                      "assets/icons/brain-illustration-1-svgrepo-com.png",
                                    ),
                                    text: 'Interaction',
                                    color_text: Color.fromARGB(255, 0, 176, 0),
                                    color_icon: Color.fromARGB(255, 0, 176, 0),
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      print(
                                        'Interaction with article: ${widget.articleId}',
                                      );
                                      _toggleMenu();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildMenuItem({
    required AssetImage icon,
    required String text,
    required VoidCallback onTap,
    Color? color_icon,
    Color? color_text,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).extension<IconColors>()!;

    return Material(
      color: const Color.fromARGB(0, 6, 4, 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              ImageIcon(
                icon,
                size: 20,
                color: color_icon ?? iconColor.iconColor,
              ),
              SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Outfit-Medium",
                  color: color_text ?? textTheme.bodyMedium!.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).extension<IconColors>()!;

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: IconButton(
        key: _buttonKey,
        icon: Icon(Icons.more_vert, color: iconColor.iconColor),
        onPressed: _toggleMenu,
      ),
    );
  }
}
