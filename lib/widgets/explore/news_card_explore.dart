import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/screen/Article/show_article.dart';
import 'package:itech/widgets/home/popup/show_article_options.dart'
    as custom_menu;

class NewsCardExplore extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String source;
  final String title;
  final String profileImg;
  final int readsCount;
  final int commentsCount;
  final String articleId;
  final DateTime createdAt;

  const NewsCardExplore({
    Key? key,
    required this.imageUrl,
    required this.category,
    required this.source,
    required this.title,
    required this.articleId,
    required this.readsCount,
    required this.commentsCount,
    required this.profileImg,
    required this.createdAt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ShowArticle(articleId: articleId, source: 'explore'),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(left: 1, right: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header (profile picture, name, date, menu)
            // Post image
            Container(
              width: double.infinity,
              height: 180,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl,
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
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontFamily: "a-b"),
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
                      profileImg == null
                          ? AssetImage(
                            'assets/img/44884218_345707102882519_2446069589734326272_n.jpg',
                          )
                          : NetworkImage(profileImg),
                ),
                SizedBox(width: 10),

                Text(source, style: TextStyle(fontSize: 16, fontFamily: "a-r")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${_formatDate(createdAt.toString())}',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 134, 134, 134),
                        fontSize: 14,
                        fontFamily: "a-r",
                      ),
                    ),
                    SizedBox(width: 10),
                    Row(
                      children: [
                        Image(
                          image: AssetImage('assets/icons/eye-svgrepo-com.png'),
                          color: Colors.grey[400],
                          width: 15,
                        ),
                        SizedBox(width: 5),
                        Text(
                          // "${Provider.of<GetMyArticleManager>(context).likesCount}",
                          readsCount.toString(),
                          style: TextStyle(fontFamily: 'm-m'),
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                    Row(
                      children: [
                        Image(
                          image: AssetImage(
                            'assets/icons/chat-round-dots-svgrepo-com (1).png',
                          ),
                          color: Colors.grey[400],
                          width: 15,
                        ),
                        SizedBox(width: 5),
                        Text(
                          // "${Provider.of<GetMyArticleManager>(context).likesCount}",
                          readsCount.toString(),
                          style: TextStyle(fontFamily: 'm-m'),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    custom_menu.PopupMenuButton(
                      articleId: articleId,
                      isSaved:
                          false, // Default state, can be updated if you have this information
                      onSavedStatusChanged: (isSaved) {
                        // Handle saved status change if needed
                        print(
                          'Article $articleId saved status changed to: $isSaved',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
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
}
