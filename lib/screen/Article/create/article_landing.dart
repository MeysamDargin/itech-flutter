import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/screen/Article/show_article.dart';
import 'package:itech/screen/Home/home.dart';
import 'package:itech/screen/buttonBar/ButtonNavbar.dart';

class ArticleLanding extends StatefulWidget {
  final String articleId;
  const ArticleLanding({super.key, required this.articleId});

  @override
  State<ArticleLanding> createState() => _ArticleLandingState();
}

class _ArticleLandingState extends State<ArticleLanding> {
  @override
  Widget build(BuildContext context) {
    final String articleid = widget.articleId;
    final screenWidth = MediaQuery.of(context).size.width;

    // سایز فونت دکمه‌ها بر اساس عرض صفحه
    double buttonFontSize = screenWidth > 350 ? 16 : 12;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(), // Spacer در بالا
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Image(
                    image: AssetImage("assets/icons/check-article.png"),
                    width: 80,
                    height: 80,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Your story has been \n published!",
                    style: TextStyle(fontSize: 30, fontFamily: 'g-b'),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Dont forget to share whith your friends to let \n them know you have an amazing story",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'outfit',
                      color: Color.fromARGB(255, 108, 108, 108),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(thickness: 1, color: Colors.grey.shade300),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 350 ? 32 : 16,
                        vertical: 16,
                      ),
                      borderRadius: BorderRadius.circular(99),
                      color: const Color.fromARGB(255, 242, 243, 251),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ButtonNavbar(0),
                          ),
                          (route) =>
                              false, // This will remove all previous routes
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Back to Home",
                          style: TextStyle(
                            color: const Color(0xff123fdb),
                            fontSize: buttonFontSize,
                            fontFamily: "outfit-Medium",
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 350 ? 32 : 16,
                        vertical: 16,
                      ),
                      borderRadius: BorderRadius.circular(99),
                      color: const Color(0xff123fdb),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder:
                                (context) => ShowArticle(
                                  source: 'view-story',
                                  articleId: articleid,
                                ),
                          ),
                        );
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "View Story",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: buttonFontSize,
                            fontFamily: "outfit-Medium",
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
