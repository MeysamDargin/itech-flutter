import 'dart:convert';

UserPageGetModel userPageGetFromJson(String str) =>
    UserPageGetModel.fromJson(json.decode(str));

String userPageGetToJson(UserPageGetModel data) => json.encode(data.toJson());

class UserPageGetModel {
  int userId;
  String username;
  String email;
  String? firstName;
  String? lastName;
  String? jobTitle;
  String? website;
  String? bio;
  String? phoneNumber;
  String? country;
  String? cityState;
  String? profilePicture;
  String? profileCover; // اصلاح typo
  int followersCount;
  int followingCount;
  int articlesCount;
  List<Article>? articles;
  bool isFollowing;

  UserPageGetModel({
    required this.userId,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.jobTitle,
    this.website,
    this.bio,
    this.phoneNumber,
    this.country,
    this.cityState,
    this.profilePicture,
    this.profileCover,
    required this.followersCount,
    required this.followingCount,
    required this.articlesCount,
    this.articles,
    required this.isFollowing,
  });

  factory UserPageGetModel.fromJson(Map<String, dynamic> json) =>
      UserPageGetModel(
        userId: json["user_id"],
        username: json["username"],
        email: json["email"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        jobTitle: json["job_title"],
        website: json["website"],
        bio: json["bio"],
        phoneNumber: json["phone_number"],
        country: json["country"],
        cityState: json["city_state"],
        profilePicture: json["profile_picture"],
        profileCover: json["profile_cover"], // اصلاح typo
        followersCount: json["followers_count"],
        followingCount: json["following_count"],
        articlesCount: json["articles_count"],
        articles: List<Article>.from(
          json["articles"].map((x) => Article.fromJson(x)),
        ),
        isFollowing: json["is_following"],
      );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "username": username,
    "email": email,
    "first_name": firstName,
    "last_name": lastName,
    "job_title": jobTitle,
    "website": website,
    "bio": bio,
    "phone_number": phoneNumber,
    "country": country,
    "city_state": cityState,
    "profile_picture": profilePicture,
    "profile_cover": profileCover, // اصلاح typo
    "followers_count": followersCount,
    "following_count": followingCount,
    "articles_count": articlesCount,
    "articles": articles?.map((x) => x.toJson()).toList() ?? [],
    "is_following": isFollowing,
  };
}

class Article {
  String id;
  String title;
  String text;
  String? imgCover;
  String? category;
  DateTime? createdAt;
  DateTime? updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.text,
    this.imgCover,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
    id: json["_id"],
    title: json["title"],
    text: json["text"],
    imgCover: json["imgCover"],
    category: json["category"],
    createdAt:
        json["createdAt"] != null ? _tryParseDateTime(json["createdAt"]) : null,
    updatedAt:
        json["updatedAt"] != null ? _tryParseDateTime(json["updatedAt"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "text": text,
    "imgCover": imgCover,
    "category": category,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };

  static DateTime? _tryParseDateTime(String? dateStr) {
    try {
      return dateStr != null ? DateTime.parse(dateStr) : null;
    } catch (e) {
      return null;
    }
  }
}
