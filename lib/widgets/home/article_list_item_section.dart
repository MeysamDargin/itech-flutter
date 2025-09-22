import 'package:flutter/material.dart';
import 'package:itech/models/article/article_recommended_model.dart';
import 'package:itech/widgets/public/article_list_item.dart';
import 'package:shimmer/shimmer.dart';

class ArticleListSection extends StatelessWidget {
  final bool isLoading;
  final List<RecommendedArticle> articles;
  final String selectedCategoryName;
  final Function(String) getAuthorNameByCategory;

  const ArticleListSection({
    Key? key,
    required this.isLoading,
    required this.articles,
    required this.selectedCategoryName,
    required this.getAuthorNameByCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _getFilteredArticles();

    if (isLoading) {
      return _buildArticleListShimmer();
    }

    if (articles.isEmpty) {
      return const Center(child: Text("No articles available"));
    }

    if (filteredArticles.isEmpty) {
      return _buildEmptyCategory();
    }

    return _buildArticleList(filteredArticles);
  }

  List<RecommendedArticle> _getFilteredArticles() {
    if (selectedCategoryName == 'All') {
      return articles;
    } else {
      return articles
          .where(
            (article) =>
                article.category.toLowerCase() ==
                selectedCategoryName.toLowerCase(),
          )
          .toList();
    }
  }

  Widget _buildArticleList(List<RecommendedArticle> articles) {
    return Column(
      children: List.generate(articles.length, (index) {
        final article = articles[index];
        return ArticleListItem(
          articleId: article.id,
          imageUrl: article.imgCover,
          title: article.title,
          likesCount: article.likesCount,
          readsCount: article.readsCount,
          commentsCount: article.commentsCount,
          category: article.category,
          username: article.username,
          profilePicture: article.profilePicture,
          date: article.createdAt, // This should be dynamic
        );
      }),
    );
  }

  Widget _buildArticleListShimmer() {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(width: 150, height: 16, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCategory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: AssetImage("assets/img/Humaaans - Paperwork.png"),
            width: 90,
          ),
          const SizedBox(height: 16),
          Text(
            "No articles found in this category",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: "a-r",
            ),
          ),
        ],
      ),
    );
  }
}
