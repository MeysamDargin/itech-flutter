import 'package:flutter/material.dart';
import 'package:itech/models/article/article_breaking_model.dart';
import 'package:itech/models/article/article_recommended_model.dart';
import 'package:itech/service/article/article_list_service.dart';
import 'package:itech/models/article/article_list_model.dart';
import 'package:itech/service/article/breaking_article_service.dart';
import 'package:itech/service/article/recommended_article_service.dart';
import 'package:itech/widgets/home/article_list_item_section.dart';
import 'package:itech/widgets/home/category_navigation.dart';
import 'package:itech/widgets/home/BreakingNews/news_carousel.dart';
import 'package:itech/widgets/home/section_header.dart';
import 'package:itech/widgets/home/top_navigation_bar.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategoryIndex = 0;
  List<BreakingArticle> _breakingArticles = [];
  List<RecommendedArticle> _recommendedArticles = [];
  bool _isLoading = true;

  final RecommendedArticleService _recommendedArticleService =
      RecommendedArticleService();
  final BreakingArticleService _breakingArticleService =
      BreakingArticleService();
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All'},
    {'name': 'Politic', 'icon': Icons.balance},
    {'name': 'Business', 'icon': Icons.business},
    {'name': 'Sport', 'icon': Icons.sports_soccer},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'Games', 'icon': Icons.gamepad},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRecommendedArticles();
    _fetchBreakingArticles();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecommendedArticles() async {
    try {
      final recommendedArticlesData =
          await _recommendedArticleService.getRecommendedArticle();
      if (mounted && recommendedArticlesData != null) {
        setState(() {
          _recommendedArticles = recommendedArticlesData.articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching recommended articles: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchBreakingArticles() async {
    try {
      final breakingArticlesData =
          await _breakingArticleService.getBreakingArticle();
      if (mounted && breakingArticlesData != null) {
        setState(() {
          _breakingArticles = breakingArticlesData.articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching articles: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onRefresh() async {
    await _fetchRecommendedArticles();
    await _fetchBreakingArticles();
    _refreshController.refreshCompleted();
  }

  String _getAuthorNameByCategory(String category) {
    final Map<String, String> authorsByCategory = {
      'Business': 'Alex Morgan',
      'Technology': 'James Wilson',
      'Economy': 'Sarah Johnson',
      'Sports': 'Kristin Watson',
      'Nature': 'Marvin McKinney',
      'Politic': 'Robert Chen',
      'Education': 'Emily Parker',
      'Games': 'Nathan Drake',
    };
    return authorsByCategory[category] ?? "Jane Cooper";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenPadding = size.width * 0.03;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: SmartRefresher(
          enablePullDown: true,
          header: const WaterDropHeader(
            waterDropColor: Color(0xFF4055FF),
            complete: Icon(Icons.check, color: Color(0xFF4055FF)),
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: ListView(
            children: [
              TopNavigationBar(screenPadding: screenPadding),
              const SizedBox(height: 20),
              BuildSectionHeader(
                horizontalPadding: screenPadding,
                title: "Breaking News",
              ),
              const SizedBox(height: 16),
              NewsCarousel(
                isLoading: _isLoading,
                articles: _breakingArticles,
                screenPadding: screenPadding,
              ),
              const SizedBox(height: 29),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BuildSectionHeader(
                      horizontalPadding: 0.0,
                      title: "Recommended for you",
                    ),
                    const SizedBox(height: 16),
                    CategoryNavigation(
                      selectedCategoryIndex: _selectedCategoryIndex,
                      categories: _categories,
                      onCategorySelected: (index) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                      screenPadding: screenPadding,
                    ),
                    const SizedBox(height: 30),
                    ArticleListSection(
                      isLoading: _isLoading,
                      articles: _recommendedArticles,
                      selectedCategoryName:
                          _categories[_selectedCategoryIndex]['name'],
                      getAuthorNameByCategory: _getAuthorNameByCategory,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
