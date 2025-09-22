import 'package:itech/models/hub/morning_article_model.dart';
import 'package:itech/service/hub/afternoon_article_service.dart';
import 'package:itech/service/hub/morniin_article_service.dart';
import 'package:itech/service/hub/night_article_service.dart';

class ArticleFetcher {
  final MorningArticleService _morningService = MorningArticleService();
  final AfternoonArticleService _afternoonService = AfternoonArticleService();
  final NightArticleService _nightService = NightArticleService();

  Future<List<Article>> fetchMorningArticles() async {
    final morningArticles = await _morningService.getMorningArticles();
    return morningArticles?.articles ?? [];
  }

  Future<List<Article>> fetchAfternoonArticles() async {
    final afternoonArticles = await _afternoonService.getAfternoonArticles();
    return afternoonArticles?.articles ?? [];
  }

  Future<List<Article>> fetchNightArticles() async {
    final nightArticles = await _nightService.getNightArticles();
    return nightArticles?.articles ?? [];
  }
}
