import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:itech/service/ai/chat_bot_article_service.dart'; // سرویس جدید

class AiChatInput extends StatefulWidget {
  final Function(String)? onSendMessage;
  final String? hintText;
  final String? articleText;
  final int? userId;
  final double? borderRadius;
  final Function(bool)? onChatInputChanged;

  const AiChatInput({
    super.key,
    this.onSendMessage,
    this.articleText,
    this.userId,
    this.hintText = 'Ask AI...',
    this.borderRadius = 25.0,
    this.onChatInputChanged,
  });

  @override
  State<AiChatInput> createState() => _AiChatInputState();
}

class _AiChatInputState extends State<AiChatInput>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  final ChatBotArticle _chatBotService = ChatBotArticle(); // سرویس چت

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });

    // تنظیم AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // انیمیشن گلو (درخشش)
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // انیمیشن مقیاس (از 0.8 به 1.0)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // انیمیشن اسلاید (از پایین به بالا)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // شروع انیمیشن ورود
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSendMessage?.call(_controller.text.trim());
      _sendToServer(_controller.text.trim()); // ارسال به سرور
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  // تابع ارسال متن به سرور
  void _sendToServer(String message) async {
    await _chatBotService.chatBotArticle(
      message,
      widget.articleText!,
      widget.userId!,
    );
  }

  void _closeChatInput() {
    // اجرای انیمیشن خروج قبل از بستن
    _animationController.reverse().then((_) {
      widget.onChatInputChanged?.call(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return GradientShadowBox(
                  blurStrength: 30 * _glowAnimation.value,
                  radius: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius!),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: LiquidGlass(
                        shape: LiquidRoundedSuperellipse(
                          borderRadius: Radius.circular(50),
                        ),
                        settings: LiquidGlassSettings(
                          thickness: 16,
                          blur: 800,
                          lightAngle: 1,
                          lightIntensity: 1,
                          ambientStrength: 20,
                          chromaticAberration: 0,
                          refractiveIndex: 1.2,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 255, 240, 201),
                                Color.fromARGB(255, 246, 252, 255),
                                Color.fromARGB(255, 228, 236, 255),
                              ],
                            ),
                            color: Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(
                              widget.borderRadius! - 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              // فیلد متنی
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'a-r',
                                  ),
                                  decoration: InputDecoration(
                                    hintText: widget.hintText,
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 16,
                                      fontFamily: 'a-r',
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 0,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.send,
                                  onSubmitted: (_) => _sendMessage(),
                                  maxLines: 1,
                                ),
                              ),
                              // دکمه‌های اکشن
                              Row(
                                children: [
                                  // دکمه ارسال
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 12),
                                    child:
                                        _hasText
                                            ? GestureDetector(
                                              onTap: _sendMessage,
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                child: const Icon(
                                                  Icons.arrow_upward,
                                                  color: Colors.black,
                                                  size: 20,
                                                ),
                                              ),
                                            )
                                            : Container(),
                                  ),
                                  // دکمه بستن
                                  GestureDetector(
                                    onTap: _closeChatInput,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class GradientShadowBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blurStrength;
  final double spread;

  const GradientShadowBox({
    super.key,
    required this.child,
    this.radius = 25,
    this.blurStrength = 30,
    this.spread = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // لایه سایه گرادینتی
        Positioned(
          left: -spread,
          right: -spread,
          top: -spread,
          bottom: -spread,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurStrength,
              sigmaY: blurStrength,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius + spread),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 170, 0),
                    Color.fromARGB(255, 0, 170, 255),
                    Color.fromARGB(255, 49, 118, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        // لایه محتوای اصلی
        child,
      ],
    );
  }
}
