class ApiEndpoint {
  static const String login = "/accounts/login/";
  static const String logout = "/accounts/logout/";
  static const String profilePut = "/profiles/update/";
  static const String articleList = "/articles/list/";
  static const String morningArticleList = "/articles/get-morning-articles/";
  static const String afternoonArticleList =
      "/articles/get-afternoon-articles/";
  static const String recommendedArticleList =
      "/articles/get-recommended-articles/";
  static const String breakingArticleList = "/articles/get-breaking-articles/";
  static const String nightArticleList = "/articles/get-night-articles/";
  static const String aiSummarize = "/webhook/summarize-article";
  static const String newsDaySummarize = "/webhook/summarize-news-day";
  static const String aiLanguage = "/webhook/language-article";
  static const String aiAnalysis = "/webhook/analis-article";
  static const String aiChat = "/webhook/chats-article";
  static const String articleDetail = "/articles/detail/";
  static const String uploadImage = "/articles/upload-image/";
  static const String sendArticle = "/articles/create/";
  static const String getCategoryList = "/articles/save-directories/";
  static const String getSavelist = "/articles/saved/";
  static const String checkSaveArticle = "/articles/check-save/";
  static const String articleUpdate = "/articles/update/";
  static const String articleDelete = "/articles/delete/";
  static const String articleLike = "/articles/like/";
  static const String articleSave = "/articles/save/";
  static const String createSaveDirectory = "/articles/create-save-directory/";
  static const String updateSaveDirectory = "/articles/update-save-directory/";
  static const String deleteSaveDirectory = "/articles/delete-save-directory/";
  static const String commentEdite = "/comments/update/";
  static const String commentCreate = "/comments/create/";
  static const String commentDelete = "/comments/delete/";
  static const String checkUsername = "/profiles/check-username/";
  static const String checkEmail = "/profiles/check-email/";
  static const String sendOtpCode = "/otp/send-otp/";
  static const String verifyOtpCode = "/otp/verify-otp/";
  static const String registerUser = "/profiles/register-basic/";
  static const String getPageUser = "/profiles/get-user-profile/";
  static const String following = "/following/toggle/";
  static const String articleRead = "/articles/track-read/";
  static const String postfeedback = "/feedback/create-feedback/";
  static const String postreport = "/report/create-report/";
  static const String getSearch = "/search/search/";
  static const String getSearchHistory = "/search/search-history/";
}
