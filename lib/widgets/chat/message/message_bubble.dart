import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itech/models/chat/message_model.dart';
import 'package:itech/screen/pageUser/profile_page.dart';
import 'package:itech/widgets/chat/message/reply_content.dart';
import 'package:itech/widgets/chat/status_icon.dart';
import 'package:itech/widgets/chat/show_chat_options.dart';
import 'package:itech/utils/url.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool isMe;
  final String recipientAvatar;
  final Function(String) scrollToMessage;
  final Function(Message)? onReply;
  final Function(Message)? onEdit;
  final Function(Message)? onDelete;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.isMe,
    required this.recipientAvatar,
    required this.scrollToMessage,
    this.onReply,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userInfo = message.userInfo;
    final replyInfo = message.replyToInfo;

    // Get user's name from userInfo or fallback to userId
    final String userName =
        userInfo != null
            ? "${userInfo['first_name']} ${userInfo['last_name']}"
            : "کاربر ${message.userId}";
    final String userName2 = userInfo?['username'] ?? "کاربر ${message.userId}";

    // Get profile picture URL or fallback to avatar
    final String? profilePicture = userInfo?['profile_picture'];

    return Padding(
      padding: EdgeInsets.only(bottom: isLastInGroup ? 8 : 2),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            isLastInGroup
                ? CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      profilePicture != null
                          ? NetworkImage("${ApiAddress.baseUrl}$profilePicture")
                              as ImageProvider
                          : AssetImage(recipientAvatar) as ImageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    print("Error loading avatar image: $exception");
                  },
                  child: Center(
                    child: Text(
                      userName.isNotEmpty
                          ? userName.substring(0, min(1, userName.length))
                          : "?",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                : SizedBox(width: 32),
          SizedBox(width: !isMe ? 8 : 0),
          GestureDetector(
            onTapDown: (details) {
              // Get the global position of the tap
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset position = box.localToGlobal(details.localPosition);

              // Show message options at tap position
              showMessageOptionsAtPosition(
                context,
                message,
                position,
                onReply:
                    onReply ??
                    (message) {
                      // Default reply handler if not provided
                    },
                onCopy: (message) {
                  Clipboard.setData(ClipboardData(text: message.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Message copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onDelete:
                    isMe && onDelete != null
                        ? (message) {
                          onDelete!(message);
                        }
                        : null,
                onForward: (message) {
                  // Forward functionality would be implemented here
                  print('Forward message: ${message.id}');
                },
                onEdit:
                    isMe && onEdit != null
                        ? (message) {
                          onEdit!(message);
                        }
                        : null,
              );
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Color(0xFFE3FEE0) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    isFirstInGroup
                        ? 16
                        : isMe
                        ? 16
                        : 5,
                  ),
                  topRight: Radius.circular(
                    isFirstInGroup
                        ? 16
                        : isMe
                        ? 5
                        : 16,
                  ),
                  bottomLeft: Radius.circular(
                    isMe ? 16 : (isLastInGroup ? 0 : 5),
                  ),
                  bottomRight: Radius.circular(
                    isMe ? (isLastInGroup ? 0 : 5) : 16,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isMe == false)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    UserProfilePage(username: userName2),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(3),
                        child: Text(
                          "${userName}",
                          style: TextStyle(
                            fontFamily: 'a-m',
                            color: Color(0xFFCC5049),
                          ),
                        ),
                      ),
                    ),
                  if (replyInfo != null)
                    BuildReplyContent(
                      replyInfo: replyInfo,
                      isMe: isMe,
                      scrollToMessage: scrollToMessage,
                    ),
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.black : Colors.black,
                      fontSize: 16,
                      fontFamily: 'a-m',
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: isMe ? Color(0xff5DA853) : Colors.black54,
                          fontSize: 14,
                          fontFamily: 'a-r',
                        ),
                      ),
                      SizedBox(width: 3),
                      if (isMe)
                        BuildStatusIcon(
                          sendStatus: message.sendStatus,
                          seen: message.seen,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
