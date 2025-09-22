class ArticleLang {
  final String? originalDelta;
  final String? langDelta;
  final bool isLoading;
  final String? error;

  ArticleLang({
    this.originalDelta,
    this.langDelta,
    this.isLoading = false,
    this.error,
  });

  // کپی مدل با مقادیر جدید
  ArticleLang copyWith({
    String? originalDelta,
    String? langDelta,
    bool? isLoading,
    String? error,
  }) {
    return ArticleLang(
      originalDelta: originalDelta ?? this.originalDelta,
      langDelta: langDelta ?? this.langDelta,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
