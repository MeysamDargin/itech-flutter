class SavedItemsResponse {
  final String status;
  final List<SavedItem> savedItems;

  SavedItemsResponse({required this.status, required this.savedItems});

  factory SavedItemsResponse.fromJson(Map<String, dynamic> json) {
    return SavedItemsResponse(
      status: json['status'],
      savedItems:
          (json['saved_items'] as List)
              .map((item) => SavedItem.fromJson(item))
              .toList(),
    );
  }
}

class SavedItem {
  final SaveDetails saveDetails;
  final ArticleDetails articleDetails;

  SavedItem({required this.saveDetails, required this.articleDetails});

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      saveDetails: SaveDetails.fromJson(json['save_details']),
      articleDetails: ArticleDetails.fromJson(json['article_details']),
    );
  }
}

class SaveDetails {
  final String saveId;
  final String articleId;
  final int userId;
  final String directoryId;
  final DateTime createdAt;

  SaveDetails({
    required this.saveId,
    required this.articleId,
    required this.userId,
    required this.directoryId,
    required this.createdAt,
  });

  factory SaveDetails.fromJson(Map<String, dynamic> json) {
    return SaveDetails(
      saveId: json['save_id'],
      articleId: json['articleId'],
      userId: json['userId'],
      directoryId: json['directoryId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ArticleDetails {
  final String id;
  final String title;
  final String category;
  final String imgCover;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int readsCount;
  final String username;
  final String profilePicture;

  ArticleDetails({
    required this.id,
    required this.title,
    required this.category,
    required this.imgCover,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.readsCount,
    required this.username,
    required this.profilePicture,
  });

  factory ArticleDetails.fromJson(Map<String, dynamic> json) {
    return ArticleDetails(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      imgCover: json['imgCover'],
      createdAt: DateTime.parse(json['createdAt']),
      likesCount: json['likes_count'],
      commentsCount: json['comments_count'],
      readsCount: json['reads_count'],
      username: json['username'],
      profilePicture: json['profilePicture'],
    );
  }
}
