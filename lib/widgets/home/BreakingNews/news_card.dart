import 'package:flutter/material.dart';
import 'package:itech/screen/Article/show_article.dart';
import 'package:itech/widgets/home/glass_morphism.dart';

class NewsCard extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String source;
  final String title;
  final String profileImg;
  final String articleId;

  const NewsCard({
    Key? key,
    required this.imageUrl,
    required this.category,
    required this.source,
    required this.title,
    required this.articleId,
    required this.profileImg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ShowArticle(
                  articleId: articleId,
                  source: 'home-breaking-news',
                ),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
        child: Stack(
          children: [
            Positioned.fill(child: Image.network(imageUrl, fit: BoxFit.cover)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GlassMorphism(
                blur: 15,
                opacity: 0.6,
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: "a-b",
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          profileImg,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 20,
                                height: 20,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: "a-m",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "a-b",
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
