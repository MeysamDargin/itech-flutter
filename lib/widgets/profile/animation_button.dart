import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedButton({required this.child, required this.onTap});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _glassAnimation;
  late Animation<double> _iconScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // سرعت انیمیشن پرشی و ژله‌ای
      vsync: this,
    );

    // انیمیشن بزرگ شدن با حالت پرش و ژله‌ای
    _scaleAnimation = TweenSequence<double>([
      // اول سریع بزرگ می‌شود
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.55, // کمی بیشتر از مقدار نهایی
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      // سپس کمی کوچک می‌شود (حس ژله‌ای)
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.5,
          end: 1.45,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    // انیمیشن سایه
    _shadowAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // انیمیشن شیشه‌ای شدن (0 = عادی، 1 = شیشه‌ای)
    _glassAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // انیمیشن بزرگ شدن آیکون
    _iconScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward(); // شروع انیمیشن بزرگ شدن و پرش و شیشه‌ای شدن
  }

  void _onTapUp(TapUpDetails details) {
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        _controller.reverse(); // برگشت به حالت اولیه با کمی تاخیر
        widget.onTap(); // اجرای تابع onTap
      }
    });
  }

  void _onTapCancel() {
    _controller.reverse(); // برگشت به حالت اولیه اگه tap کنسل شد
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _controller.forward(); // انیمیشن برای long press
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _controller.reverse(); // برگشت از long press
    widget.onTap(); // اجرای تابع onTap
  }

  // متد برای تشخیص دکمه سفید
  bool _isWhiteButton(Stack stackWidget) {
    // بررسی می‌کنیم آیا آیکون سیاه در استک وجود دارد
    // اگر آیکون سیاه باشد، پس دکمه سفید است
    for (var child in stackWidget.children) {
      if (child is Icon && child.color == Colors.black) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _shadowAnimation,
          _glassAnimation,
          _iconScaleAnimation,
        ]),
        builder: (context, child) {
          // تبدیل widget.child به کانتینر یا LiquidGlass بر اساس مقدار _glassAnimation
          Widget transformedChild;

          if (widget.child is Stack &&
              (widget.child as Stack).children.isNotEmpty) {
            // اگر فرزند یک Stack است (مثل دکمه آبی)
            final stackWidget = widget.child as Stack;

            // پیدا کردن آیکون در Stack
            Widget? iconWidget;
            Widget? backgroundWidget;

            for (var child in stackWidget.children) {
              if (child is Icon) {
                iconWidget = child;
              } else {
                backgroundWidget = child;
              }
            }

            // ساخت Stack جدید با آیکون بزرگ شده
            transformedChild = Stack(
              alignment: Alignment.center,
              children: [
                // پس‌زمینه (LiquidGlass یا کانتینر معمولی)
                if (_glassAnimation.value > 0.5)
                  backgroundWidget ??
                      SizedBox() // اگر انیمیشن فعال است، پس‌زمینه اصلی را نشان بده
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      // بررسی کنیم که آیا یک آیکون سفید است یا آبی
                      color:
                          _isWhiteButton(stackWidget)
                              ? Colors.white
                              : Color(0xff0179FD),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              _isWhiteButton(stackWidget)
                                  ? Colors.black.withOpacity(0.1)
                                  : Color(0xff0179FD).withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                // آیکون با مقیاس انیمیشن
                if (iconWidget != null)
                  Transform.scale(
                    scale: _iconScaleAnimation.value,
                    child: iconWidget,
                  ),
              ],
            );
          } else {
            // برای سایر انواع فرزندان
            transformedChild = widget.child;
          }

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: transformedChild,
          );
        },
      ),
    );
  }
}
