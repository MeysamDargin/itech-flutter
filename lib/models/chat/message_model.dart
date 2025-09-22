class Message {
  final String text;
  final bool seen;
  final bool isMe;
  final DateTime timestamp;
  final String id;
  final String userId;
  final Map<String, dynamic>? userInfo;
  final Map<String, dynamic>? replyToInfo;
  final String sendStatus;

  Message({
    required this.text,
    required this.seen,
    required this.isMe,
    required this.timestamp,
    required this.id,
    required String userId,
    this.userInfo,
    this.replyToInfo,
    this.sendStatus = "sent",
  }) : this.userId = userId.toString();
}
