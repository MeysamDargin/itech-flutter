import 'package:flutter/material.dart';
import 'package:itech/models/chat/message_model.dart';

class MessageInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode focusNode;
  final bool isTyping;
  final bool isShowEmojiPicker;
  final Message? replyingToMessage;
  final Message? editingMessage;
  final Function() onCancelReply;
  final Function()? onCancelEdit;
  final Function() onSendMessage;
  final Function() onToggleEmojiPicker;
  final Function(String) onTextChanged;
  final Function() onInsertEmoji;

  const MessageInputArea({
    Key? key,
    required this.messageController,
    required this.focusNode,
    required this.isTyping,
    required this.isShowEmojiPicker,
    this.replyingToMessage,
    this.editingMessage,
    required this.onCancelReply,
    this.onCancelEdit,
    required this.onSendMessage,
    required this.onToggleEmojiPicker,
    required this.onTextChanged,
    required this.onInsertEmoji,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Reply preview area
        if (replyingToMessage != null) _buildReplyPreview(replyingToMessage!),

        // Edit preview area
        if (editingMessage != null) _buildEditPreview(editingMessage!),

        Row(
          children: [
            // Emoji button
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: IconButton(
                icon: Image.asset(
                  isShowEmojiPicker
                      ? "assets/icons/keyboard-svgrepo-com.png"
                      : "assets/icons/mood-smile.png",
                  color: isShowEmojiPicker ? Colors.black : Colors.black,
                  width: 30,
                  height: 30,
                ),
                onPressed: onToggleEmojiPicker,
              ),
            ),

            // Text input
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: messageController,
                  focusNode: focusNode,
                  style: TextStyle(color: Colors.black, fontFamily: 'a-m'),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText:
                        editingMessage != null
                            ? "Edit your message..."
                            : "type your Message...",
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'a-r',
                      fontSize: 17,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 11),
                    border: InputBorder.none,
                  ),
                  onChanged: onTextChanged,
                  onTap: () {
                    if (isShowEmojiPicker) {
                      onToggleEmojiPicker();
                    }
                  },
                ),
              ),
            ),

            // Send button
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF008edf),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Image.asset(
                  "assets/icons/send-2-svgrepo-com.png",
                  color: Colors.white,
                  width: 25,
                  height: 25,
                ),
                onPressed: isTyping ? onSendMessage : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReplyPreview(Message message) {
    final firstName = message.userInfo?['first_name'] ?? '';
    final lastName = message.userInfo?['last_name'] ?? '';
    final userId = message.userId.toString();
    final userName =
        (firstName.isNotEmpty || lastName.isNotEmpty)
            ? "$firstName $lastName"
            : "user $userId";
    final messageText = message.text;

    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xfffaeef3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: Color(0xffC7518B)),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Reply to $userName",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xffC7518B),
                      fontFamily: 'a-b',
                    ),
                  ),
                  Text(
                    messageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'a-r',
                      color: const Color.fromARGB(255, 129, 129, 129),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onCancelReply,
              child: Icon(Icons.close, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditPreview(Message message) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, color: Colors.blue[700]),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Editing message",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                      fontFamily: 'a-b',
                    ),
                  ),
                  Text(
                    message.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onCancelEdit != null)
              GestureDetector(
                onTap: onCancelEdit,
                child: Icon(Icons.close, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}
