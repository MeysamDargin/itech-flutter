import 'dart:convert';

ArticleDetailModel welcomeFromJson(String str) =>
    ArticleDetailModel.fromJson(json.decode(str));

String welcomeToJson(ArticleDetailModel data) => json.encode(data.toJson());

class ArticleDetailModel {
  String status;
  Article article;

  ArticleDetailModel({required this.status, required this.article});

  factory ArticleDetailModel.fromJson(Map<String, dynamic> json) =>
      ArticleDetailModel(
        status: json["status"],
        article: Article.fromJson(json["article"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "article": article.toJson(),
  };
}

class Article {
  String id;
  String title;
  String text;
  String delta;
  String category;
  String imgCover;
  dynamic userId; // Changed to dynamic to handle both int and String
  String? collection;
  String? username;
  String? bio;
  String? profilePicture;
  String? createdAt; // اضافه شده و اختیاری است
  String? updatedAt; // اضافه شده و اختیاری است
  dynamic likesCount; // تغییر به dynamic برای پشتیبانی از String و int
  dynamic commentsCount; // تغییر به dynamic برای پشتیبانی از String و int
  bool? isLiked; // اضافه شده و اختیاری است
  bool? isSaved;

  Article({
    required this.id,
    required this.title,
    required this.text,
    required this.delta,
    required this.category,
    required this.imgCover,
    this.userId,
    this.collection,
    this.username,
    this.bio,
    this.profilePicture,
    this.createdAt, // اختیاری
    this.updatedAt, // اختیاری
    this.isLiked,
    this.likesCount,
    this.commentsCount,
    this.isSaved,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    // Get userId from json (can be int, String, or null)
    var rawUserId = json["userId"];

    return Article(
      id: json["id"],
      title: json["title"],
      text: json["text"],
      delta: json["delta"],
      category: json["category"],
      imgCover: json["imgCover"],
      userId: rawUserId, // Store as dynamic
      collection: json["collection"],
      username: json["username"],
      bio: json["bio"],
      profilePicture: json["profilePicture"],
      createdAt: json["createdAt"], // اگر null باشد، مشکلی ندارد
      updatedAt: json["updatedAt"], // اگر null باشد، مشکلی ندارد
      isLiked: json["isLiked"], // اگر null باشد، مشکلی ندارد
      isSaved: json["isSaved"], // اگر null باشد، مشکلی ندارد
      likesCount: json["likes_count"],
      commentsCount: json["comments_count"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "text": text,
    "delta": delta,
    "category": category,
    "imgCover": imgCover,
    "userId": userId,
    "collection": collection,
    "createdAt": createdAt,
    "username": username,
    "bio": bio,
    "profilePicture": profilePicture,
    "updatedAt": updatedAt,
    "isLiked": isLiked,
    "isSaved": isSaved,
    "likesCount": likesCount,
    "commentsCount": commentsCount,
  };

  // Helper methods to check userId type
  bool hasUserId() {
    return userId != null && userId != 0 && userId != "0";
  }

  // Get userId as int (useful for comparisons)
  int getUserIdAsInt() {
    if (userId == null) return 0;
    if (userId is int) return userId;
    if (userId is String) {
      try {
        return int.parse(userId);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }
}
