import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/models/hub/morning_article_model.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:itech/screen/Article/show_article.dart';
import 'package:itech/service/hub/afternoon_article_service.dart';
import 'package:itech/service/hub/morniin_article_service.dart';
import 'package:itech/service/hub/night_article_service.dart';
import 'package:itech/widgets/explore/news/card_news.dart';
import 'package:itech/widgets/explore/weather/weather_widget.dart';
import 'package:provider/provider.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  List<Article> _articles = [];
  bool _isLoading = true;

  final AfternoonArticleService _afternoonArticleService =
      AfternoonArticleService();
  final MorningArticleService _morningArticleService = MorningArticleService();
  final NightArticleService _nightArticleService = NightArticleService();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchArticlesByTime(); // بار اول

    // هر 10 دقیقه یکبار آپدیت
    _timer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _fetchArticlesByTime();
      setState(() {}); // برای آپدیت todayRecommend
    });
  }

  void _fetchArticlesByTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 9) {
      _morningfetchArticles();
    } else if (hour < 18) {
      _afternoonfetchArticles();
    } else if (hour < 23) {
      _nightfetchArticles();
    }
  }

  Future<void> _morningfetchArticles() async {
    try {
      final morningArticles = await _morningArticleService.getMorningArticles();
      if (mounted && morningArticles != null) {
        setState(() {
          _articles = morningArticles.articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching morning articles: $e');
    }
  }

  Future<void> _afternoonfetchArticles() async {
    try {
      final afternoonArticles =
          await _afternoonArticleService.getAfternoonArticles();
      if (mounted && afternoonArticles != null) {
        setState(() {
          _articles = afternoonArticles.articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching afternoon articles: $e');
    }
  }

  Future<void> _nightfetchArticles() async {
    try {
      final nightArticles = await _nightArticleService.getNightArticles();
      if (mounted && nightArticles != null) {
        setState(() {
          _articles = nightArticles.articles;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching night articles: $e');
    }
  }

  String todayRecommend() {
    final now = DateTime.now();
    final hour = now.hour;
    if (hour < 9) return 'Good morning';
    if (hour < 11) return 'Good day';
    if (hour < 13) return 'Good afternoon';
    if (hour < 16) return 'Good evening';
    return 'Good night';
  }

  @override
  void dispose() {
    _timer?.cancel(); // جلوگیری از memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileSocketManager = Provider.of<ProfileSocketManager>(context);
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 80, left: 20),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                todayRecommend(),
                                style: TextStyle(
                                  fontFamily: 'a-b',
                                  fontSize: 33,
                                  color: textTheme.bodyMedium!.color,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Start your day with this iTech',
                                style: TextStyle(
                                  fontFamily: 'a-r',
                                  fontSize: 20,
                                  color: textTheme.bodyMedium!.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const WeatherWidget(),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Here's some news you may be interested in.",
                              style: TextStyle(
                                fontFamily: 'a-r',
                                fontSize: 17,
                                color: textTheme.bodyMedium!.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            "assets/icons/icons8-ai-100.png",
                            width: 25,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ..._articles.map(
                      (article) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ShowArticle(
                                      articleId: article.id,
                                      source: 'morning-hub',
                                    ),
                              ),
                            );
                          },
                          child: ExplorGlassCard(
                            borderRadius: BorderRadius.circular(20),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      article.imgCover,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 100,
                                                width: 100,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 50,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      article.title,
                                      style: const TextStyle(
                                        fontFamily: 'a-b',
                                        fontSize: 17,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            blur: 15,
                            opacity: 0.7,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
