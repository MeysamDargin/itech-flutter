import 'package:flutter/material.dart';
import 'package:itech/screen/buttonBar/ButtonNavbar.dart';
import 'package:itech/screen/category/show_category.dart';
import 'package:itech/screen/pageUser/profile_page.dart';

class ArticleMetaInfoWidget extends StatelessWidget {
  final String category;
  final String date;
  final String source;
  final int userLoginid;
  final String sourceAbbreviation;
  final dynamic useridArticle;
  final Color sourceColor;

  const ArticleMetaInfoWidget({
    Key? key,
    required this.category,
    this.date = "Feb 28, 2023",
    this.useridArticle = 0,
    this.userLoginid = 0,
    this.source = "CNN Indonesia",
    this.sourceAbbreviation = "CNN",
    this.sourceColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).size.width * 0.03;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenPadding),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (useridArticle == userLoginid) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ButtonNavbar(3)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(username: source),
                  ),
                );
              }
            },
            child: Container(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: Image.network(
                      sourceAbbreviation,
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 35,
                            height: 35,
                            color: Colors.grey[200],
                            child: Image(
                              image: AssetImage(
                                "assets/img/44884218_345707102882519_2446069589734326272_n.jpg",
                              ),
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  Text(
                    source,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'outfit',
                      color: textTheme.bodyMedium!.color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),
          Text("•", style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 6),
          Text(date, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(width: 6),
          const SizedBox(width: 6),
          Text("•", style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 6),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowCategory(categoryName: category),
                ),
              );
            },
            child: Text(
              category,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),
    );
  }
}
