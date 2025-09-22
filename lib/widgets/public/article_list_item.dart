import 'package:flutter/material.dart';
import 'package:itech/main.dart';
import 'package:itech/screen/Article/show_article.dart';
import 'package:itech/widgets/home/popup/show_article_options.dart'
    as custom_menu;

class ArticleListItem extends StatelessWidget {
  final String articleId;
  final String imageUrl;
  final String title;
  final String category;
  final String? source;
  final String profilePicture;
  final String username;
  final int likesCount;
  final int readsCount;
  final int commentsCount;
  final DateTime date;

  const ArticleListItem({
    Key? key,
    required this.articleId,
    required this.imageUrl,
    required this.title,
    required this.category,
    this.source,
    required this.username,
    required this.profilePicture,
    required this.date,
    required this.likesCount,
    required this.readsCount,
    required this.commentsCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).extension<IconColors>()!;

    String _formatDate(DateTime date) {
      try {
        final DateTime localDateTime = date.toLocal();

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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ShowArticle(
                  articleId: articleId,
                  source: source ?? 'home-recommendation',
                ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          fontFamily: "a-b",
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: Image.network(
                              profilePicture,
                              width: 25,
                              height: 25,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    width: 25,
                                    height: 25,
                                    color: Colors.grey[200],
                                    child: Image.asset(
                                      "assets/img/headshot-placeholder.jpg",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 12,
                              color: textTheme.bodyMedium!.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    imageUrl,
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 120,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image(
                            image: AssetImage("assets/icons/image.png"),
                            width: 20,
                          ),
                        ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  _formatDate(date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Image.asset(
                  "assets/icons/eye-svgrepo-com.png",
                  width: 15,
                  height: 15,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  "${readsCount}",
                  style: TextStyle(
                    fontFamily: "a-m",
                    fontSize: 12,
                    color: Color.fromARGB(255, 75, 75, 75),
                  ),
                ),
                const SizedBox(width: 16),
                Image.asset(
                  "assets/icons/chat-round-dots-svgrepo-com (1).png",
                  width: 15,
                  height: 15,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  "${commentsCount}",
                  style: TextStyle(
                    fontFamily: "a-m",
                    fontSize: 12,
                    color: Color.fromARGB(255, 75, 75, 75),
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/icons/share.png',
                  width: 22,
                  color: iconColor.iconColor,
                ),
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
      ),
    );
  }
}
