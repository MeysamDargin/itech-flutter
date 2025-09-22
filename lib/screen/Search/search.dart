import 'package:flutter/material.dart';
import 'package:itech/screen/pageUser/profile_page.dart';
import 'package:itech/service/search/search_service.dart';
import 'package:itech/service/search/history_search_service.dart';
import 'package:itech/widgets/public/custom_input_field.dart';
import 'package:itech/widgets/public/article_list_item.dart';
import 'package:itech/widgets/search/category_search.dart';
import 'package:lottie/lottie.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with TickerProviderStateMixin {
  final SearchService _searchService = SearchService();
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _arrowAnimation;
  late Animation<double> _widthAnimation;
  late FocusNode _focusNode;
  bool _isSearchFocused = false;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _userResults = [];
  List<String> _searchHistory = [];
  int _selectedCategoryIndex = 0;
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Articles'},
    {'name': 'Accounts'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    _loadSearchHistory();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _arrowAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _widthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_isSearchFocused) {
        setState(() {
          _isSearchFocused = true;
        });
        _animationController.forward();
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Removed automatic search on text change
  }

  Future<void> _fetchSearchResults(String query) async {
    try {
      final response = await _searchService.sendQuery(query: query);

      if (response != null && response is Map<String, dynamic>) {
        // Extract articles from the response
        final articlesData = response['articles'];
        final usersData = response['users'];

        if (articlesData is List) {
          setState(() {
            _searchResults =
                articlesData
                    .map(
                      (item) => {
                        'articleId': item['article_id']?.toString() ?? '',
                        'title': item['title']?.toString() ?? '',
                        'category': item['category']?.toString() ?? '',
                        'imageUrl': item['imgCover']?.toString() ?? '',
                        'username': item['username']?.toString() ?? '',
                        'profilePicture':
                            item['profilePicture']?.toString() ?? '',
                        'date':
                            item['createdAt'] != null
                                ? DateTime.parse(item['createdAt'].toString())
                                : DateTime.now(),
                        'likesCount':
                            item['likes_count'] is int
                                ? item['likes_count']
                                : int.tryParse(
                                      item['likes_count']?.toString() ?? '0',
                                    ) ??
                                    0,
                        'commentsCount':
                            item['comments_count'] is int
                                ? item['comments_count']
                                : int.tryParse(
                                      item['comments_count']?.toString() ?? '0',
                                    ) ??
                                    0,
                        'readsCount':
                            item['reads_count'] is int
                                ? item['reads_count']
                                : int.tryParse(
                                      item['reads_count']?.toString() ?? '0',
                                    ) ??
                                    0,
                      },
                    )
                    .toList();
          });

          print("تعداد مقالات یافت شده: ${articlesData.length}");
        }

        if (usersData is List) {
          setState(() {
            _userResults =
                usersData
                    .map(
                      (item) => {
                        'userId': item['user_id']?.toString() ?? '',
                        'username': item['username']?.toString() ?? '',
                        'displayName': item['display_name']?.toString() ?? '',
                        'profilePicture':
                            item['profile_picture']?.toString() ?? '',
                        'bio': item['bio']?.toString() ?? '',
                        'first_name': item['first_name']?.toString() ?? '',
                        'last_name': item['last_name']?.toString() ?? '',
                      },
                    )
                    .toList();
          });

          print("تعداد کاربران یافت شده: ${usersData.length}");
        }
      }
    } catch (e) {
      print("خطای اتصال به سرور: $e");
      print("Stack trace: ${e.toString()}");
    }
  }

  Future<void> _loadSearchHistory() async {
    try {
      final response = await HistorySearchService.getSearchHistory();

      // Handle the case where response is directly a List
      if (response is List) {
        setState(() {
          _searchHistory =
              response.map((item) => item['query'].toString()).toList();
        });
      }
      // Handle the case where response is a Map with data field
      else if (response is Map<String, dynamic>) {
        if (response['status'] == 'success' && response['data'] != null) {
          setState(() {
            if (response['data'] is List) {
              _searchHistory =
                  (response['data'] as List)
                      .map((item) => item['query'].toString())
                      .toList();
            }
          });
        }
      }
    } catch (e) {
      print('خطا در دریافت تاریخچه جستجو: $e');
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    return Container(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: CircleAvatar(
          radius: 25,
          backgroundImage:
              user['profilePicture'].isNotEmpty
                  ? NetworkImage(user['profilePicture'])
                  : null,
          child:
              user['profilePicture'].isEmpty
                  ? const Icon(Icons.person, size: 25)
                  : null,
        ),
        title: Text(
          user['displayName'].isNotEmpty
              ? user['displayName']
              : user['username'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user['displayName'].isNotEmpty)
              Text(
                '@${user['username']}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            if (user['bio'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  user['bio'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${user['first_name']} ${user['last_name']}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 132, 132, 132),
                  fontSize: 12,
                  fontFamily: 'a-r',
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfilePage(username: user['username']),
            ),
          );
        },
      ),
    );
  }

  void _hideSearch() {
    if (_isSearchFocused) {
      _focusNode.unfocus();
      setState(() {
        _isSearchFocused = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _hideSearch,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Row(
                      children: [
                        AnimatedOpacity(
                          opacity: _arrowAnimation.value,
                          duration: const Duration(milliseconds: 50),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 50),
                            width: _arrowAnimation.value * 36,
                            child:
                                _arrowAnimation.value > 0.1
                                    ? GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: _arrowAnimation.value * 12,
                        ),
                        Expanded(
                          child: CustomInputField(
                            focusNode: _focusNode,
                            focusedBorder: const Color(0xff2f57ff),
                            controller: _searchController,
                            hintText: "Search",
                            prefixImagePath:
                                'assets/icons/search-svgrepo-com.png',
                            onSubmitted: (query) {
                              final trimmedQuery = query.trim();
                              if (trimmedQuery.isNotEmpty) {
                                _fetchSearchResults(trimmedQuery);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // Add CategoryNavigation when search results are available
                if (_searchResults.isNotEmpty || _userResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CategorySearch(
                      selectedCategoryIndex: _selectedCategoryIndex,
                      categories: _categories,
                      onCategorySelected: _onCategorySelected,
                      screenPadding: 0,
                    ),
                  ),
                Expanded(
                  child:
                      _searchResults.isEmpty && _userResults.isEmpty
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  bottom: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Recent Searches',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _searchHistory.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 0,
                                          ),
                                      title: Text(
                                        _searchHistory[index],
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      trailing: Image.asset(
                                        'assets/icons/history-svgrepo-com.png',
                                        width: 25,
                                      ),
                                      onTap: () {
                                        _searchController.text =
                                            _searchHistory[index];
                                        _fetchSearchResults(
                                          _searchHistory[index],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                          : _selectedCategoryIndex == 0
                          ? ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              return ArticleListItem(
                                source: 'search-page',
                                articleId: result['articleId'],
                                imageUrl: result['imageUrl'],
                                title: result['title'],
                                category: result['category'],
                                username: result['username'],
                                profilePicture: result['profilePicture'],
                                date: result['date'],
                                likesCount: result['likesCount'],
                                readsCount: result['readsCount'],
                                commentsCount: result['commentsCount'],
                              );
                            },
                          )
                          : ListView.builder(
                            itemCount: _userResults.length,
                            itemBuilder: (context, index) {
                              final user = _userResults[index];
                              return _buildUserItem(user);
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
