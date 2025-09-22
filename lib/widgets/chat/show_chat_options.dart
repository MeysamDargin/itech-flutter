import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itech/models/chat/message_model.dart';

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

// Function to show message options at the tap position
void showMessageOptionsAtPosition(
  BuildContext context,
  Message message,
  Offset position, {
  Function(Message)? onReply,
  Function(Message)? onDelete,
  Function(Message)? onCopy,
  Function(Message)? onForward,
  Function(Message)? onEdit,
}) {
  // Create animation controller
  final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: Scaffold.of(context),
  );

  final scaleAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));

  final opacityAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

  // Get screen size
  final Size screenSize = MediaQuery.of(context).size;

  // Calculate position for the menu
  // Make sure it stays within screen bounds
  double left = position.dx - 80; // Center menu horizontally at tap point
  double top = position.dy + 20; // Position below tap point

  // Adjust if menu would go off screen
  if (left < 10) left = 10;
  if (left > screenSize.width - 170) left = screenSize.width - 170;
  if (top > screenSize.height - 200)
    top = position.dy - 180; // Show above tap point

  // Create the overlay entry with late variable
  late final OverlayEntry overlayEntry;

  // Function to close the overlay
  void closeOverlay() {
    controller.reverse().then((_) {
      overlayEntry.remove();
    });
  }

  overlayEntry = OverlayEntry(
    builder:
        (context) => Stack(
          children: [
            // Background overlay to dismiss on tap
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: closeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Glassmorphic Menu
            Positioned(
              left: left,
              top: top,
              child: GestureDetector(
                onTap: () {}, // Prevent taps on the menu from closing it
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: FadeTransition(
                    opacity: opacityAnimation,
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
                                  "assets/icons/reply-svgrepo-com.png",
                                ),
                                text: 'Reply',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (onReply != null) {
                                    onReply(message);
                                  }
                                  closeOverlay();
                                },
                              ),
                              _buildMenuItem(
                                icon: AssetImage(
                                  "assets/icons/copy-svgrepo-com.png",
                                ),
                                text: 'Copy',
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (onCopy != null) {
                                    onCopy(message);
                                  } else {
                                    Clipboard.setData(
                                      ClipboardData(text: message.text),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Message copied to clipboard',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                  closeOverlay();
                                },
                              ),
                              // Only show edit for user's own messages
                              if (message.isMe)
                                _buildMenuItem(
                                  icon: AssetImage(
                                    "assets/icons/edit-1-svgrepo-com (1).png",
                                  ),
                                  text: 'Edit',
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    if (onEdit != null) {
                                      onEdit(message);
                                    }
                                    closeOverlay();
                                  },
                                ),
                              if (message.isMe)
                                _buildMenuItem(
                                  icon: AssetImage(
                                    "assets/icons/delete-f-svgrepo-com.png",
                                  ),
                                  text: 'Delete',
                                  color_text: Color.fromARGB(255, 255, 52, 52),
                                  color_icon: Color.fromARGB(255, 255, 52, 52),
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    if (onDelete != null) {
                                      onDelete(message);
                                    }
                                    closeOverlay();
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
            ),
          ],
        ),
  );

  // Insert the overlay entry
  Overlay.of(context).insert(overlayEntry);

  // Start the animation
  controller.forward();
}

// Helper method to build menu items
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
            Image(
              image: icon,
              width: 20,
              height: 20,
              color: color_icon ?? Colors.black87,
            ),
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
