import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/screen/auth/signing/signing.dart';
import 'package:itech/widgets/public/custom_input_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Mark fields as dirty to trigger validation
    // setState(() {
    //   _isLoading = true;
    // });

    // final username = _usernameController.text.trim();
    // final password = _passwordController.text;

    // // Validate inputs
    // if (username.isEmpty || password.isEmpty) {
    //   // Force validation on empty fields instead of showing snackbar
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   return;
    // }

    // try {
    //   // Call login service with WebSocket reconnection
    //   final success = await _loginService.loginWithReconnect(
    //     context,
    //     username,
    //     password,
    //   );

    //   // Hide loading state
    //   setState(() {
    //     _isLoading = false;
    //   });

    //   if (success) {
    //     // On successful login, navigate to ButtonNavbar with index 1 (Explore)
    //     // Replace current route to prevent going back to login page
    //     Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(builder: (context) => const ButtonNavbar(1)),
    //       (route) => false, // This prevents going back to previous screens
    //     );
    //   } else {
    //     // Show error message
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('Login failed. Please check your credentials.'),
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   // Hide loading state and show error
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    // }
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
                    'Forgot',
                    style: TextStyle(
                      fontSize: isTablet ? 40 : 50,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2f57ff),
                      fontFamily: 'Outfit-Bold',
                    ),
                  ),
                  Text(
                    'Password!',
                    style: TextStyle(
                      fontSize: isTablet ? 40 : 45,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Outfit-Bold',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please enter the email address of your account for which you have forgotten your password in the box below. A password reset link will be sent to your email.',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Colors.black54,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.05),

                  // Email input with envelope icon
                  CustomInputField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    prefixImagePath: "assets/icons/email-svgrepo-com.png",
                    prefixIconSize: 22.0,
                    validateEmpty: true,
                    keyboardType: TextInputType.emailAddress,
                    checkEmail: true,
                    onChanged: (value) {
                      // Update email validation state when it changes
                      RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value);
                    },
                  ),

                  SizedBox(height: screenSize.height * 0.03),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: _isLoading ? null : _login,
                      color: Color(0xFF123fdb),
                      borderRadius: BorderRadius.circular(16),
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
                                'Continue',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 17,
                                  color: Colors.white,
                                  fontFamily: 'sf-m',
                                ),
                              ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Back button
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      color: Color.fromARGB(255, 232, 232, 232),
                      borderRadius: BorderRadius.circular(16),
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
                                'Back',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 17,
                                  color: Color(0xFF123fdb),
                                  fontFamily: 'sf-m',
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
