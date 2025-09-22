import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // برای HapticFeedback
import 'package:itech/screen/Article/edit/edit_article_page.dart';
import 'package:itech/service/article/article_delete.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// Custom Glassmorphism Widget
class GlassMorphism extends StatelessWidget {
  const GlassMorphism({
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
  final Map<String, dynamic>? article;

  const PopupMenuButton({Key? key, this.article}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
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
          (context) => Stack(
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
                    !showBelow ? screenHeight - buttonPosition.dy + 10 : null,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: GlassMorphism(
                      blur: 15,
                      opacity: 0.7,
                      color: Colors.white,
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
                                  "assets/icons/edit-1-svgrepo-com (1).png",
                                ),
                                text: 'Edit',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  print(
                                    'Edit article: ${widget.article?['_id']}',
                                  );
                                  _toggleMenu();

                                  // انتقال به صفحه ویرایش مقاله
                                  if (widget.article != null &&
                                      widget.article!['_id'] != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditArticlePage(
                                              articleId:
                                                  widget.article!['_id']
                                                      .toString(),
                                            ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              _buildMenuItem(
                                icon: AssetImage(
                                  "assets/icons/delete-f-svgrepo-com.png",
                                ),
                                text: 'Delete',
                                color_text: Color.fromARGB(255, 255, 52, 52),
                                color_icon: Color.fromARGB(255, 255, 52, 52),
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  print('Delete button tapped');

                                  if (widget.article != null &&
                                      widget.article!['_id'] != null) {
                                    final String articleId =
                                        widget.article!['_id'].toString();
                                    print('Article ID to delete: $articleId');

                                    // Show loading indicator
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (context) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                    );

                                    // Call delete service
                                    print('Creating delete service instance');
                                    final ArticleDeleteService deleteService =
                                        ArticleDeleteService();
                                    print('Calling deleteArticle method');
                                    final result = await deleteService
                                        .deleteArticle(articleId);
                                    print('Delete result: $result');

                                    // Close loading indicator
                                    Navigator.of(context).pop();

                                    // Close menu
                                    _toggleMenu();

                                    // Show result message with awesome snackbar
                                    final snackBar = SnackBar(
                                      elevation: 0,
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.transparent,
                                      duration: Duration(seconds: 3),
                                      content: AwesomeSnackbarContent(
                                        messageTextStyle: TextStyle(
                                          fontFamily: 'outfit-Medium',
                                        ),
                                        title:
                                            result['status'] == 'success'
                                                ? 'Success!'
                                                : 'Error!',
                                        message:
                                            result['status'] == 'success'
                                                ? 'Article was deleted successfully'
                                                : result['message'] ??
                                                    'Error deleting article',
                                        contentType:
                                            result['status'] == 'success'
                                                ? ContentType.success
                                                : ContentType.failure,
                                      ),
                                    );

                                    ScaffoldMessenger.of(context)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(snackBar);

                                    // If success, navigate back
                                    if (result['status'] == 'success') {
                                      print(
                                        'Article deleted successfully, navigating back',
                                      );
                                      // Give time for the snackbar to be visible before navigation
                                      await Future.delayed(
                                        Duration(milliseconds: 500),
                                      );

                                      // Use a more reliable way to navigate back
                                      if (Navigator.canPop(context)) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  }
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              ImageIcon(icon, size: 20, color: color_icon ?? Colors.black87),
              SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Outfit-Medium",
                  color: color_text ?? Colors.black87,
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
    return IconButton(
      key: _buttonKey,
      icon: Icon(Icons.more_vert, color: Colors.grey[800]),
      onPressed: _toggleMenu,
    );
  }
}
