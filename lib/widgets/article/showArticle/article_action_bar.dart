import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/main.dart';
import 'package:lottie/lottie.dart';
import 'package:itech/service/article/article_like_service.dart';
import 'package:itech/screen/chats/chats.dart';
import 'package:provider/provider.dart';
import 'package:itech/providers/article_comments_socket.dart';
import 'dart:ui';

class ArticleActionBar extends StatefulWidget {
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String articleId;
  final Function()? onCommentPressed;
  final Function() onSoundPressed;
  final Function(bool isLiked)? onLikeStatusChanged;
  final ScrollController? scrollController;

  const ArticleActionBar({
    Key? key,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.articleId,
    this.onCommentPressed,
    required this.onSoundPressed,
    this.onLikeStatusChanged,
    this.scrollController,
  }) : super(key: key);

  @override
  State<ArticleActionBar> createState() => _ArticleActionBarState();
}

class _ArticleActionBarState extends State<ArticleActionBar>
    with TickerProviderStateMixin {
  bool _showLikeAnimation = false;
  late AnimationController _likeAnimationController;
  late AnimationController _visibilityController;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  bool _isLiked = false;
  int _likesCount = 0;
  int _commentsCount = 0;
  final ArticleLikeService _articleLikeService = ArticleLikeService();
  bool _isProcessing = false;
  bool _isVisible = true;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likesCount = widget.likesCount;
    _commentsCount = widget.commentsCount;

    // Animation controller for like animation
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    // Animation controller for visibility
    _visibilityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      value: 1.0, // Start visible
    );

    // Slide animation (moves from bottom)
    _slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _visibilityController, curve: Curves.easeInOut),
    );

    // Opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _visibilityController, curve: Curves.easeInOut),
    );

    // Listen to scroll changes
    widget.scrollController?.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (widget.scrollController == null) return;

    final currentOffset = widget.scrollController!.offset;
    final isScrollingDown = currentOffset > _lastScrollOffset;
    final isScrollingUp = currentOffset < _lastScrollOffset;

    // Show/hide action bar based on scroll direction
    if (isScrollingDown && _isVisible && currentOffset > 100) {
      setState(() {
        _isVisible = false;
      });
      _visibilityController.reverse();
    } else if (isScrollingUp && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
      _visibilityController.forward();
    }

    _lastScrollOffset = currentOffset;
  }

  @override
  void didUpdateWidget(covariant ArticleActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      _isLiked = widget.isLiked;
    }
    if (oldWidget.likesCount != widget.likesCount) {
      _likesCount = widget.likesCount;
    }
    if (oldWidget.commentsCount != widget.commentsCount) {
      _commentsCount = widget.commentsCount;
    }
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _visibilityController.dispose();
    widget.scrollController?.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleLikePressed() async {
    // Prevent multiple rapid taps
    if (_isProcessing) return;

    // Store the previous state before changing
    bool wasLiked = _isLiked;

    setState(() {
      _isProcessing = true;

      // Only show animation when going from not liked to liked
      if (!_isLiked) {
        _showLikeAnimation = true;
        _likeAnimationController.reset();
        _likeAnimationController.forward().then((_) {
          setState(() {
            _showLikeAnimation = false;
          });
        });
      }

      // Update UI
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    try {
      // Call the API
      final result = await _articleLikeService.likeArticle(widget.articleId);

      // Notify parent about the like status change
      if (widget.onLikeStatusChanged != null) {
        widget.onLikeStatusChanged!(_isLiked);
      }

      // Handle the response if needed
      if (result['status'] == 'error') {
        print('Error liking article: ${result['message']}');
        // Revert the optimistic update if API call failed
        setState(() {
          _isLiked = wasLiked;
          _likesCount = wasLiked ? _likesCount + 1 : _likesCount - 1;
        });
      }
    } catch (e) {
      print('Exception while liking article: $e');
      // Revert the optimistic update on exception
      setState(() {
        _isLiked = wasLiked;
        _likesCount = wasLiked ? _likesCount + 1 : _likesCount - 1;
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // هدایت به صفحه کامنت‌ها
  void _navigateToComments() {
    print("Comment button tapped! Article ID: ${widget.articleId}");

    if (widget.onCommentPressed != null) {
      print("Using custom onCommentPressed callback");
      widget.onCommentPressed!();
    } else {
      print("Using default navigation to ChatScreen");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChangeNotifierProvider(
                create: (_) => ArticleCommentsSocketProvider(),
                child: ChatScreen(
                  articleId: widget.articleId,
                  recipientName: "نظرات مقاله",
                ),
              ),
        ),
      );
    }
  }

  // Helper method to format count numbers
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconColor = Theme.of(context).extension<IconColors>()!;

    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _opacityAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              height: 65,
              margin: EdgeInsets.only(left: 75, right: 75, bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 40,
                    offset: Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.1),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Like button
                  _buildEnhancedActionButton(
                    onTap: _handleLikePressed,
                    icon: _buildLikeIcon(),
                    count: _likesCount,
                    isActive: _isLiked,
                    activeColor: Colors.red,
                  ),

                  SizedBox(width: 20),

                  // Comments button
                  _buildEnhancedActionButton(
                    onTap: _navigateToComments,
                    icon: Icon(
                      CupertinoIcons.chat_bubble_text,
                      size: 27,
                      color: iconColor.iconColor,
                    ),
                    count: _commentsCount,
                    isActive: false,
                  ),

                  SizedBox(width: 20),

                  // Sound/read aloud button
                  _buildEnhancedSoundButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // متد برای ساخت دکمه‌های بهبود یافته با فضای کلیک بیشتر
  Widget _buildEnhancedActionButton({
    required VoidCallback onTap,
    required Widget icon,
    required int count,
    bool isActive = false,
    Color? activeColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // دایره با آیکون
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      isActive && activeColor != null
                          ? activeColor.withOpacity(0.1)
                          : colorScheme.background,
                  shape: BoxShape.circle,
                ),
                child: Center(child: icon),
              ),

              SizedBox(width: 8),

              // شمارنده کنار دایره
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'sf-m',
                  color:
                      isActive && activeColor != null
                          ? activeColor
                          : Colors.grey.shade700,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دکمه صدا بهبود یافته
  Widget _buildEnhancedSoundButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onSoundPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(2),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFF4055FF),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                "assets/icons/headphones-round-sound-svgrepo-com.png",
                width: 25,
                height: 25,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // متد کمکی برای ساخت آیکون لایک با انیمیشن
  Widget _buildLikeIcon() {
    final iconColor = Theme.of(context).extension<IconColors>()!;

    return Stack(
      alignment: Alignment.center,
      children: [
        // نمایش تصویر ثابت قلب
        Visibility(
          visible: !_showLikeAnimation,
          maintainState: true,
          maintainAnimation: true,
          maintainSize: true,
          child:
              _isLiked
                  ? Icon(CupertinoIcons.heart_fill, size: 33, color: Colors.red)
                  : Image.asset(
                    "assets/icons/like-svgrepo-com.png",
                    width: 27,
                    color: iconColor.iconColor,
                  ),
        ),
        // نمایش انیمیشن لوتی
        Visibility(
          visible: _showLikeAnimation,
          child: Lottie.asset(
            'assets/animation/Animation - 1748890848350.json',
            controller: _likeAnimationController,
            width: 49,
            height: 49,
            fit: BoxFit.cover,
            repeat: false,
            animate: true,
            onLoaded: (composition) {
              // تنظیم مدت زمان انیمیشن بر اساس مدت زمان فایل لوتی
              _likeAnimationController.duration = composition.duration;
            },
          ),
        ),
      ],
    );
  }
}
