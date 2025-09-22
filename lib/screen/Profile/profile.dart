import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/providers/temporal_behavior.dart';
import 'package:itech/screen/setting/setting.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:itech/screen/Profile/edit/edit_profile.dart';
import 'package:itech/widgets/profile/shimmer_profile.dart';
import 'package:itech/widgets/profile/state_column.dart';
import 'package:itech/widgets/share/share_account_sheet.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:itech/providers/get_myArticle_manager.dart';
import 'package:itech/screen/Profile/components/post_list_component.dart';
import 'package:itech/screen/Profile/components/profile_tabs_component.dart';
import 'package:itech/screen/Profile/components/placeholder_content.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // متغیر برای نگهداری تب فعلی
  int _selectedTabIndex = 0;
  bool _isLoading = true;

  // لیست تب‌های نوار ناوبری
  final List<String> _tabs = ['Activity', 'About'];

  @override
  void initState() {
    super.initState();
    // درخواست مقالات فقط یک بار در زمان شروع صفحه
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    try {
      // Call requestArticles without await since it returns void
      Provider.of<GetMyArticleManager>(
        context,
        listen: false,
      ).requestArticles();
      Provider.of<TemporalBehaviorProvider>(context, listen: false).isConnected;

      // Simulate loading delay for demonstration
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final webSocketManager = Provider.of<ProfileSocketManager>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    void _showShareSheet() {
      if (webSocketManager != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => ShareAccountSheet(
                username: webSocketManager.userName.toLowerCase()!,
              ),
        );
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        top: false,
        child:
            _isLoading
                ? ShimmerProfile()
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
                                    webSocketManager.profile_caver == null
                                        ? AssetImage(
                                          "assets/img/kevin-mueller-MardXkt4Gdk-unsplash.jpg",
                                        )
                                        : NetworkImage(
                                          '${ApiAddress.baseUrl}${webSocketManager.profile_caver}',
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
                                  colorScheme.background.withOpacity(0.2),
                                  colorScheme.background.withOpacity(0.6),
                                  colorScheme.background.withOpacity(0.9),
                                  colorScheme.background,
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
                                // glassColor: const Color.fromARGB(
                                //   75,
                                //   255,
                                //   255,
                                //   255,
                                // ).withOpacity(0.2),
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
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => const Setting(),
                                      ),
                                    );
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
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: colorScheme.background.withOpacity(
                                      0.2,
                                    ),
                                    border: Border.all(
                                      color: colorScheme.background.withOpacity(
                                        0.7,
                                      ),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ProfileStateColumn(
                                        count:
                                            webSocketManager.follower_count
                                                .toString(),
                                        label: "Followers",
                                      ),
                                      SizedBox(width: 20),
                                      ProfileStateColumn(
                                        count:
                                            webSocketManager.following_count
                                                .toString(),
                                        label: "Following",
                                      ),
                                      SizedBox(width: 20),
                                      ProfileStateColumn(
                                        count:
                                            webSocketManager.article_count
                                                .toString(),
                                        label: "Articles",
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
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
                                    webSocketManager.profile_picture == null
                                        ? AssetImage(
                                          'assets/img/44884218_345707102882519_2446069589734326272_n.jpg',
                                        ) // مسیر عکس لوکال
                                        : NetworkImage(
                                              '${ApiAddress.baseUrl}${webSocketManager.profile_picture}',
                                            )
                                            as ImageProvider,
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
                              '${webSocketManager.first_name} ${webSocketManager.last_name}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textTheme.bodyMedium!.color,
                                fontFamily: "a-b",
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${webSocketManager.bio}',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: "a-r",
                                color: textTheme.bodyMedium!.color,
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
                              child: CupertinoButton(
                                borderRadius: BorderRadius.circular(99),
                                color: Color(0xFF123fdb), // حفظ رنگ اصلی
                                padding: EdgeInsets.symmetric(vertical: 13),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // ImageIcon(
                                    //   AssetImage(
                                    //     "assets/icons/edit-1-svgrepo-com (1).png",
                                    //   ),
                                    //   color: CupertinoColors.white,
                                    //   size: 20,
                                    // ),
                                    SizedBox(width: 8), // فاصله بین آیکون و متن
                                    Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "a-m",
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder:
                                          (context) => const EditProfilePage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Message button
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(
                                      255,
                                      200,
                                      200,
                                      200,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: CupertinoButton(
                                  borderRadius: BorderRadius.circular(99),
                                  padding: EdgeInsets.symmetric(vertical: 13),
                                  onPressed: () => _showShareSheet(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // ImageIcon(
                                      //   AssetImage(
                                      //     "assets/icons/share-2-svgrepo-com.png",
                                      //   ),
                                      //   color: Colors.black87,
                                      // ),
                                      // SizedBox(width: 5),
                                      Text(
                                        'Share Profile',
                                        style: TextStyle(
                                          color: textTheme.bodyMedium!.color,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "a-m",
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
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
      ),
    );
  }

  // ساخت نوار ناوبری (نویگیشن بار) پروفایل
  Widget _buildProfileNavBar() {
    return ProfileTabsComponent(
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
    final myArticlesManager = Provider.of<GetMyArticleManager>(context);
    final articles = myArticlesManager.articles;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.background,
      child: PostListComponent(articles: articles),
    );
  }

  Widget _buildAboutContent() {
    return PlaceholderContent(title: 'About');
  }
}
