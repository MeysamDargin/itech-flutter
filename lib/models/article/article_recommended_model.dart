import 'dart:convert';

ArticleRecommendedModel welcomeFromJson(String str) =>
    ArticleRecommendedModel.fromJson(json.decode(str));

String welcomeToJson(ArticleRecommendedModel data) =>
    json.encode(data.toJson());

class ArticleRecommendedModel {
  String status;
  List<RecommendedArticle> articles;

  ArticleRecommendedModel({required this.status, required this.articles});

  factory ArticleRecommendedModel.fromJson(Map<String, dynamic> json) =>
      ArticleRecommendedModel(
        status: json["status"],
        articles: List<RecommendedArticle>.from(
          json["articles"].map((x) => RecommendedArticle.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "articles": List<dynamic>.from(articles.map((x) => x.toJson())),
  };
}

class RecommendedArticle {
  String id;
  String title;
  String category;
  String imgCover;
  String username;
  String profilePicture;
  int likesCount;
  int readsCount;
  int commentsCount;
  DateTime createdAt;

  RecommendedArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.imgCover,
    required this.username,
    required this.profilePicture,
    required this.likesCount,
    required this.createdAt,
    required this.readsCount,
    required this.commentsCount,
  });

  factory RecommendedArticle.fromJson(Map<String, dynamic> json) =>
      RecommendedArticle(
        id: json["id"],
        title: json["title"],
        category: json["category"],
        imgCover: json["imgCover"],
        username: json["username"],
        profilePicture: json["profilePicture"],
        likesCount: json["likes_count"],
        commentsCount: json["comments_count"],
        readsCount: json["reads_count"],
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "category": category,
    "imgCover": imgCover,
    "username": username,
    "profilePicture": profilePicture,
    "likesCount": likesCount,
    "commentsCount": commentsCount,
    "readsCount": readsCount,
    "createdAt": createdAt.toIso8601String(),
  };
}
