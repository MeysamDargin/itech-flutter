import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/service/auth/check_email.dart';
import 'package:itech/service/auth/check_username.dart';
import 'package:itech/screen/auth/signing/signing.dart';
import 'package:itech/screen/auth/verify/verify_code.dart';
import 'package:itech/widgets/public/custom_input_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordRepeaController = TextEditingController();
  bool _obscurePassword = true;

  // Form validation states
  bool _isUsernameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordRepeaController.dispose();
    super.dispose();
  }

  // Check if all form fields are valid
  bool get isFormValid =>
      _isUsernameValid &&
      _isEmailValid &&
      _isPasswordValid &&
      _isConfirmPasswordValid;

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
            child: Form(
              key: _formKey,
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
                      'Hello',
                      style: TextStyle(
                        fontSize: isTablet ? 40 : 50,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2f57ff),
                        fontFamily: 'Outfit-Bold',
                      ),
                    ),
                    Text(
                      'there!',
                      style: TextStyle(
                        fontSize: isTablet ? 40 : 45,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Outfit-Bold',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The future is one step further... \n And this is where you can see it before anyone else.',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.black54,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.05),

                    // Username input with profile icon and validation
                    CustomInputField(
                      controller: _usernameController,
                      hintText: 'Enter your username',
                      prefixImagePath: "assets/icons/profile-svgrepo-com.png",
                      prefixIconSize: 22.0,
                      keyboardType: TextInputType.text,
                      checkUsername: true,
                      onChanged: (value) {
                        // Update username validation state when it changes
                        if (value.length >= 3) {
                          CheckUsernameService.checkUsername(value)
                              .then((response) {
                                setState(() {
                                  _isUsernameValid =
                                      response['available'] == true;
                                });
                              })
                              .catchError((e) {
                                setState(() {
                                  _isUsernameValid = false;
                                });
                              });
                        } else {
                          setState(() {
                            _isUsernameValid = false;
                          });
                        }
                      },
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Email input with envelope icon and validation
                    CustomInputField(
                      controller: _emailController,
                      hintText: 'Enter your email',
                      prefixImagePath: "assets/icons/email-svgrepo-com.png",
                      prefixIconSize: 22.0,
                      keyboardType: TextInputType.emailAddress,
                      checkEmail: true,
                      onChanged: (value) {
                        // Update email validation state when it changes
                        final bool isEmailFormat = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value);

                        if (isEmailFormat) {
                          CheckEmailService.checkEmail(value)
                              .then((response) {
                                setState(() {
                                  _isEmailValid = response['available'] == true;
                                });
                              })
                              .catchError((e) {
                                setState(() {
                                  _isEmailValid = false;
                                });
                              });
                        } else {
                          setState(() {
                            _isEmailValid = false;
                          });
                        }
                      },
                    ),

                    SizedBox(height: screenSize.height * 0.02),

                    // Password input with lock icon, visibility toggle and validation
                    CustomInputField(
                      controller: _passwordController,
                      hintText: 'your Password',
                      obscureText: _obscurePassword,
                      prefixImagePath:
                          "assets/icons/lock-password-svgrepo-com.png",
                      prefixIconSize: 22.0,
                      validatePassword: true,
                      onChanged: (value) {
                        // Update password validation state when it changes
                        final bool isValidPassword =
                            value.length >= 6 &&
                            RegExp(r'^[a-zA-Z0-9!@#\$&*~]+$').hasMatch(value);
                        setState(() {
                          _isPasswordValid = isValidPassword;
                          // Also check confirm password validity when password changes
                          _isConfirmPasswordValid =
                              _passwordRepeaController.text == value &&
                              isValidPassword;
                        });
                      },
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
                    SizedBox(height: screenSize.height * 0.02),

                    // Confirm password input with validation
                    CustomInputField(
                      controller: _passwordRepeaController,
                      hintText: 'Repeat password',
                      obscureText: _obscurePassword,
                      prefixImagePath:
                          "assets/icons/lock-password-svgrepo-com.png",
                      prefixIconSize: 22.0,
                      validateConfirmPassword: true,
                      passwordController: _passwordController,
                      onChanged: (value) {
                        // Update confirm password validation state when it changes
                        setState(() {
                          _isConfirmPasswordValid =
                              value == _passwordController.text &&
                              _isPasswordValid;
                        });
                      },
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

                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        borderRadius: BorderRadius.circular(99),
                        onPressed:
                            isFormValid
                                ? () {
                                  // Proceed with sign up
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => VerifyCode(
                                            email: _emailController.text,
                                            username: _usernameController.text,
                                            password: _passwordController.text,
                                          ),
                                    ),
                                  );
                                  // Here you would call your sign up API
                                }
                                : null, // Disable button if form is not valid
                        color: Color(0xff2f57ff),
                        disabledColor: Color.fromARGB(158, 233, 233, 233),
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 18 : 14,
                        ),
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 17,
                            color:
                                isFormValid ? Colors.white : Color(0xff2f57ff),
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
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                          child: Text(
                            'Sign in',
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
      ),
    );
  }
}
