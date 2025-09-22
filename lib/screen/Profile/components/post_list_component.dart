import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:provider/provider.dart';
import 'package:itech/screen/Article/show_article.dart';
import 'package:itech/widgets/article/popup/show_post_options.dart'
    as custom_menu;

class PostListComponent extends StatelessWidget {
  final List<Map<String, dynamic>> articles;

  const PostListComponent({Key? key, required this.articles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: articles.isEmpty ? 0 : articles.length,
      itemBuilder: (context, index) {
        return _buildPostItem(
          context,
          index < articles.length ? articles[index] : null,
        );
      },
    );
  }

  // Format date string to a readable format
  String _formatDate(String? dateString) {
    if (dateString == null) return '23 June at 16:32';

    try {
      final DateTime dateTime = DateTime.parse(dateString);
      final DateTime localDateTime = dateTime.toLocal();

      final List<String> months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      final String day = localDateTime.day.toString();
      final String month = months[localDateTime.month - 1];
      // final String hour = localDateTime.hour.toString().padLeft(2, '0');
      // final String minute = localDateTime.minute.toString().padLeft(2, '0');

      return '$day $month';
    } catch (e) {
      return '23 June at 16:32';
    }
  }

  // Build a single post item
  Widget _buildPostItem(BuildContext context, Map<String, dynamic>? article) {
    return InkWell(
      onTap:
          article == null
              ? null
              : () {
                if (article.containsKey('_id') && article['_id'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ShowArticle(
                            articleId: article['_id'].toString(),
                            source: 'my-profile-article',
                          ),
                    ),
                  );
                } else {
                  print('ERROR: No valid _id found in article: $article');
                }
              },
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header (profile picture, name, date, menu)
            // Post image
            Container(
              width: double.infinity,
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  '${ApiAddress.baseUrl}${article != null ? '${article['imgCover']}' : ''}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.image, size: 48, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            // Post content
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article != null ? '${article['title']}' : 'Jonatan Braut',
                    style: TextStyle(fontSize: 22, fontFamily: "a-b"),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage:
                      Provider.of<ProfileSocketManager>(
                                context,
                              ).profile_picture ==
                              null
                          ? AssetImage(
                            'assets/img/44884218_345707102882519_2446069589734326272_n.jpg',
                          )
                          : NetworkImage(
                            '${ApiAddress.baseUrl}${Provider.of<ProfileSocketManager>(context).profile_picture}',
                          ),
                ),
                SizedBox(width: 10),

                Text(
                  '${Provider.of<ProfileSocketManager>(context).userName}',
                  style: TextStyle(fontSize: 16, fontFamily: "a-r"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${_formatDate(article != null ? article['createdAt'] : null)}',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 134, 134, 134),
                        fontSize: 14,
                        fontFamily: "a-r",
                      ),
                    ),
                    SizedBox(width: 10),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.heart,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          // "${Provider.of<GetMyArticleManager>(context).likesCount}",
                          "${article != null ? article['likes_count'] ?? '0' : '0'}",
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.chat_bubble,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        SizedBox(width: 5),
                        Text(
                          // "${Provider.of<GetMyArticleManager>(context).commentsCount}",
                          "${article != null ? article['comments_count'] ?? '0' : '0'}",
                        ),
                      ],
                    ),
                  ],
                ),
                Row(children: [custom_menu.PopupMenuButton(article: article)]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
