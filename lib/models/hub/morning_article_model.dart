class NewsDayArticleModel {
  final String status;
  final List<Article> articles;

  NewsDayArticleModel({required this.status, required this.articles});

  factory NewsDayArticleModel.fromJson(Map<String, dynamic> json) {
    var articlesJson = json['articles'] as List? ?? [];
    List<Article> articlesList =
        articlesJson.map((e) => Article.fromJson(e)).toList();

    return NewsDayArticleModel(
      status: json['status'] ?? '',
      articles: articlesList,
    );
  }
}

class Article {
  final String id;
  final String title;
  final String category;
  final String imgCover;
  final DateTime? createdAt;

  Article({
    required this.id,
    required this.title,
    required this.category,
    required this.imgCover,
    this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      imgCover: json['imgCover'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
