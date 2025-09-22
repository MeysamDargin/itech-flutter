import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:itech/screen/Article/show_article.dart';
import 'package:itech/utils/url.dart';

class LikeArticleNotification extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String articleCover;
  final String articleId;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onTimeTap;
  final bool isRead;

  const LikeArticleNotification({
    Key? key,
    required this.profileImageUrl,
    required this.username,
    required this.timeAgo,
    required this.onTap,
    required this.onTimeTap,
    required this.articleCover,
    required this.articleId,
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
                (context) => ShowArticle(
                  articleId: articleId,
                  source: 'notification-like',
                ),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isRead ? Colors.transparent : const Color(0xffF5F5F5),
          child: Row(
            children: [
              // Profile image
              Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
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
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
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
                            child: Icon(Icons.person, color: Colors.grey[600]),
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
                        fontSize: 17,
                        color: textTheme.bodyMedium!.color,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // متن "started following you" در پایین
                    Text(
                      'liked one of your article',
                      style: TextStyle(
                        fontFamily: 'g-m',
                        fontSize: 17,
                        color: textTheme.bodyMedium!.color,
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
                  height: 60,
                  width: 60,
                  constraints: BoxConstraints(minWidth: 85),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
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
      ),
    );
  }
}
