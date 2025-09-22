import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itech/service/auth/login_service.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:itech/screen/Landing/landing.dart';
import 'package:itech/screen/Profile/edit/edit_profile.dart';
import 'package:itech/screen/buttonBar/ButtonNavbar.dart';
import 'package:provider/provider.dart';

class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({Key? key}) : super(key: key);

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  final LoginService _loginService = LoginService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

    try {
      final isLoggedIn = await _loginService.isLoggedIn();

      // Wait a bit to avoid flickering on fast devices
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (isLoggedIn) {
          // اگر کاربر لاگین کرده باشد، چک کنیم که آیا کاربر جدید است یا خیر
          final String? newUserValue = await _secureStorage.read(
            key: 'newUser',
          );
          print('newUser value: $newUserValue');

          if (newUserValue == 'true') {
            // اگر کاربر جدید است، به صفحه ادیت پروفایل هدایت شود
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
            // اگر کاربر جدید نیست، به صفحه اصلی هدایت شود
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ButtonNavbar(0)),
            );
          }
        } else {
          // If user is not logged in, navigate to login page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
          );
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // On error, navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or splash screen content
            Image.asset(
              'assets/logo/Screenshot_2025-05-11_at_2-new.48.58_PM-removebg-preview (1).png',
              width: 150,
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}
