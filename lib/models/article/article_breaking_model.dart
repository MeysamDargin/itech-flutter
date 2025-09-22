import 'dart:convert';

ArticleBreakingModel welcomeFromJson(String str) =>
    ArticleBreakingModel.fromJson(json.decode(str));

String welcomeToJson(ArticleBreakingModel data) => json.encode(data.toJson());

class ArticleBreakingModel {
  String status;
  List<BreakingArticle> articles;

  ArticleBreakingModel({required this.status, required this.articles});

  factory ArticleBreakingModel.fromJson(Map<String, dynamic> json) =>
      ArticleBreakingModel(
        status: json["status"],
        articles: List<BreakingArticle>.from(
          json["articles"].map((x) => BreakingArticle.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "articles": List<dynamic>.from(articles.map((x) => x.toJson())),
  };
}

class BreakingArticle {
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

  BreakingArticle({
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

  factory BreakingArticle.fromJson(Map<String, dynamic> json) =>
      BreakingArticle(
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
