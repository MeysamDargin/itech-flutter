import 'package:flutter/material.dart';

class HeaderButton extends StatefulWidget {
  final String rightIcon;
  final String leftIcon;
  final int? rightIconSize;
  final int? leftIconSize;
  final VoidCallback? onLeftIconPressed; // رویداد برای آیکون چپ
  final VoidCallback? onRightIconPressed; // رویداد برای آیکون راست

  const HeaderButton({
    super.key,
    this.rightIcon = "assets/icons/search-svgrepo-com.png",
    this.leftIcon = "assets/icons/share.png",
    this.rightIconSize = 20,
    this.leftIconSize = 20,
    this.onLeftIconPressed,
    this.onRightIconPressed,
  });

  @override
  State<HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<HeaderButton> {
  @override
  Widget build(BuildContext context) {
    return _buildHeaderButton();
  }

  Widget _buildHeaderButton() {
    return Container(
      height: 53,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min, // تنظیم اندازه بر اساس محتوا
        children: [
          // Search icon in white circle
          GestureDetector(
            onTap: widget.onLeftIconPressed,
            child: Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: ImageIcon(
                  AssetImage(widget.rightIcon),
                  color: Colors.black87,
                  size: widget.leftIconSize?.toDouble() ?? 20.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Notification icon with red dot in white circle
          GestureDetector(
            onTap: widget.onRightIconPressed,
            child: Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ImageIcon(
                      AssetImage(widget.leftIcon),
                      color: Colors.black87,
                      size: widget.rightIconSize?.toDouble() ?? 25.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
