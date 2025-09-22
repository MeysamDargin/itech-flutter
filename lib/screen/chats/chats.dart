import 'package:flutter/material.dart';
import 'package:itech/providers/article_comments_socket.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:itech/widgets/chat/empty_chat.dart';
import 'package:itech/widgets/chat/message/message_bubble.dart';
import 'package:itech/widgets/chat/message/message_input_area.dart';
import 'package:itech/widgets/chat/show_emoji_picker.dart';
import 'package:itech/widgets/public/header_button.dart';
import 'package:provider/provider.dart';
import 'package:itech/service/comment/comment_service.dart';
import 'package:itech/service/comment/comment_edite_service.dart';
import 'package:itech/service/comment/comment_delete_service.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:math';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:itech/models/chat/message_model.dart';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  final String recipientName;
  final String recipientAvatar;
  final String lastSeen;
  final String? commentId;
  final String? new_comment_id;
  final String articleId;

  const ChatScreen({
    Key? key,
    this.recipientName = "Tech Talk",
    this.recipientAvatar =
        "assets/img/44884218_345707102882519_2446069589734326272_n.jpg",
    this.lastSeen = "Last seen 25 mins ago",
    required this.articleId,
    this.commentId,
    this.new_comment_id,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  List<Message> _messages = [];
  bool _isTyping = false;
  bool _isShowEmojiPicker = false;
  late ArticleCommentsSocketProvider _commentsProvider;

  // Add state for replying
  Message? _replyingToMessage;

  // Add state for editing
  Message? _editingMessage;

  // لیست کامنت‌هایی که در حال ارسال درخواست برای آنها هستیم
  final Set<String> _processingCommentIds = {};
  // سرویس کامنت برای ارسال درخواست‌ها و ایجاد کامنت
  final CommentService _commentService = CommentService();

  void _setReplyMessage(Message message) {
    setState(() {
      _replyingToMessage = message;
      _editingMessage = null; // Reset editing state
    });
    _focusNode.requestFocus();
  }

  void _setEditMessage(Message message) {
    setState(() {
      _editingMessage = message;
      _replyingToMessage = null; // Reset reply state
      _messageController.text =
          message.text; // Set text to message being edited
    });
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyingToMessage = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingMessage = null;
      _messageController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    print("ChatScreen initState for article ID: ${widget.articleId}");

    print("ChatScreen initState for commentId: ${widget.commentId}");
    print("ChatScreen initState for new_comment_id: ${widget.new_comment_id}");

    // اتصال به وب سوکت برای دریافت کامنت‌های مقاله
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
        "ChatScreen post frame callback for article ID: ${widget.articleId}",
      );

      // Ensure WebSocketManager is initialized
      Provider.of<ProfileSocketManager>(context, listen: false);
      print("WebSocketManager initialized");

      _commentsProvider = Provider.of<ArticleCommentsSocketProvider>(
        context,
        listen: false,
      );
      print("Provider obtained successfully");

      _commentsProvider.connectToArticleComments(widget.articleId);
      print("Connected to article comments websocket");

      _commentsProvider.requestComments();
      print("Requested comments from websocket");

      // تنظیم لیستنر برای تغییرات کامنت‌ها
      _setupCommentsListener();
      print("Comments listener setup complete");

      // اگر commentId نال نباشد، پس از دریافت کامنت‌ها به آن کامنت اسکرول کن
      if (widget.commentId != null) {
        // افزودن یک تاخیر کوتاه برای اطمینان از دریافت کامنت‌ها
        Future.delayed(Duration(seconds: 1), () {
          _scrollToSpecificComment(widget.commentId!);
        });
      }
      if (widget.new_comment_id != null) {
        // افزودن یک تاخیر کوتاه برای اطمینان از دریافت کامنت‌ها
        Future.delayed(Duration(seconds: 1), () {
          _scrollToSpecificNewComment(widget.new_comment_id!);
        });
      }
    });
  }

  // متد جدید برای اسکرول به کامنت خاص
  void _scrollToSpecificComment(String commentId) {
    print("Attempting to scroll to comment: $commentId");

    // پیدا کردن ایندکس کامنت در لیست پیام‌ها
    final index = _messages.indexWhere((message) => message.id == commentId);

    if (index != -1) {
      print("Found comment at index: $index");

      // اسکرول به موقعیت کامنت
      _scrollController.animateTo(
        index * 80.0, // تخمین ارتفاع هر پیام
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      // برجسته کردن کامنت (اختیاری)
      setState(() {
        // می‌توانید یک فیلد جدید به Message اضافه کنید تا کامنت را برجسته نشان دهد
        // و بعد از چند ثانیه آن را به حالت عادی برگردانید
      });
    } else {
      print("Comment with ID $commentId not found in the messages list");
    }
  }

  void _scrollToSpecificNewComment(String new_comment_id) {
    print("Attempting to scroll to new_comment_id: $new_comment_id");

    // پیدا کردن ایندکس کامنت در لیست پیام‌ها
    final index = _messages.indexWhere(
      (message) => message.id == new_comment_id,
    );

    if (index != -1) {
      print("Found comment at index: $index");

      // اسکرول به موقعیت کامنت
      _scrollController.animateTo(
        index * 80.0, // تخمین ارتفاع هر پیام
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      // برجسته کردن کامنت (اختیاری)
      setState(() {
        // می‌توانید یک فیلد جدید به Message اضافه کنید تا کامنت را برجسته نشان دهد
        // و بعد از چند ثانیه آن را به حالت عادی برگردانید
      });
    } else {
      print("Comment with ID $new_comment_id not found in the messages list");
    }
  }

  void _setupCommentsListener() {
    _commentsProvider.addListener(() {
      print("Comments listener triggered - comments updated");

      // Get current user ID from WebSocketManager
      final webSocketManager = Provider.of<ProfileSocketManager>(
        context,
        listen: false,
      );
      final currentUserId = webSocketManager.id.toString();
      print("Current user ID: $currentUserId");

      // تبدیل کامنت‌های دریافتی به پیام‌های چت
      final comments = _commentsProvider.comments;
      setState(() {
        _messages =
            comments.map((comment) {
              // Check if reply_to is a Map or a String ID
              Map<String, dynamic>? replyToInfo;
              final replyTo = comment['reply_to'];
              final isReply = replyTo != null && replyTo != "";

              // Handle different types of reply_to field
              if (isReply) {
                if (replyTo is Map<String, dynamic>) {
                  replyToInfo = replyTo;
                } else if (replyTo is String) {
                  // If it's just an ID string, create a minimal map with just the ID
                  replyToInfo = {'_id': replyTo};
                }
              }

              String messageText = comment['message'] ?? "";
              bool seen = comment['seen'] ?? false;

              // Check if this comment is from the current user
              final isCurrentUser =
                  comment['user_id'].toString() == currentUserId;
              print(
                "Comment user_id: ${comment['user_id']}, isCurrentUser: $isCurrentUser",
              );

              return Message(
                text: messageText,
                seen: seen,
                isMe:
                    isCurrentUser, // Use actual comparison with current user ID
                timestamp: DateTime.parse(comment['created_at']),
                id: comment['_id'],
                userId: comment['user_id'].toString(),
                userInfo: comment['user_info'],
                replyToInfo: replyToInfo,
                sendStatus: "sent",
              );
            }).toList();

        // مرتب‌سازی پیام‌ها بر اساس زمان
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // اسکرول به آخرین پیام
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _commentsProvider.closeConnection();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    // Get current user ID from WebSocketManager
    final webSocketManager = Provider.of<ProfileSocketManager>(
      context,
      listen: false,
    );
    final currentUserId = webSocketManager.id.toString();
    final messageText = _messageController.text.trim();

    // Check if we are editing a message
    if (_editingMessage != null) {
      _updateMessage(_editingMessage!.id, messageText);
      return;
    }

    // Check if we are replying to a message
    final replyToId = _replyingToMessage?.id;

    print("Sending message: $messageText, Reply to: $replyToId");

    // Create a temporary message ID
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    // Add message optimistically to the UI with "sending" status
    final optimisticReplyInfo =
        _replyingToMessage != null
            ? {
              '_id': _replyingToMessage!.id,
              'message': _replyingToMessage!.text,
              'user_info': _replyingToMessage!.userInfo,
            }
            : null;

    setState(() {
      _messages.add(
        Message(
          text: messageText,
          isMe: true,
          timestamp: DateTime.now(),
          id: tempId,
          userId: currentUserId,
          seen: false,
          sendStatus: "sending",
          replyToInfo: optimisticReplyInfo, // Use structured reply info
          userInfo: {
            'first_name': webSocketManager.first_name,
            'last_name': webSocketManager.last_name,
            'profile_picture': webSocketManager.profile_picture,
          },
        ),
      );

      // Sort messages by timestamp
      _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Scroll to bottom
      _scrollToBottom();
    });

    // پاک کردن متن پیام و وضعیت ریپلای
    _messageController.clear();
    setState(() {
      _isTyping = false;
      _replyingToMessage = null; // Reset reply state
    });

    // ارسال کامنت از طریق سرویس
    try {
      final result = await _commentService.createComment(
        widget.articleId,
        messageText,
        replyToId: replyToId, // Pass the ID here
      );

      if (result['status'] == 'success') {
        print("Comment sent successfully");
        // کامنت با موفقیت ارسال شد، نیازی به کار خاصی نیست
        // چون سرور از طریق وب‌سوکت کامنت جدید را ارسال می‌کند
      } else {
        print("Error sending comment: ${result['message']}");
        // نمایش خطا در UI
        setState(() {
          final index = _messages.indexWhere((m) => m.id == tempId);
          if (index != -1) {
            final failedMessage = Message(
              id: tempId,
              text: messageText,
              isMe: true,
              timestamp: _messages[index].timestamp,
              userId: currentUserId,
              userInfo: _messages[index].userInfo,
              replyToInfo: _messages[index].replyToInfo,
              seen: false,
              sendStatus: "error", // Mark as error
            );
            _messages[index] = failedMessage;
          }
        });
      }
    } catch (e) {
      print("Exception sending comment: $e");
      // نمایش خطا در UI
      setState(() {
        final index = _messages.indexWhere((m) => m.id == tempId);
        if (index != -1) {
          final failedMessage = Message(
            id: tempId,
            text: messageText,
            isMe: true,
            timestamp: _messages[index].timestamp,
            userId: currentUserId,
            userInfo: _messages[index].userInfo,
            replyToInfo: _messages[index].replyToInfo,
            seen: false,
            sendStatus: "error", // Mark as error
          );
          _messages[index] = failedMessage;
        }
      });
    }
  }

  // Method to update an existing message
  void _updateMessage(String messageId, String newText) async {
    if (newText.trim().isEmpty) return;

    final commentEditeService = CommentEditeService();

    // Optimistically update the message in UI
    setState(() {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final updatedMessage = Message(
          id: messageId,
          text: newText,
          isMe: _messages[index].isMe,
          timestamp: _messages[index].timestamp,
          userId: _messages[index].userId,
          userInfo: _messages[index].userInfo,
          replyToInfo: _messages[index].replyToInfo,
          seen: _messages[index].seen,
          sendStatus: "sending", // Mark as sending
        );
        _messages[index] = updatedMessage;
      }

      // Clear editing state
      _editingMessage = null;
      _messageController.clear();
      _isTyping = false;
    });

    try {
      // Call the edit service
      final result = await commentEditeService.editeComment(newText, messageId);

      if (result['status'] == 'success') {
        print("Comment updated successfully");
        // The server will send the updated comment via websocket
      } else {
        print("Error updating comment: ${result['message']}");
        // Show error in UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update message'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print("Exception updating comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Method to delete a message
  void _deleteMessage(Message message) async {
    // Create the service
    final commentDeleteService = CommentDeleteService();

    // Show confirmation dialog
    bool confirmDelete =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'Delete Message',
                  style: TextStyle(fontFamily: "a-b"),
                ),
                content: Text(
                  'Are you sure you want to delete this message?',
                  style: TextStyle(fontFamily: "a-r"),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel', style: TextStyle(fontFamily: "a-m")),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Colors.red, fontFamily: "a-m"),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirmDelete) return;

    // Optimistically remove the message from UI
    setState(() {
      _messages.removeWhere((m) => m.id == message.id);
    });

    try {
      // Call the delete service
      final result = await commentDeleteService.editeComment(message.id);

      if (result['status'] == 'success') {
        print("Comment deleted successfully");
        // The server will handle the deletion via websocket
      } else {
        print("Error deleting comment: ${result['message']}");
        // Show error and restore the message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete message'),
            duration: Duration(seconds: 2),
          ),
        );
        // Restore the message if deletion fails
        setState(() {
          _messages.add(message);
          _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        });
      }
    } catch (e) {
      print("Exception deleting comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: Duration(seconds: 2),
        ),
      );
      // Restore the message if deletion fails
      setState(() {
        _messages.add(message);
        _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isShowEmojiPicker = !_isShowEmojiPicker;
      if (_isShowEmojiPicker) {
        _focusNode.unfocus();
      } else {
        _focusNode.requestFocus();
      }
    });
  }

  // Scroll to a specific message ID
  void _scrollToMessage(String messageId) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      // This is a simplified scroll. For perfect accuracy,
      // we would need to calculate item heights.
      // However, this provides a good-enough experience.
      _scrollController.animateTo(
        index * 70.0, // Approximate height of a message bubble
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffD8E2ED),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tech Talk",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: "a-b",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            HeaderButton(
              rightIcon: "assets/icons/search-svgrepo-com.png",
              leftIcon: "assets/icons/share.png",
              leftIconSize: 20,
              rightIconSize: 25,
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/img/a04cfb781dae03e258248e4e08aa62c1.jpg',
            ),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
          children: [
            // Messages area
            Expanded(
              child:
                  _messages.isEmpty
                      ? BuildEmptyChat()
                      : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];

                          // Check if this message is part of a consecutive group
                          final bool isFirstInGroup =
                              index == 0 ||
                              _messages[index].userId !=
                                  _messages[index - 1].userId;
                          final bool isLastInGroup =
                              index == _messages.length - 1 ||
                              _messages[index].userId !=
                                  _messages[index + 1].userId;

                          return Slidable(
                            key: Key('slidable-${message.id}'),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              extentRatio: 0.2,
                              dismissible: DismissiblePane(
                                onDismissed: () {
                                  // This won't be called because confirmDismiss returns false
                                },
                                closeOnCancel: true,
                                confirmDismiss: () async {
                                  _setReplyMessage(message);
                                  return false; // Don't actually dismiss, just trigger the reply
                                },
                              ),
                              children: [
                                SlidableAction(
                                  autoClose: true,
                                  onPressed: (_) {
                                    _setReplyMessage(message);
                                  },
                                  backgroundColor: Color.fromARGB(
                                    198,
                                    64,
                                    86,
                                    255,
                                  ),
                                  foregroundColor: Colors.white,
                                  icon: Icons.reply,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ],
                            ),
                            child: VisibilityDetector(
                              key: Key('message-${message.id}'),
                              onVisibilityChanged: (visibilityInfo) {
                                if (visibilityInfo.visibleFraction > 0.7) {
                                  _checkAndMarkMessageAsSeen(message);
                                }
                              },
                              child: MessageBubble(
                                message: message,
                                isFirstInGroup: isFirstInGroup,
                                isLastInGroup: isLastInGroup,
                                isMe: message.isMe,
                                recipientAvatar: widget.recipientAvatar,
                                scrollToMessage: _scrollToMessage,
                                onReply: _setReplyMessage,
                                onEdit: _setEditMessage,
                                onDelete: _deleteMessage,
                              ),
                            ),
                          );
                        },
                      ),
            ),

            // Message input area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              color: Colors.white,
              child: MessageInputArea(
                messageController: _messageController,
                focusNode: _focusNode,
                isTyping: _isTyping,
                isShowEmojiPicker: _isShowEmojiPicker,
                replyingToMessage: _replyingToMessage,
                editingMessage: _editingMessage,
                onCancelReply: _cancelReply,
                onCancelEdit: _cancelEdit,
                onSendMessage: _sendMessage,
                onToggleEmojiPicker: _toggleEmojiPicker,
                onTextChanged: (text) {
                  setState(() {
                    _isTyping = text.isNotEmpty;
                  });
                },
                onInsertEmoji: () {
                  // Implement if needed
                },
              ),
            ),

            // Emoji Picker
            ShowEmojiPicker(
              isShowEmojiPicker: _isShowEmojiPicker,
              messageController: _messageController,
              onTextChanged: (text) {
                setState(() {
                  _isTyping = text.isNotEmpty;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // بررسی و علامت‌گذاری پیام به عنوان خوانده شده
  void _checkAndMarkMessageAsSeen(Message message) {
    // اگر پیام قبلاً خوانده شده یا متعلق به کاربر فعلی است یا در حال پردازش است، کاری انجام نمی‌دهیم
    if (message.seen) {
      // پیام قبلاً خوانده شده است
      return;
    }

    if (message.isMe) {
      // پیام متعلق به خود کاربر است، نیازی به علامت‌گذاری نیست
      return;
    }

    if (_processingCommentIds.contains(message.id)) {
      // پیام در حال پردازش است
      return;
    }

    // اضافه کردن به لیست در حال پردازش
    _processingCommentIds.add(message.id);
    print(
      'Marking message as seen: ${message.id} (${message.text.substring(0, min(20, message.text.length))}...)',
    );

    // ارسال درخواست برای علامت‌گذاری به عنوان خوانده شده
    _commentService
        .markCommentsAsSeen(widget.articleId, [message.id])
        .then((result) {
          // حذف از لیست در حال پردازش
          _processingCommentIds.remove(message.id);

          if (result['status'] == 'success') {
            print('Successfully marked message as seen: ${message.id}');

            // به‌روزرسانی وضعیت پیام در UI
            setState(() {
              final index = _messages.indexWhere((m) => m.id == message.id);
              if (index != -1) {
                final updatedMessage = Message(
                  id: message.id,
                  text: message.text,
                  isMe: message.isMe,
                  timestamp: message.timestamp,
                  userId: message.userId,
                  userInfo: message.userInfo,
                  replyToInfo: message.replyToInfo,
                  seen: true, // علامت‌گذاری به عنوان خوانده شده
                );
                _messages[index] = updatedMessage;
              }
            });
          } else {
            print('Failed to mark message as seen: ${result['message']}');
          }
        })
        .catchError((error) {
          // حذف از لیست در حال پردازش در صورت خطا
          _processingCommentIds.remove(message.id);
          print('Error marking message as seen: $error');
        });
  }
}
