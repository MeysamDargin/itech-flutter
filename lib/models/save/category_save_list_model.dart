class CategoryListModel {
  final String status;
  final List<SaveDirectory> directories;

  CategoryListModel({required this.status, required this.directories});

  factory CategoryListModel.fromJson(Map<String, dynamic> json) {
    return CategoryListModel(
      status: json['status'],
      directories:
          (json['directories'] as List)
              .map((dir) => SaveDirectory.fromJson(dir))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'directories': directories.map((dir) => dir.toJson()).toList(),
    };
  }
}

class SaveDirectory {
  final String id;
  final String name;
  final DateTime createdAt;
  final int articleCount;

  SaveDirectory({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.articleCount,
  });

  factory SaveDirectory.fromJson(Map<String, dynamic> json) {
    return SaveDirectory(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
      articleCount: json['articleCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'articleCount': articleCount,
    };
  }
}
