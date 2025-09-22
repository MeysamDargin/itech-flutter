import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/service/saved/update_category_service.dart';
import 'package:itech/utils/save/fach_save_directory.dart';

class EditSaveDirectorySheet extends StatefulWidget {
  final String directoryId;
  final String currentName;
  final Function(String newName) onDirectoryUpdated;

  const EditSaveDirectorySheet({
    Key? key,
    required this.directoryId,
    required this.currentName,
    required this.onDirectoryUpdated,
  }) : super(key: key);

  @override
  State<EditSaveDirectorySheet> createState() => _EditSaveDirectorySheetState();
}

class _EditSaveDirectorySheetState extends State<EditSaveDirectorySheet> {
  late TextEditingController _nameController;
  final UpdateCategoryService _updateCategoryService = UpdateCategoryService();
  bool _formSubmitted = false;
  bool _isLoading = false;

  // Maximum character limit for the name field
  final int _maxNameLength = 30;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
                  'Edit Collection',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'a-b',
                    color: textTheme.bodyMedium!.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormField(
              "Collection title",
              _nameController,
              hintText: "Enter Collection Name",
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
                      backgroundColor: const Color.fromARGB(255, 242, 243, 251),
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
                              color: const Color(0xff123fdb),
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
                            onPressed: _updateCollection,
                            color: const Color(0xff123fdb),
                            child: const Text(
                              'Update',
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

  Future<void> _updateCollection() async {
    // Set form as submitted to trigger validation display
    setState(() {
      _formSubmitted = true;
      _isLoading = true;
    });

    // Check for required fields
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Check if name exceeds character limit
    if (_nameController.text.length > _maxNameLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message:
                'Collection name cannot exceed $_maxNameLength characters.',
            contentType: ContentType.failure,
          ),
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Check if name has changed
    if (_nameController.text.trim() == widget.currentName) {
      Navigator.pop(context);
      return;
    }

    try {
      // Update the service to include directory_id in the URL
      final response = await _updateCategoryService.updateSaveDirectory(
        name: _nameController.text.trim(),
        directoryId: widget.directoryId,
      );

      if (response != null && response['status'] == 'success') {
        // Refresh categories list
        fetchAndParseCategoryList();

        // Call the callback with the new name
        widget.onDirectoryUpdated(response['directory']['name']);

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
              message: 'Collection updated successfully',
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
              message: 'Failed to update collection. Please try again.',
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
