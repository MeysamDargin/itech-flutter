import 'package:flutter/material.dart';
import 'package:itech/service/auth/check_email.dart';
import 'package:itech/service/auth/check_username.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Color? borderColor;
  final Color? focusedBorder;
  final bool obscureText;
  final Widget? prefixIcon;
  final String? prefixImagePath;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType keyboardType;
  final bool autofocus;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final double prefixIconSize;
  final bool checkUsername;
  final bool checkEmail;
  final bool validatePassword;
  final bool validateConfirmPassword;
  final bool validateEmpty;
  final String fieldName;
  final TextEditingController? passwordController;
  final FocusNode? focusNode; // اضافه شده
  final Function(String)? onSubmitted;

  const CustomInputField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.prefixImagePath,
    this.focusedBorder,
    this.suffixIcon,
    this.contentPadding,
    this.keyboardType = TextInputType.text,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.borderColor,
    this.validator,
    this.prefixIconSize = 24.0,
    this.checkUsername = false,
    this.checkEmail = false,
    this.validatePassword = false,
    this.validateConfirmPassword = false,
    this.validateEmpty = false,
    this.fieldName = 'Field',
    this.passwordController,
    this.focusNode, // اضافه شده
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  String? errorMessage;
  bool isValid = false;
  bool isChecking = false;
  bool isDirty = false;

  @override
  void initState() {
    super.initState();
    // Add listener to controller to validate on changes
    widget.controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  Future<void> _validateInput() async {
    if (!isDirty && widget.controller.text.isNotEmpty) {
      setState(() {
        isDirty = true;
      });
    }

    if (!isDirty) return;

    // Empty field validation
    if (widget.validateEmpty && widget.controller.text.isEmpty) {
      setState(() {
        errorMessage = '${widget.fieldName} cannot be empty';
        isValid = false;
        isChecking = false;
      });
      return;
    } else if (widget.validateEmpty && widget.controller.text.isNotEmpty) {
      // Clear empty field error when user starts typing
      setState(() {
        errorMessage = null;
        isValid = true;
        isChecking = false;
      });
    }

    // Don't validate empty fields immediately for other validations
    if (widget.controller.text.isEmpty && !widget.validateEmpty) {
      setState(() {
        errorMessage = null;
        isValid = false;
        isChecking = false;
      });
      return;
    }

    // Username validation
    if (widget.checkUsername && widget.controller.text.length >= 3) {
      setState(() {
        isChecking = true;
      });

      try {
        final response = await CheckUsernameService.checkUsername(
          widget.controller.text,
        );
        setState(() {
          isChecking = false;
          isValid = response['available'] == true;
          errorMessage = isValid ? null : 'Username already used';
        });
      } catch (e) {
        setState(() {
          isChecking = false;
          isValid = false;
          errorMessage = 'Error checking username';
        });
      }
    }
    // Email validation
    else if (widget.checkEmail) {
      // Basic email format validation
      final bool isEmailFormat = RegExp(
        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
      ).hasMatch(widget.controller.text);

      if (!isEmailFormat) {
        setState(() {
          isValid = false;
          errorMessage = 'Email format is invalid';
          isChecking = false;
        });
        return;
      }

      setState(() {
        isChecking = true;
      });

      try {
        final response = await CheckEmailService.checkEmail(
          widget.controller.text,
        );
        setState(() {
          isChecking = false;
          isValid = response['available'] == true;
          errorMessage = isValid ? null : 'Email already used';
        });
      } catch (e) {
        setState(() {
          isChecking = false;
          isValid = false;
          errorMessage = 'Error checking email';
        });
      }
    }
    // Password validation
    else if (widget.validatePassword) {
      final bool isValidPassword =
          widget.controller.text.length >= 6 &&
          RegExp(r'^[a-zA-Z0-9!@#\$&*~]+$').hasMatch(widget.controller.text);
      setState(() {
        isValid = isValidPassword;
        errorMessage =
            isValidPassword
                ? null
                : 'Password must be at least 6 characters and in English';
        isChecking = false;
      });
    }
    // Confirm password validation
    else if (widget.validateConfirmPassword &&
        widget.passwordController != null) {
      final bool isMatch =
          widget.controller.text == widget.passwordController!.text;
      setState(() {
        isValid = isMatch;
        errorMessage = isMatch ? null : 'Password does not match';
        isChecking = false;
      });
    }
    // If no specific validation is enabled but field is not empty
    else if (!widget.checkUsername &&
        !widget.checkEmail &&
        !widget.validatePassword &&
        !widget.validateConfirmPassword &&
        !widget.validateEmpty &&
        widget.controller.text.isNotEmpty) {
      setState(() {
        isValid = true;
        errorMessage = null;
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prepare prefix icon - either use the provided icon widget or create one from the image path
    Widget? finalPrefixIcon;
    if (widget.prefixIcon != null) {
      finalPrefixIcon = widget.prefixIcon;
    } else if (widget.prefixImagePath != null) {
      finalPrefixIcon = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Image.asset(
          widget.prefixImagePath!,
          width: widget.prefixIconSize,
          height: widget.prefixIconSize,
          color: Colors.black54,
        ),
      );
    }

    // Determine border color based on validation state
    Color borderColor = widget.borderColor ?? Colors.grey.shade200;
    if (isDirty) {
      if (isChecking) {
        borderColor = Colors.amber;
      } else if (isValid && widget.controller.text.isNotEmpty) {
        borderColor = Colors.green;
      } else if (errorMessage != null) {
        borderColor = Colors.red;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          autofocus: widget.autofocus,
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
            // Force validation when empty validation is enabled
            if (widget.validateEmpty) {
              setState(() {
                isDirty = true;
                if (value.isEmpty) {
                  isValid = false;
                  errorMessage = '${widget.fieldName} cannot be empty';
                } else {
                  // Clear error when user starts typing
                  isValid = true;
                  errorMessage = null;
                }
              });
            }
          },
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontFamily: "Outfit-Medium",
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Colors.black38,
              fontSize: 16,
              fontFamily: "a-r",
            ),
            prefixIcon: finalPrefixIcon,
            suffixIcon:
                isChecking
                    ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(10),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    )
                    : isDirty &&
                        widget.controller.text.isNotEmpty &&
                        !isValid &&
                        errorMessage != null
                    ? const Icon(Icons.error, color: Colors.red)
                    : isDirty && widget.controller.text.isNotEmpty && isValid
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : widget.validateEmpty &&
                        widget.controller.text.isEmpty &&
                        isDirty
                    ? const Icon(Icons.error, color: Colors.red)
                    : widget.suffixIcon,
            contentPadding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: widget.focusedBorder ?? borderColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
            ),
          ),
        ),
        if (errorMessage != null && isDirty)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: "Outfit",
              ),
            ),
          ),
        if (isValid &&
            widget.controller.text.isNotEmpty &&
            isDirty &&
            !widget.validateEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 6),
            child: Text(
              widget.checkUsername
                  ? 'Username is allowed'
                  : widget.checkEmail
                  ? 'Email is allowed'
                  : widget.validatePassword
                  ? 'Password is acceptable'
                  : widget.validateConfirmPassword
                  ? 'Password matches'
                  : '',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontFamily: "Outfit",
              ),
            ),
          ),
      ],
    );
  }
}
