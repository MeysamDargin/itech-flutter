import 'package:flutter/material.dart';
import 'package:itech/screen/auth/forgotPassword/forgot_password.dart';
import 'package:itech/screen/auth/signup/signup.dart';
import 'package:itech/widgets/public/custom_input_field.dart';
import 'package:itech/service/auth/login_service.dart'; // Import LoginService
import 'package:itech/screen/buttonBar/ButtonNavbar.dart'; // Import ButtonNavbar
import 'package:flutter/cupertino.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // Track loading state
  final LoginService _loginService = LoginService(); // Initialize LoginService

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login function to handle authentication
  Future<void> _login() async {
    // Mark fields as dirty to trigger validation
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Validate inputs
    if (username.isEmpty || password.isEmpty) {
      // Force validation on empty fields instead of showing snackbar
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Call login service with WebSocket reconnection
      final success = await _loginService.loginWithReconnect(
        context,
        username,
        password,
      );

      // Hide loading state
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // On successful login, navigate to ButtonNavbar with index 1 (Explore)
        // Replace current route to prevent going back to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ButtonNavbar(1)),
          (route) => false, // This prevents going back to previous screens
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
          ),
        );
      }
    } catch (e) {
      // Hide loading state and show error
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset:
          true, // Ensure the screen resizes when keyboard appears
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.03,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    screenSize.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenSize.height * 0.05),
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: isTablet ? 40 : 50,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2f57ff),
                      fontFamily: 'Outfit-Bold',
                    ),
                  ),
                  Text(
                    'back!',
                    style: TextStyle(
                      fontSize: isTablet ? 40 : 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Outfit-Bold',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Technology is changing faster than you can imagine... \n Do you want to be among the first to understand?',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.black54,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),

                  // Email input with envelope icon
                  CustomInputField(
                    controller: _usernameController,
                    hintText: 'Enter your username',
                    prefixImagePath: "assets/icons/profile-svgrepo-com.png",
                    prefixIconSize: 22.0,
                    keyboardType: TextInputType.emailAddress,
                    validateEmpty: true,
                    fieldName: 'Username',
                  ),

                  SizedBox(height: screenSize.height * 0.02),

                  // Password input with lock icon and visibility toggle
                  CustomInputField(
                    controller: _passwordController,
                    hintText: 'your Password',
                    obscureText: _obscurePassword,
                    prefixImagePath:
                        "assets/icons/lock-password-svgrepo-com.png",
                    prefixIconSize: 22.0,
                    validateEmpty: true,
                    fieldName: 'Password',
                    suffixIcon: IconButton(
                      icon: Image.asset(
                        _obscurePassword
                            ? "assets/icons/eye-closed-svgrepo-com.png"
                            : "assets/icons/eye-svgrepo-com.png",
                        width: 22.0,
                        height: 22.0,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.015),

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenSize.height * 0.03),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _isLoading ? null : _login,
                      color: Color(0xFF123fdb),
                      borderRadius: BorderRadius.circular(99),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 17,
                                  color: Colors.white,
                                  fontFamily: 'sf-m',
                                ),
                              ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 200, 200, 200),
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: CupertinoButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupPage(),
                            ),
                          );
                        },
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(99),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 17,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontFamily: 'sf-m',
                                  ),
                                ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
