import 'package:flutter/material.dart';
import 'package:itech/main.dart';
import 'package:itech/models/save/saved_items_response.dart';
import 'package:itech/utils/save/fach_save_list.dart';
import 'package:itech/widgets/saved/create_save_directory.dart';
import 'package:itech/widgets/public/article_list_item.dart';
import 'package:itech/widgets/saved/category_save_navigation.dart';
import 'package:itech/models/save/category_save_list_model.dart';
import 'package:itech/utils/save/fach_save_directory.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:lottie/lottie.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  int _selectedCategoryIndex = 0;
  bool _isLoadingCategories = true;
  bool _isLoadingArticles = true;
  List<SaveDirectory> _directories = [];
  List<Map<String, dynamic>> _categories = [
    {'name': 'All'},
  ];
  List<SavedItem> _savedItems = [];
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingCategories = true;
      _isLoadingArticles = true;
    });
    await Future.wait([_loadSaveDirectories(), _loadSavedArticles()]);
    if (mounted) {
      setState(() {});
    }
  }

  void _onRefresh() async {
    await _loadData();
    _refreshController.refreshCompleted();
  }

  Future<void> _loadSaveDirectories() async {
    try {
      final categoryList = await fetchAndParseCategoryList();

      if (categoryList != null && mounted) {
        setState(() {
          _directories = categoryList.directories;
          _categories = [
            {'name': 'All'},
            ..._directories
                .map(
                  (dir) => {
                    'name': dir.name,
                    'id': dir.id,
                    'count': dir.articleCount,
                  },
                )
                .toList(),
          ];
          _isLoadingCategories = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Error loading save directories: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> _loadSavedArticles() async {
    try {
      final savedItemsResponse = await fetchSaveList();
      if (savedItemsResponse != null && mounted) {
        setState(() {
          _savedItems = savedItemsResponse.savedItems;
          _isLoadingArticles = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingArticles = false;
        });
      }
    } catch (e) {
      print('Error loading saved articles: $e');
      if (mounted) {
        setState(() {
          _isLoadingArticles = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.of(context).size.width * 0.03;
    final bool isLoading = _isLoadingCategories || _isLoadingArticles;
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).extension<IconColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bookmarks',
          style: TextStyle(fontFamily: 'outfit-Medium', fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => CreateSaveDirectorySheet(
                        onCollectionCreated: () {
                          // Refresh the saved page data
                          _loadData();
                        },
                      ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: iconColor.iconColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              height: 47,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25),
                        child: Center(
                          child: ImageIcon(
                            AssetImage("assets/icons/search-svgrepo-com.png"),
                            color: iconColor.iconColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        header: const WaterDropHeader(
          waterDropColor: Color(0xFF4055FF),
          complete: Icon(Icons.check, color: Color(0xFF4055FF)),
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _isLoadingCategories
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff123fdb),
                        ),
                      )
                      : CategorySaveNavigation(
                        selectedCategoryIndex: _selectedCategoryIndex,
                        categories: _categories,
                        onCategorySelected: (index) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        screenPadding: screenPadding,
                      ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SliverFillRemaining(
              child:
                  isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff123fdb),
                        ),
                      )
                      : _buildSavedArticlesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedArticlesList() {
    List<SavedItem> filteredItems;

    if (_selectedCategoryIndex == 0) {
      filteredItems = _savedItems;
    } else {
      final selectedDirectoryId = _categories[_selectedCategoryIndex]['id'];
      filteredItems =
          _savedItems
              .where(
                (item) => item.saveDetails.directoryId == selectedDirectoryId,
              )
              .toList();
    }

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation
            Lottie.asset(
              'assets/animation/Not Found.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
            Text(
              'Empty',
              style: TextStyle(
                fontFamily: 'g-b',
                fontSize: 30,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _selectedCategoryIndex == 0
                  ? 'You have no saved articles.'
                  : 'No saved articles in ${_categories[_selectedCategoryIndex]['name']}',
              style: TextStyle(
                fontFamily: 'a-m',
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          filteredItems.map((item) {
            final articleDetails = item.articleDetails;
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              child: ArticleListItem(
                articleId: articleDetails.id,
                imageUrl: articleDetails.imgCover,
                title: articleDetails.title,
                category: articleDetails.category,
                profilePicture: articleDetails.profilePicture,
                username: articleDetails.username,
                date: articleDetails.createdAt,
                likesCount: articleDetails.likesCount,
                readsCount: articleDetails.readsCount,
                commentsCount: articleDetails.commentsCount,
              ),
            );
          }).toList(),
    );
  }
}
