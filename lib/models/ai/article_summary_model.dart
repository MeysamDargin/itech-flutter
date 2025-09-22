class ArticleSummary {
  final String? originalDelta;
  final String? summaryDelta;
  final bool isLoading;
  final String? error;

  ArticleSummary({
    this.originalDelta,
    this.summaryDelta,
    this.isLoading = false,
    this.error,
  });

  // کپی مدل با مقادیر جدید
  ArticleSummary copyWith({
    String? originalDelta,
    String? summaryDelta,
    bool? isLoading,
    String? error,
  }) {
    return ArticleSummary(
      originalDelta: originalDelta ?? this.originalDelta,
      summaryDelta: summaryDelta ?? this.summaryDelta,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
