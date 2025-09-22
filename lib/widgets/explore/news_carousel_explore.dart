import 'package:flutter/material.dart';
import 'package:itech/models/article/article_list_model.dart';
import 'package:itech/widgets/explore/news_card_explore.dart';
import 'package:itech/widgets/home/BreakingNews/news_card.dart';
import 'package:shimmer/shimmer.dart';

class NewsCarouselExplore extends StatelessWidget {
  final bool isLoading;
  final List<Article> articles;
  final double screenPadding;

  const NewsCarouselExplore({
    Key? key,
    required this.isLoading,
    required this.articles,
    required this.screenPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return isLoading
        ? _buildNewsCarouselShimmer(size, screenPadding)
        : _buildNewsCarousel(size, screenPadding);
  }

  Widget _buildNewsCarousel(Size size, double screenPadding) {
    return SizedBox(
      height: 400,
      width: size.width,
      child:
          articles.isEmpty
              ? const Center(child: Text("No articles available"))
              : PageView.builder(
                itemCount: articles.length,
                controller: PageController(
                  viewportFraction: 0.80,
                  initialPage: 0,
                ),
                padEnds: false,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  double leftPadding = index == 0 ? screenPadding : 0;
                  double rightPadding =
                      index == articles.length - 1 ? screenPadding : 8;

                  return Padding(
                    padding: EdgeInsets.only(
                      left: leftPadding,
                      right: rightPadding,
                    ),
                    child: NewsCardExplore(
                      imageUrl: article.imgCover,
                      category: article.category,
                      source: article.username,
                      profileImg: article.profilePicture,
                      title: article.title,
                      articleId: article.id,
                      createdAt: article.createdAt,
                      readsCount: article.readsCount,
                      commentsCount: article.likesCount,
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildNewsCarouselShimmer(Size size, double screenPadding) {
    return SizedBox(
      height: 225,
      width: size.width,
      child: PageView.builder(
        itemCount: 3,
        controller: PageController(viewportFraction: 0.92, initialPage: 0),
        padEnds: false,
        itemBuilder: (context, index) {
          double leftPadding = index == 0 ? screenPadding : 8;
          double rightPadding = index == 2 ? screenPadding : 8;

          return Padding(
            padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
