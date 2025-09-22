import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/service/feedback/send_feedback_service.dart';
import 'package:itech/service/report/send_report.dart';

class SendReportSheet extends StatefulWidget {
  final Function? onCollectionCreated;
  final String articleId;

  const SendReportSheet({
    Key? key,
    this.onCollectionCreated,
    required this.articleId,
  }) : super(key: key);

  @override
  State<SendReportSheet> createState() => _SendReportSheetState();
}

class _SendReportSheetState extends State<SendReportSheet> {
  final TextEditingController _name = TextEditingController();
  final SendReportService _sendSendReport = SendReportService();
  bool _formSubmitted = false;
  bool _isLoading = false;

  // Maximum character limit for the name field
  final int _maxNameLength = 100;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.background,
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
                Text(
                  'Send',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'a-b',
                    color: textTheme.bodyMedium!.color,
                  ),
                ),
                SizedBox(width: 5),
                const Text(
                  'Report',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'a-b',
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormField(
              "Report Message",
              _name,
              hintText: "Enter your message",
              isRequired: true,
              maxLength: _maxNameLength,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 251, 242, 242),
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
                            onPressed: _sendNewFeedback,
                            color: Colors.red,
                            child: const Text(
                              'Send',
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                      color: textTheme.bodyMedium!.color,
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
              fillColor: readOnly ? Colors.grey[100] : colorScheme.background,
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

  Future<void> _sendNewFeedback() async {
    // Set form as submitted to trigger validation display
    setState(() {
      _formSubmitted = true;
      _isLoading = true;
    });

    // Check for required fields
    bool hasEmptyRequiredFields = false;

    // Check required fields
    if (_name.text.trim().isEmpty) {
      hasEmptyRequiredFields = true;
    }

    if (hasEmptyRequiredFields) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Check if name exceeds character limit
    if (_name.text.length > _maxNameLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'Report Message cannot exceed $_maxNameLength characters.',
            contentType: ContentType.failure,
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final success = await _sendSendReport.sendReport(
        message: _name.text,
        articleId: widget.articleId,
      );

      if (success != null && success['status'] != 'error') {
        // Close the bottom sheet
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success',
              color: Colors.red,
              message: 'Report Send successfully',
              contentType: ContentType.success,
            ),
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error',
              message: 'Failed to create Report. Please try again.',
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'An error occurred. Please try again.',
            contentType: ContentType.failure,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
