class ArticleAnalysis {
  final String? originalText;
  final String? analysisText;
  final bool isLoading;
  final String? error;

  ArticleAnalysis({
    this.originalText,
    this.analysisText,
    this.isLoading = false,
    this.error,
  });

  // کپی مدل با مقادیر جدید
  ArticleAnalysis copyWith({
    String? originalText,
    String? analysisText,
    bool? isLoading,
    String? error,
  }) {
    return ArticleAnalysis(
      originalText: originalText ?? this.originalText,
      analysisText: analysisText ?? this.analysisText,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
