import 'package:flutter/material.dart';

class BuildReplyContent extends StatefulWidget {
  final Map<String, dynamic> replyInfo;
  final bool isMe;
  final Function scrollToMessage;
  const BuildReplyContent({
    super.key,
    required this.replyInfo,
    required this.isMe,
    required this.scrollToMessage,
  });

  @override
  State<BuildReplyContent> createState() => _BuildReplyContentState();
}

class _BuildReplyContentState extends State<BuildReplyContent> {
  @override
  Widget build(BuildContext context) {
    return buildReplyContent(widget.replyInfo, widget.isMe);
  }

  Widget buildReplyContent(Map<String, dynamic> replyInfo, bool isMe) {
    // Check if we have full reply info or just the ID
    final bool hasFullInfo =
        replyInfo.containsKey('user_info') && replyInfo['user_info'] != null;

    String userName = "کاربر";
    if (hasFullInfo) {
      final firstName = replyInfo['user_info']?['first_name'] ?? '';
      final lastName = replyInfo['user_info']?['last_name'] ?? '';
      final userId = replyInfo['user_id']?.toString() ?? '';
      userName =
          (firstName.isNotEmpty || lastName.isNotEmpty)
              ? "$firstName $lastName"
              : "کاربر $userId";
    }

    final messageText = replyInfo['message'] ?? '';
    final originalMessageId = replyInfo['_id'];

    return GestureDetector(
      onTap: () {
        if (originalMessageId != null) {
          widget.scrollToMessage(originalMessageId);
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isMe ? Color(0xffD6F5D1) : const Color(0xffFAEEED),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                color: isMe ? Color(0xff5DA853) : Color(0xFFCC5049),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isMe ? Color(0xff5DA853) : Color(0xFFCC5049),
                        fontFamily: 'a-b',
                      ),
                    ),
                    if (messageText.isNotEmpty)
                      Text(
                        messageText,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: 'a-m',
                          color: isMe ? Colors.black : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        "Original message",
                        maxLines: 1,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
