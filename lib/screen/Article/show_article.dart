import 'package:flutter/material.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:itech/service/article/article_detail_service.dart';
import 'package:itech/service/article/article_read_service.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/models/article/article_detail_model.dart';
import 'package:itech/widgets/article/showArticle/account_user.dart';
import 'package:itech/widgets/article/ai/ai_caht_input.dart';
import 'package:itech/widgets/article/showArticle/article_action_bar.dart';
import 'package:itech/widgets/article/showArticle/article_meta_info.dart';
import 'package:itech/widgets/article/ai/ai_features_bottom_sheet.dart';
import 'package:itech/widgets/article/showArticle/article_content.dart';
import 'package:itech/widgets/article/showArticle/article_header.dart';
import 'package:itech/service/ai/article_summary_service.dart';
import 'package:itech/service/ai/article_lang.dart';
import 'package:itech/service/ai/article_analysis_service.dart';
import 'package:itech/widgets/article/ai/article_analysis_sheet.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:itech/providers/article_comments_socket.dart';
import 'package:itech/screen/chats/chats.dart';
import 'dart:async';
import 'dart:io';
import 'package:lottie/lottie.dart';

class ShowArticle extends StatefulWidget {
  final String articleId;
  final String source;

  const ShowArticle({super.key, required this.articleId, required this.source});

  @override
  State<ShowArticle> createState() => _ShowArticleState();
}

class _ShowArticleState extends State<ShowArticle> with WidgetsBindingObserver {
  final ArticleDetailService _articleService = ArticleDetailService();
  final ArticleSummaryService _summaryService = ArticleSummaryService();
  final ArticleLangService _langService = ArticleLangService();
  final ArticleAnalysisService _analysisService = ArticleAnalysisService();
  final ArticleReadService _articleReadService = ArticleReadService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  Article? _article;
  bool _isLiked = false;
  bool _isSaved = false;
  bool _chatInput = false;

  // Reading tracking variables
  Timer? _readingTimer;
  DateTime? _pageEntryTime;
  int _totalDurationSeconds = 0;
  double _maxScrollPosition = 0.0;
  double _contentHeight = 0.0;
  bool _hasMinimumTimeElapsed = false;
  bool _isPageFullyLoaded = false;
  bool _hasReportedReading = false;

  // Timer for minimum 5 seconds requirement
  Timer? _minimumTimeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageEntryTime = DateTime.now();
    _startReadingTimer();
    _setupMinimumTimeRequirement();
    _setupScrollListener();
    _fetchArticleDetail();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _readingTimer?.cancel();
    _minimumTimeTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    // پاک کردن خلاصه و ترجمه
    _summaryService.clearSummary();
    _langService.clearTranslation();
    _analysisService.clearAnalysis();

    // Report reading when leaving the page
    if (_isPageFullyLoaded && _hasMinimumTimeElapsed && !_hasReportedReading) {
      _reportArticleReading();
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // App is going to background or being closed
        if (_isPageFullyLoaded &&
            _hasMinimumTimeElapsed &&
            !_hasReportedReading) {
          _reportArticleReading();
        }
        break;
      default:
        break;
    }
  }

  void _startReadingTimer() {
    _readingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_pageEntryTime != null) {
        _totalDurationSeconds =
            DateTime.now().difference(_pageEntryTime!).inSeconds;
      }
    });
  }

  void _setupMinimumTimeRequirement() {
    _minimumTimeTimer = Timer(Duration(seconds: 5), () {
      _hasMinimumTimeElapsed = true;
      print("Minimum 5 seconds elapsed, can now report reading");
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      double currentPosition = _scrollController.offset;
      if (currentPosition > _maxScrollPosition) {
        _maxScrollPosition = currentPosition;
      }
    }
  }

  String _getDeviceType() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else {
      return 'Unknown';
    }
  }

  double _calculateReadPercentage() {
    if (!_scrollController.hasClients || _contentHeight <= 0) {
      return 0.0;
    }

    // Get screen height
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate the maximum scrollable distance
    double maxScrollExtent = _scrollController.position.maxScrollExtent;

    // If there's no scrollable content, consider it 100% read
    if (maxScrollExtent <= 0) {
      return 100.0;
    }

    // Calculate how much of the scrollable content has been viewed
    // We add screen height because when user reaches the bottom,
    // they've seen the entire content
    double viewedContent = _maxScrollPosition + screenHeight;
    double totalContent = maxScrollExtent + screenHeight;

    double percentage = (viewedContent / totalContent) * 100;

    // Cap at 100%
    return percentage > 100 ? 100.0 : percentage;
  }

  Future<void> _reportArticleReading() async {
    if (_hasReportedReading || _article == null) {
      return;
    }

    _hasReportedReading = true;

    double readPercentage = _calculateReadPercentage();
    String deviceType = _getDeviceType();

    print("Reporting article reading:");
    print("- Article ID: ${widget.articleId}");
    print("- Source: ${widget.source}");
    print("- Device: $deviceType");
    print("- Duration: $_totalDurationSeconds seconds");
    print("- Read Percentage: ${readPercentage.toStringAsFixed(1)}%");

    try {
      final response = await _articleReadService.readArticle(
        article_id: widget.articleId,
        source: widget.source,
        device: deviceType,
        duration: _totalDurationSeconds,
        read_percentage: readPercentage.round(),
      );

      if (response != null && response['status'] != 'error') {
        print("Article reading reported successfully");
      } else {
        print("Failed to report article reading: ${response?['message']}");
      }
    } catch (e) {
      print("Error reporting article reading: $e");
    }
  }

  Future<void> _fetchArticleDetail() async {
    try {
      final articleData = await _articleService.getArticleDetail(
        widget.articleId,
      );
      if (articleData != null) {
        setState(() {
          _article = articleData.article;
          _isLiked = _article?.isLiked ?? false;
          _isSaved = _article?.isSaved ?? false;
          _isLoading = false;
          _isPageFullyLoaded = true;
        });

        // Wait for the widget to build and calculate content height
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _calculateContentHeight();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateContentHeight() {
    if (_scrollController.hasClients) {
      _contentHeight = _scrollController.position.maxScrollExtent;
      print("Content height calculated: $_contentHeight");
    }
  }

  void _handleLikeStatusChanged(bool isLiked) {
    setState(() {
      _isLiked = isLiked;
      if (_article != null) {
        _article!.isLiked = isLiked;
      }
    });
  }

  void _handleSavedStatusChanged(bool isSaved) {
    setState(() {
      _isSaved = isSaved;
      if (_article != null) {
        _article!.isSaved = isSaved;
      }
    });
  }

  void _navigateToComments() {
    print(
      "Navigate to comments from article page for article ID: ${widget.articleId}",
    );

    // Report reading before navigating away
    if (_isPageFullyLoaded && _hasMinimumTimeElapsed && !_hasReportedReading) {
      _reportArticleReading();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChangeNotifierProvider(
              create: (_) => ArticleCommentsSocketProvider(),
              child: ChatScreen(
                articleId: widget.articleId,
                recipientName: "نظرات مقاله",
              ),
            ),
      ),
    );
  }

  // آنالیز مقاله
  Future<void> _analyzeArticle() async {
    if (_article != null) {
      print('Analyze button pressed');

      // نمایش یک دیالوگ در حال بارگذاری
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Lottie.asset(
                'assets/animation/Ai loading model.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      );

      // ارسال درخواست آنالیز
      final analysisResult = await _analysisService.analyzeArticle(
        _article!,
        setState,
      );

      // بستن دیالوگ در حال بارگذاری
      Navigator.pop(context);

      // نمایش نتیجه آنالیز
      if (analysisResult != null) {
        ArticleAnalysisSheet.show(context, analysisText: analysisResult);
      } else {
        // نمایش خطا
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze article. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAIBottomSheet() {
    AIFeaturesBottomSheet.show(
      context,
      onSummarizePressed: () {
        if (_article != null) {
          print('Summarize button pressed');

          // اگر مقاله ترجمه شده است، متن ترجمه شده را برای خلاصه‌سازی ارسال می‌کنیم
          if (_langService.isShowingLang &&
              _langService.articleLang != null &&
              _langService.articleLang!.langDelta != null) {
            print(
              'Article is translated, using translated text for summarization',
            );

            // ایجاد یک Article موقت با محتوای ترجمه شده
            final translatedArticle = Article(
              id: _article!.id,
              title: _article!.title,
              delta: _langService.articleLang!.langDelta!,
              text: _article!.text,
              imgCover: _article!.imgCover,
              category: _article!.category,
              username: _article!.username,
              profilePicture: _article!.profilePicture,
              isLiked: _article!.isLiked,
              collection: _article!.collection,
            );

            _summaryService.summarizeArticle(translatedArticle, setState);
          } else {
            print('Using original article text for summarization');
            _summaryService.summarizeArticle(_article!, setState);
          }
        }
      },
      onTranslatePressed: (String languageCode) {
        if (_article != null) {
          print('Translate requested for language: $languageCode');

          // اگر مقاله خلاصه شده است، متن خلاصه شده را برای ترجمه ارسال می‌کنیم
          if (_summaryService.isShowingSummary &&
              _summaryService.articleSummary != null &&
              _summaryService.articleSummary!.summaryDelta != null) {
            print('Article is summarized, using summary text for translation');

            // ایجاد یک Article موقت با محتوای خلاصه شده
            final summarizedArticle = Article(
              id: _article!.id,
              title: _article!.title,
              delta: _summaryService.articleSummary!.summaryDelta!,
              text: _article!.text,
              imgCover: _article!.imgCover,
              category: _article!.category,
              username: _article!.username,
              profilePicture: _article!.profilePicture,
              isLiked: _article!.isLiked,
              collection: _article!.collection,
            );

            _langService.translateArticle(
              summarizedArticle,
              languageCode,
              setState,
            );
          } else {
            print('Using original article text for translation');
            _langService.translateArticle(_article!, languageCode, setState);
          }
        }
      },
      onAnalyzePressed: _analyzeArticle,
      onChatInputChanged: (bool value) {
        setState(() {
          _chatInput = value; // تغییر _chatInput
        });
      },
      article: _article!,
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '23 June at 16:32';

    try {
      final DateTime dateTime = DateTime.parse(dateString);
      final DateTime localDateTime = dateTime.toLocal();

      final List<String> months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];

      final String day = localDateTime.day.toString();
      final String month = months[localDateTime.month - 1];
      // final String hour = localDateTime.hour.toString().padLeft(2, '0');
      // final String minute = localDateTime.minute.toString().padLeft(2, '0');

      return '$day $month';
    } catch (e) {
      return '23 June at 16:32';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenPadding = size.width * 0.03; // 3% padding on each side
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        // Report reading when user tries to go back
        if (_isPageFullyLoaded &&
            _hasMinimumTimeElapsed &&
            !_hasReportedReading) {
          await _reportArticleReading();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: SafeArea(
          top: true,
          bottom: false,
          left: false,
          right: false,
          child:
              _isLoading
                  ? _buildArticleShimmer(screenPadding)
                  : _article == null
                  ? Center(child: Text("Article not found"))
                  : Stack(
                    children: [
                      // Main content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top navigation bar
                          ArticleHeaderWidget(
                            articleid: _article!.id,
                            articleSaved: _isSaved,
                            onBackPressed: () async {
                              // Report reading when back button is pressed
                              if (_isPageFullyLoaded &&
                                  _hasMinimumTimeElapsed &&
                                  !_hasReportedReading) {
                                await _reportArticleReading();
                              }
                              Navigator.pop(context);
                            },
                            onAIButtonPressed: _showAIBottomSheet,
                            onSharePressed: () {},
                            onBookmarkPressed: () {},
                            onSavedStatusChanged: _handleSavedStatusChanged,
                          ),

                          // Article content
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Article header with source, date, and category
                                  ArticleMetaInfoWidget(
                                    category: _article!.category,
                                    useridArticle: _article!.userId,
                                    userLoginid:
                                        Provider.of<ProfileSocketManager>(
                                          context,
                                        ).id,
                                    date:
                                        '${_formatDate(_article != null ? _article!.createdAt : null)}',
                                    source: _article!.username!,
                                    sourceAbbreviation:
                                        _article!.profilePicture!,
                                    sourceColor: Colors.red,
                                  ),

                                  // Article title
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenPadding,
                                      vertical: 16,
                                    ),
                                    child: Text(
                                      _article!.title,
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "a-b",
                                        color: textTheme.bodyMedium!.color,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),

                                  // Article feature image
                                  Container(
                                    width: double.infinity,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          _article!.collection ==
                                                  'articles_users'
                                              ? '${ApiAddress.baseUrl}${_article!.imgCover}'
                                              : _article!.imgCover,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  // نوار وضعیت خلاصه
                                  _summaryService.buildSummaryStatusBar(
                                    screenPadding,
                                    setState,
                                  ),

                                  // نوار وضعیت ترجمه
                                  _langService.buildTranslationStatusBar(
                                    screenPadding,
                                    setState,
                                  ),

                                  // Article content
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenPadding,
                                      vertical: 16,
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width -
                                              (screenPadding * 2),
                                        ),
                                        child: ArticleContentWidget(
                                          originaldelta: _article!.delta,
                                          articleSummary:
                                              _summaryService.articleSummary,
                                          articleLang: _langService.articleLang,
                                          isShowingSummary:
                                              _summaryService.isShowingSummary,
                                          isShowingTranslated:
                                              _langService.isShowingLang,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color: const Color.fromARGB(
                                      255,
                                      230,
                                      230,
                                      230,
                                    ),
                                    height: 1,
                                  ),
                                  AccountUser(
                                    isFollowing: true,
                                    username: _article!.username!,
                                    profileImageUrl: _article!.profilePicture!,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 17,
                                    ),
                                    child: Text(
                                      "${_article?.bio}",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontFamily: 'a-r',
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),

                                  Divider(
                                    color: const Color.fromARGB(
                                      255,
                                      230,
                                      230,
                                      230,
                                    ),
                                    height: 1,
                                  ),
                                  // Add padding at the bottom to account for the floating action bar
                                  SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Floating Action Bar
                      _chatInput
                          ? Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: AiChatInput(
                              onSendMessage: (message) {
                                print('پیام ارسال شده: $message');
                              },
                              hintText: 'Ask AI...',
                              onChatInputChanged: (bool value) {
                                setState(() {
                                  _chatInput = value; // تغییر _chatInput
                                });
                              },
                              articleText: _article!.delta,
                              userId:
                                  Provider.of<ProfileSocketManager>(context).id,
                            ),
                          )
                          : Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: ArticleActionBar(
                              likesCount:
                                  _article!.likesCount is int
                                      ? _article!.likesCount
                                      : _article!.likesCount != null
                                      ? int.tryParse(
                                            _article!.likesCount.toString(),
                                          ) ??
                                          0
                                      : 0,
                              commentsCount:
                                  _article!.commentsCount is int
                                      ? _article!.commentsCount
                                      : _article!.commentsCount != null
                                      ? int.tryParse(
                                            _article!.commentsCount.toString(),
                                          ) ??
                                          0
                                      : 0,
                              isLiked: _isLiked,
                              articleId: widget.articleId,
                              onLikeStatusChanged: _handleLikeStatusChanged,
                              onCommentPressed: _navigateToComments,
                              onSoundPressed: () {},
                              scrollController: _scrollController,
                            ),
                          ),
                    ],
                  ),
        ),
      ),
    );
  }

  // Shimmer loading effect for article
  Widget _buildArticleShimmer(double screenPadding) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top navigation bar with back button only
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenPadding,
                vertical: 10,
              ),
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: ImageIcon(
                                  AssetImage(
                                    "assets/icons/back-svgrepo-com.png",
                                  ),
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Shimmer content
            Expanded(
              child: SingleChildScrollView(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Article header shimmer (source, date, category)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenPadding,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Source logo shimmer
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Source name shimmer
                            Container(
                              width: 100,
                              height: 10,
                              color: Colors.white,
                            ),
                            SizedBox(width: 16),
                            // Date shimmer
                            Container(
                              width: 80,
                              height: 10,
                              color: Colors.white,
                            ),
                            Spacer(),
                            // Category shimmer
                            Container(
                              width: 60,
                              height: 10,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      // Article title shimmer
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenPadding,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 20,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              height: 20,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),

                      // Article feature image shimmer
                      Container(
                        width: double.infinity,
                        height: 240,
                        color: Colors.white,
                      ),

                      // Content paragraphs shimmer
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenPadding,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            10, // 10 paragraph placeholders
                            (index) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 12,
                                  margin: EdgeInsets.only(bottom: 6),
                                  color: Colors.white,
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 12,
                                  margin: EdgeInsets.only(bottom: 6),
                                  color: Colors.white,
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 12,
                                  margin: EdgeInsets.only(bottom: 6),
                                  color: Colors.white,
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 12,
                                  margin: EdgeInsets.only(bottom: 16),
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Add padding at the bottom for the fixed bottom action bar
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Fixed bottom action bar shimmer
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
