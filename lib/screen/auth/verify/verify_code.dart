import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itech/service/otp/send_otp_code.dart';
import 'package:itech/service/otp/verify_code.dart';
import 'package:itech/service/auth/register_service.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:itech/screen/Profile/edit/edit_profile.dart';
import 'package:provider/provider.dart';

class VerifyCode extends StatefulWidget {
  final String email;
  final String username;
  final String password;
  const VerifyCode({
    super.key,
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  bool _isLoading = false; // Track loading state
  bool _isVerifying = false; // Track verification state
  final SendOtpCodeService _sendOtpCodeService = SendOtpCodeService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Controllers for the 6 OTP input fields
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  // Focus nodes for the 6 OTP input fields
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  // Animation related variables
  bool _isAnimatingSuccess = false;
  final List<Color> _animatedBorderColors = List.generate(
    6,
    (index) => Colors.grey.shade300,
  );

  // Timer related variables
  Timer? _resendTimer;
  int _remainingTime = 300; // 5 minutes in seconds
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    // Send verification code when page loads
    _sendVerifyCode();
    // Start the timer
    _startResendTimer();
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    // Cancel timer if active
    _resendTimer?.cancel();
    super.dispose();
  }

  // Start timer for resend functionality
  void _startResendTimer() {
    setState(() {
      _remainingTime = 300; // 5 minutes
      _canResend = false;
    });

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  // Format remaining time as mm:ss
  String get _formattedTime {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Send verification code to email
  Future<void> _sendVerifyCode() async {
    // Show loading state
    setState(() {
      _isLoading = true;
    });

    final email = widget.email;

    // Validate email
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email is required')));
      setState(() {
        _isLoading = false;
      });
      return;
    }
    // Call send OTP service
    await _sendOtpCodeService.sendOtpCode(email);

    setState(() {
      _isLoading = false;
    });
    _startResendTimer();
  }

  // Handle OTP input changes
  void _onOtpChanged(String value, int index) {
    // If a digit is entered, move to the next field
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
      } else {
        // Last digit entered, verify the code
        _verifyOtpCode();
      }
    }
  }

  // Reset OTP input fields
  void _resetOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
    }
    // Reset border colors
    setState(() {
      for (int i = 0; i < 6; i++) {
        _animatedBorderColors[i] = Colors.grey.shade300;
      }
    });
  }

  // Verify the entered OTP code
  Future<void> _verifyOtpCode() async {
    final otpCode = _otpControllers.map((c) => c.text).join();

    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter complete 6-digit code')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final response = await VerifyCodeService.verifyCode(
        widget.email,
        otpCode,
      );

      if (response['success'] == true) {
        _showSuccessAnimation();
        // Register user will be called after animation completes
      } else {
        final error = response['error'] ?? 'Invalid verification code';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        _resetOtpFields();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
      _resetOtpFields();
    } finally {
      if (mounted && !_isAnimatingSuccess) {
        setState(() => _isVerifying = false);
      }
    }
  }

  // Register user after successful verification
  Future<void> _registerUser() async {
    try {
      final response = await RegisterService.register(
        widget.email,
        widget.username,
        widget.password,
      );

      if (response['sessionid'] != null) {
        // ذخیره session و مدیریت وضعیت
        await Future.wait([
          _secureStorage.write(key: 'sessionid', value: response['sessionid']),
          _secureStorage.write(key: 'newUser', value: 'true'),
        ]);

        // اتصال WebSocket
        final webSocketManager = Provider.of<ProfileSocketManager>(
          context,
          listen: false,
        );
        // Wait for WebSocket to reconnect
        await webSocketManager.reconnectWebSockets();

        // Add a short delay to ensure WebSocket data is received
        await Future.delayed(Duration(seconds: 1));

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const EditProfilePage()),
            (route) => false,
          );
        }
      } else {
        _handleRegistrationFailure();
      }
    } catch (e) {
      _handleRegistrationFailure(error: e.toString());
    }
  }

  void _handleRegistrationFailure({String? error}) {
    setState(() {
      _isVerifying = false;
      _isAnimatingSuccess = false;
    });
    _resetOtpFields();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Registration failed. Please try again.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show success animation
  void _showSuccessAnimation() {
    setState(() {
      _isAnimatingSuccess = true;
    });

    // Animate each box border to green in sequence
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) {
          setState(() {
            _animatedBorderColors[i] = Colors.green;
          });
        }
      });
    }

    // Wait for animation to complete before proceeding
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        _registerUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 40),
                          Text(
                            'Enter Verification Code',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff2f57ff),
                              fontFamily: 'Outfit-Bold',
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'A 6-digit code has been sent to ${widget.email}',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.grey.shade600,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildOtpInputBoxes(context),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed:
                                    _canResend ? () => _sendVerifyCode() : null,
                                child: Text(
                                  'Resend Code',
                                  style: TextStyle(
                                    color:
                                        _canResend
                                            ? const Color(0xff2f57ff)
                                            : Colors.grey,
                                    fontFamily: 'Outfit-Medium',
                                  ),
                                ),
                              ),
                              Text(
                                'Didn\'t receive the code?',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              _canResend
                                  ? 'You can resend now'
                                  : 'Resend in $_formattedTime',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: 'Outfit',
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (_isVerifying)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        const Color(0xff2f57ff),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Verifying code...',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Outfit',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Change Email Address',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Build OTP input boxes
  Widget _buildOtpInputBoxes(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) {
          return SizedBox(
            width: 45,
            height: 55,
            child: TextFormField(
              autofocus: index == 0,
              controller: _otpControllers[index],
              focusNode: _otpFocusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              showCursor: false,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Outfit-Bold',
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _animatedBorderColors[index],
                    width: _isAnimatingSuccess ? 2.0 : 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _animatedBorderColors[index],
                    width: _isAnimatingSuccess ? 2.0 : 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color:
                        _isAnimatingSuccess
                            ? Colors.green
                            : const Color(0xff2f57ff),
                    width: 2.0,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
                counterText: '',
              ),
              onChanged: (value) => _onOtpChanged(value, index),
            ),
          );
        }),
      ),
    );
  }
}
