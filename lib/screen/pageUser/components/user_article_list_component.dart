import 'package:flutter/material.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/screen/Article/show_article.dart';
import 'package:itech/widgets/article/popup/show_post_options.dart'
    as custom_menu;

class UserArticleListComponent extends StatelessWidget {
  final List<Map<String, dynamic>> articles;
  final String? username;
  final String? profile_picture;

  const UserArticleListComponent({
    Key? key,
    required this.articles,
    this.username,
    this.profile_picture,
  }) : super(key: key);

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
      final String hour = localDateTime.hour.toString().padLeft(2, '0');
      final String minute = localDateTime.minute.toString().padLeft(2, '0');

      return '$day $month at $hour:$minute';
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
                            source: 'user-profile-page',
                          ),
                    ),
                  );
                } else {
                  print('ERROR: No valid _id found in article: $article');
                }
              },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header (profile picture, name, date, menu)
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      profile_picture == null
                          ? AssetImage(
                            'assets/img/44884218_345707102882519_2446069589734326272_n.jpg',
                          )
                          : NetworkImage(
                            '${ApiAddress.baseUrl}${profile_picture}',
                          ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${username}',
                      style: TextStyle(fontSize: 18, fontFamily: "a-r"),
                    ),
                    Text(
                      '${_formatDate(article != null ? article['createdAt'] : null)}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontFamily: "a-r",
                      ),
                    ),
                  ],
                ),
                Spacer(),
                custom_menu.PopupMenuButton(article: article),
              ],
            ),

            // Post content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article != null ? '${article['title']}' : 'Jonatan Braut',
                    style: TextStyle(fontSize: 16, fontFamily: "a-m"),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

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
          ],
        ),
      ),
    );
  }
}
