import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/screen/auth/signing/signing.dart';
import 'package:itech/service/auth/logout_service.dart';
import 'package:itech/service/feedback/send_feedback_service.dart';

class LogoutSheet extends StatefulWidget {
  final Function? onCollectionCreated;

  const LogoutSheet({Key? key, this.onCollectionCreated}) : super(key: key);

  @override
  State<LogoutSheet> createState() => _LogoutSheetState();
}

class _LogoutSheetState extends State<LogoutSheet> {
  final TextEditingController _name = TextEditingController();
  final SendFeedbackService _sendFeedbackService = SendFeedbackService();
  bool _formSubmitted = false;
  bool _isLoading = false;

  // Maximum character limit for the name field
  final int _maxNameLength = 100;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    199,
                    199,
                    199,
                  ).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'a-b',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: const Color.fromARGB(255, 230, 230, 230), height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Are you sure you want to log out?",
                  style: TextStyle(fontFamily: 'a-m', fontSize: 17),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 238, 238),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'a-m',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child:
                      _isLoading
                          ? Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                          : CupertinoButton(
                            borderRadius: BorderRadius.circular(99),
                            onPressed: handleLogout,
                            color: Colors.red,
                            child: const Text(
                              'Yes, Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'a-m',
                                fontSize: 16,
                              ),
                            ),
                          ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    Widget? suffix,
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    bool isLast = false,
    bool isRequired = false,
    int? maxLength,
  }) {
    // Only show error if form has been submitted and field is empty
    bool hasError = _formSubmitted && isRequired && controller.text.isEmpty;

    // Calculate current character count
    int currentLength = controller.text.length;
    bool isNearLimit = maxLength != null && currentLength > (maxLength * 0.8);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: "a-m",
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  if (isRequired)
                    Text(
                      " *",
                      style: TextStyle(
                        fontFamily: "Outfit-Medium",
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
              if (maxLength != null)
                Text(
                  "$currentLength/$maxLength",
                  style: TextStyle(
                    fontFamily: "a-r",
                    fontSize: 12,
                    color:
                        isNearLimit
                            ? (currentLength >= maxLength
                                ? Colors.red
                                : Colors.orange)
                            : Colors.grey,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),

          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            maxLength: maxLength,
            // Hide the default counter
            buildCounter:
                (
                  context, {
                  required currentLength,
                  required isFocused,
                  maxLength,
                }) => null,
            onChanged: (value) {
              // If form has been submitted, update validation state when typing
              if (_formSubmitted && isRequired || maxLength != null) {
                setState(() {
                  // This will trigger a rebuild to update error state and character count
                });
              }
            },
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey[200]!,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey[300]!,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              suffixIcon:
                  suffix ??
                  (hasError ? Icon(Icons.error, color: Colors.red) : null),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 6),
              child: Text(
                "$label cannot be empty",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontFamily: "a-r",
                ),
              ),
            ),
        ],
      ),
    );
  }

  void handleLogout() async {
    // نمایش اندیکاتور پیشرفت
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await LogoutService.completeLogout(context);
      Navigator.pop(context); // بستن دیالوگ پیشرفت

      // انتقال به صفحه لاگین با حذف تمام صفحات قبلی
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );

      // نمایش پیام موفقیت با AwesomeSnackbar
      final successSnackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Goodbye',
          message: 'Without you, iTech is missing something!',
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(successSnackBar);
    } catch (e) {
      Navigator.pop(context); // بستن دیالوگ پیشرفت در صورت خطا

      // نمایش پیام خطای سیستمی
      final failureSnackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'system error',
          message: 'error: ${e.toString()}',
          contentType: ContentType.warning,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(failureSnackBar);
    }
  }
}
