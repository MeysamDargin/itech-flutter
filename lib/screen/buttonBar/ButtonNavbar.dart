import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itech/main.dart';
import 'package:itech/screen/Explore/explore.dart';
import 'package:itech/screen/Home/home.dart';
import 'package:itech/screen/Profile/edit/edit_profile.dart';
import 'package:itech/screen/Profile/profile.dart';
import 'package:itech/screen/Saved/saved.dart';
import 'package:provider/provider.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';

class ButtonNavbar extends StatefulWidget {
  final int initialIndex;
  const ButtonNavbar(this.initialIndex, {Key? key}) : super(key: key);

  @override
  State<ButtonNavbar> createState() => _ButtonNavbarState();
}

class _ButtonNavbarState extends State<ButtonNavbar> {
  late int currentIndex;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isNewUser = false;

  // لیست ویجت‌ها برای صفحات مختلف
  final List<Widget> _pages = [
    HomePage(),
    Explore(),
    SavedPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex; // مقدار اولیه را تنظیم کنید
    _checkNewUserStatus();
  }

  // بررسی وضعیت کاربر جدید
  Future<void> _checkNewUserStatus() async {
    final String? newUserValue = await _secureStorage.read(key: 'newUser');
    setState(() {
      _isNewUser = newUserValue == 'true';
    });

    if (_isNewUser) {
      // اگر کاربر جدید است، به صفحه ادیت پروفایل هدایت می‌شود
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Initialize WebSocket before navigation
        final webSocketManager = Provider.of<ProfileSocketManager>(
          context,
          listen: false,
        );
        await webSocketManager.reconnectWebSockets();

        // Add a short delay to ensure WebSocket data is received
        await Future.delayed(const Duration(seconds: 1));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EditProfilePage()),
        );
      });
    }
  }

  void onTabTapped(int index) async {
    // قبل از تغییر تب، وضعیت کاربر جدید را بررسی می‌کنیم
    final String? newUserValue = await _secureStorage.read(key: 'newUser');
    final bool isNewUser = newUserValue == 'true';

    if (isNewUser) {
      // اگر کاربر جدید است، به صفحه ادیت پروفایل هدایت می‌شود
      // Initialize WebSocket before navigation
      final webSocketManager = Provider.of<ProfileSocketManager>(
        context,
        listen: false,
      );
      await webSocketManager.reconnectWebSockets();

      // Add a short delay to ensure WebSocket data is received
      await Future.delayed(const Duration(seconds: 1));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EditProfilePage()),
      );
    } else {
      // اگر کاربر جدید نیست، تب را تغییر می‌دهیم
      setState(() {
        currentIndex = index; // مقدار را در State تغییر دهید
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final navBarItemColors = Theme.of(context).extension<NavBarItemColors>()!;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        bottom: false,
        top: false,
        child: IndexedStack(
          index: currentIndex, // صفحه جاری را نمایش دهید
          children: _pages, // تمام صفحات در حافظه نگه داشته می‌شوند
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        top: false,
        child: Container(
          height: 64, // افزایش ارتفاع نوار پایین
          decoration: BoxDecoration(color: Colors.white),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent, // حذف اثر splash
              highlightColor: Colors.transparent, // حذف اثر highlight
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: const Color(0xff2f57ff),
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontFamily: "Outfit-Medium",
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontFamily: "Outfit",
              ),
              backgroundColor: colorScheme.background,
              onTap: onTabTapped,
              elevation: 0,
              currentIndex: currentIndex,
              unselectedItemColor: navBarItemColors.navBarItemColor,
              items: [
                buildBottomNavigationBarItem(
                  0,
                  "assets/icons/home-2-svgrepo-com.png",
                  "Home",
                ),
                buildBottomNavigationBarItem(
                  1,
                  "assets/icons/compass-big-svgrepo-com.png",
                  "Discover",
                ),
                buildBottomNavigationBarItem(
                  3,
                  "assets/icons/bookmark.512x510.png",
                  "Saved",
                ),
                buildBottomNavigationBarItem(
                  4,
                  "assets/icons/profile-svgrepo-com.png",
                  "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem buildBottomNavigationBarItem(
    int index,
    String icon,
    String title, {
    bool isBigger = false,
  }) {
    // ایجاد فاصله بیشتر بین آیکون و متن با استفاده از padding
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0, top: 8.0),
        child: ImageIcon(AssetImage(icon), size: isBigger ? 35 : 22),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 4.0, top: 8.0),
        child: ImageIcon(
          AssetImage(icon),
          size: isBigger ? 35 : 23,
          color: const Color(0xff2f57ff),
        ),
      ),
      label: title,
    );
  }
}
