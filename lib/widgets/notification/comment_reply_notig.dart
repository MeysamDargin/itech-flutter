import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:itech/utils/url.dart';
import 'package:provider/provider.dart';
import 'package:itech/screen/chats/chats.dart';
import 'package:itech/providers/article_comments_socket.dart';

class CommentReplyNotification extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String commentText;
  final String articleCover;
  final String articleId;
  final String new_comment_id;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onTimeTap;
  final bool isRead;

  const CommentReplyNotification({
    Key? key,
    required this.profileImageUrl,
    required this.username,
    required this.timeAgo,
    required this.onTap,
    required this.onTimeTap,
    required this.commentText,
    required this.articleCover,
    required this.articleId,
    required this.new_comment_id,
    this.isRead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChangeNotifierProvider(
                  create: (_) => ArticleCommentsSocketProvider(),
                  child: ChatScreen(
                    articleId: articleId,
                    recipientName: "نظرات مقاله",
                    new_comment_id: new_comment_id,
                  ),
                ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            // Divider(height: 1, thickness: 0.5, color: Colors.grey[400]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isRead ? Colors.transparent : const Color(0xffF5F5F5),
              child: Row(
                children: [
                  // Profile image
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 0.5,
                      ),
                    ),
                    margin: EdgeInsets.only(bottom: 50),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child:
                          profileImageUrl.isNotEmpty
                              ? Image.network(
                                '${ApiAddress.baseUrl}${profileImageUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: Image.asset(
                                      "assets/img/44884218_345707102882519_2446069589734326272_n.jpg",
                                    ),
                                  );
                                },
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.grey[600],
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Notification text - جدا کردن نام کاربری و متن
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // نام کاربری در بالا
                        Text(
                          username,
                          style: TextStyle(
                            fontFamily: 'a-m',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textTheme.bodyMedium!.color,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // متن "started following you" در پایین
                        Text(
                          'replied to your comment',
                          style: TextStyle(
                            fontFamily: 'g-m',
                            fontSize: 17,
                            color: textTheme.bodyMedium!.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '"${commentText}"',
                          style: TextStyle(
                            fontFamily: 'a-m',
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),

                        GestureDetector(
                          onTap: () {
                            onTimeTap();
                          },
                          child: Text(
                            timeAgo,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontFamily: 'a-m',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Follow button
                  IntrinsicWidth(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 40),
                      height: 60,
                      width: 60,
                      constraints: BoxConstraints(minWidth: 85),
                      child: ClipRRect(
                        child: Image.network(
                          '${articleCover}',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Divider(height: 1, thickness: 0.5, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
