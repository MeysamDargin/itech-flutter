import 'dart:ui';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/models/user/user_page_get_model.dart';
import 'package:itech/screen/pageUser/components/user_article_list_component.dart';
import 'package:itech/screen/pageUser/components/user_placeholder_content.dart';
import 'package:itech/screen/pageUser/components/user_profile_tabs_component.dart';
import 'package:itech/service/following/follow_service.dart';
import 'package:itech/service/pageUser/get_page_user.dart';
import 'package:itech/utils/url.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class UserProfilePage extends StatefulWidget {
  final String username;

  const UserProfilePage({super.key, required this.username});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Activity', 'About'];
  bool _isLoading = true;
  UserPageGetModel? _userData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await GetPageUser.getPageUser(widget.username);
      setState(() {
        _userData = UserPageGetModel.fromJson(response);
        _isLoading = false;
      });
      print(
        'User data fetched successfully: ${_userData?.firstName} ${_userData?.lastName}',
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('Error fetching user data: $_errorMessage');
    }
  }

  Future<void> _toggleFollow() async {
    // ذخیره وضعیت فعلی برای بازگشت در صورت خطا
    final bool currentFollowingStatus = _userData?.isFollowing ?? false;

    // تغییر وضعیت به صورت بهینه‌بینانه (Optimistic UI Update)
    setState(() {
      if (_userData != null) {
        _userData!.isFollowing = !currentFollowingStatus;
        // اگر فالو شده، تعداد فالوورها را یک واحد افزایش می‌دهیم
        if (_userData!.isFollowing) {
          _userData!.followersCount += 1;
        } else {
          // اگر آنفالو شده، تعداد فالوورها را یک واحد کاهش می‌دهیم
          _userData!.followersCount =
              (_userData!.followersCount > 0)
                  ? _userData!.followersCount - 1
                  : 0;
        }
      }
    });

    try {
      final response = await FollowService.followService(
        _userData?.userId.toString() ?? '',
      );
      // بررسی موفقیت آمیز بودن درخواست
      if (response['status'] == 'success') {
      } else {
        // عملیات ناموفق بود، برگرداندن وضعیت به حالت قبلی
        setState(() {
          if (_userData != null) {
            _userData!.isFollowing = currentFollowingStatus;
            // بازگرداندن تعداد فالوورها به حالت قبلی
            if (currentFollowingStatus) {
              _userData!.followersCount += 1;
            } else {
              _userData!.followersCount =
                  (_userData!.followersCount > 0)
                      ? _userData!.followersCount - 1
                      : 0;
            }
          }
        });

        // نمایش پیام خطا به کاربر
        _showErrorSnackBar(
          context,
          "Oops Error",
          response['message'] ?? "An error has occurred",
        );
      }
    } catch (e) {
      // در صورت خطا، برگرداندن وضعیت به حالت قبلی
      setState(() {
        if (_userData != null) {
          _userData!.isFollowing = currentFollowingStatus;
          // بازگرداندن تعداد فالوورها به حالت قبلی
          if (currentFollowingStatus) {
            _userData!.followersCount += 1;
          } else {
            _userData!.followersCount =
                (_userData!.followersCount > 0)
                    ? _userData!.followersCount - 1
                    : 0;
          }
        }
      });
      // نمایش پیام خطا به کاربر
      _showErrorSnackBar(
        context,
        "Oops Server Error",
        "Unable to connect to the server.",
      );
    }
  }

  // متد نمایش پیام خطا
  void _showErrorSnackBar(BuildContext context, String title, String message) {
    final errorSnackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(errorSnackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text('Error: $_errorMessage'))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile header with background image, profile photo, and user info
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomLeft,
                      children: [
                        // Background image with gradient overlay
                        Container(
                          height: 240,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  _userData?.profileCover == null
                                      ? AssetImage(
                                        "assets/img/kevin-mueller-MardXkt4Gdk-unsplash.jpg",
                                      )
                                      : NetworkImage(
                                        '${ApiAddress.baseUrl}${_userData?.profileCover}',
                                      ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          foregroundDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.6),
                                Colors.white.withOpacity(0.9),
                                Colors.white,
                              ],
                            ),
                          ),
                        ),

                        // دایره و آیکون سه نقطه در بالای گوشه راست
                        Positioned(
                          top: 40,
                          right: 20,
                          child: LiquidGlass(
                            settings: LiquidGlassSettings(
                              thickness: 15,
                              blur: 50,
                              lightAngle: 1,
                              lightIntensity: 1,
                              ambientStrength: 4,
                              chromaticAberration: 4,
                              refractiveIndex: 1.2,
                            ),
                            shape: LiquidRoundedSuperellipse(
                              borderRadius: Radius.circular(50),
                            ),
                            child: Container(
                              width: 50,
                              height: 50,
                              child: IconButton(
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  // _showCoverOptions(context);
                                },
                              ),
                            ),
                          ),
                        ),

                        // Glass effect stats container (followers, following, articles)
                        Positioned(
                          right: 20,
                          bottom: 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 7,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.7),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildStatColumn(
                                      "${_userData?.followersCount ?? 0}",
                                      "Followers",
                                    ),
                                    SizedBox(width: 20),
                                    _buildStatColumn(
                                      "${_userData?.followingCount ?? 0}",
                                      "Following",
                                    ),
                                    SizedBox(width: 20),
                                    _buildStatColumn(
                                      "${_userData?.articlesCount ?? 0}",
                                      "Articles",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Profile avatar with border
                        Positioned(
                          left: 20,
                          bottom: 25,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  _userData?.profilePicture == null
                                      ? AssetImage(
                                        "assets/img/44884218_345707102882519_2446069589734326272_n.jpg",
                                      )
                                      : NetworkImage(
                                        '${ApiAddress.baseUrl}${_userData?.profilePicture}',
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // User info (name and bio) - below the avatar
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_userData?.firstName ?? ""} ${_userData?.lastName ?? ""}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: "a-b",
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _userData?.bio ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "a-r",
                              color: const Color.fromARGB(255, 42, 42, 42),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action buttons (Add friend, Message)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: Row(
                        children: [
                          // Add friend button
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      _userData?.isFollowing ?? false
                                          ? const Color.fromARGB(
                                            255,
                                            200,
                                            200,
                                            200,
                                          )
                                          : const Color(0xFF123fdb),
                                ),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: CupertinoButton(
                                borderRadius: BorderRadius.circular(99),
                                color:
                                    _userData?.isFollowing ?? false
                                        ? CupertinoColors.white
                                        : Color(0xFF123fdb),
                                padding: EdgeInsets.symmetric(vertical: 13),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _userData?.isFollowing ?? false
                                        ? ImageIcon(
                                          AssetImage(
                                            "assets/icons/users-svgrepo-com.png",
                                          ),
                                          size: 25,
                                          color: CupertinoColors.black,
                                        )
                                        : ImageIcon(
                                          AssetImage(
                                            "assets/icons/user-plus.png",
                                          ),
                                          size: 20,
                                          color: CupertinoColors.white,
                                        ),
                                    SizedBox(width: 8),
                                    Text(
                                      _userData?.isFollowing ?? false
                                          ? 'Following'
                                          : 'Follow',
                                      style: TextStyle(
                                        color:
                                            _userData?.isFollowing ?? false
                                                ? CupertinoColors.black
                                                : CupertinoColors.white,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "a-m",
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: _toggleFollow,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 45,
                                height: 45,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.more_horiz_rounded,
                                    color: Colors.black87,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // نوار ناوبری پروفایل
                    _buildProfileNavBar(),

                    // محتوای پروفایل بر اساس تب انتخاب شده
                    _buildProfileContent(),
                  ],
                ),
              ),
    );
  }

  // ساخت نوار ناوبری (نویگیشن بار) پروفایل
  Widget _buildProfileNavBar() {
    return UserProfileTabsComponent(
      tabs: _tabs,
      selectedTabIndex: _selectedTabIndex,
      onTabSelected: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
    );
  }

  // ساخت محتوای پروفایل بر اساس تب انتخاب شده
  Widget _buildProfileContent() {
    // بر اساس تب انتخاب شده، محتوای مناسب را نمایش می‌دهد
    switch (_selectedTabIndex) {
      case 0: // Feed
        return _buildPostsList();
      case 5: // About
        return _buildAboutContent();
      default:
        return _buildPostsList();
    }
  }

  // نمونه محتوا برای تب Feed (پست‌ها)
  Widget _buildPostsList() {
    final articlesUserPage = _userData;
    final articles = articlesUserPage?.articles;
    final articleMaps =
        articles?.map((article) => article.toJson()).toList() ?? [];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 5),
      child: UserArticleListComponent(
        articles: articleMaps,
        username: _userData?.username,
      ),
    );
  }

  Widget _buildAboutContent() {
    return UserPlaceholderContent(title: 'About');
  }
}

Widget _buildStatColumn(String count, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        count,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: "a-b",
        ),
      ),
      SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontFamily: "a-m",
        ),
      ),
    ],
  );
}
