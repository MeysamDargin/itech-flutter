import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:itech/service/article/article_update_service.dart';
import 'package:itech/utils/url.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ArticleSettingsEdit extends StatefulWidget {
  final String textContent;
  final String quillDelta;
  final String articleId;
  final String initialTitle;
  final String initialCategory;
  final String initialImageUrl;

  const ArticleSettingsEdit({
    Key? key,
    required this.textContent,
    required this.quillDelta,
    required this.articleId,
    required this.initialTitle,
    required this.initialCategory,
    required this.initialImageUrl,
  }) : super(key: key);

  @override
  State<ArticleSettingsEdit> createState() => _ArticleSettingsEditState();
}

class _ArticleSettingsEditState extends State<ArticleSettingsEdit> {
  final TextEditingController titleController = TextEditingController();
  final List<String> availableTags = [
    "philosophy",
    "life",
    "misc",
    "technology",
    "business",
    "sport",
  ];
  List<String> selectedTags = [];
  File? coverImage;
  String? existingImageUrl;
  final ImagePicker _imagePicker = ImagePicker();
  final ArticleUpdateService _articleUpdateService = ArticleUpdateService();
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.initialTitle;
    existingImageUrl = widget.initialImageUrl;

    // پردازش دسته‌بندی‌های اولیه
    if (widget.initialCategory.isNotEmpty) {
      final categories = widget.initialCategory.split(',');
      for (final category in categories) {
        if (availableTags.contains(category.trim())) {
          selectedTags.add(category.trim());
        }
      }
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      setState(() {
        coverImage = File(pickedImage.path);
        existingImageUrl =
            null; // وقتی تصویر جدید انتخاب می‌شود، تصویر قبلی را پاک کن
      });
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  void _updateArticle() async {
    final String title = titleController.text.trim();

    if (title.isEmpty) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Required Field!',
          message: 'Please enter an article title',
          contentType: ContentType.warning,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }

    if (coverImage == null && existingImageUrl == null) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Required Field!',
          message: 'Please select a cover image',
          contentType: ContentType.warning,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }

    if (selectedTags.isEmpty) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Required Field!',
          message: 'Please select at least one tag',
          contentType: ContentType.warning,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      // به‌روزرسانی مقاله
      final result = await _articleUpdateService.updateArticle(
        articleId: widget.articleId,
        title: title,
        text: widget.textContent,
        delta: widget.quillDelta,
        imgCover: coverImage, // اگر null باشد، از تصویر موجود استفاده می‌شود
        category: selectedTags.join(','), // تبدیل تگ‌ها به string
      );

      setState(() {
        _isPublishing = false;
      });

      if (result != null && result['status'] == 'success') {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success!',
            message: 'Article updated successfully',
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);

        // بازگشت به صفحه اصلی
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: result?['message'] ?? 'Error updating article',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    } catch (e) {
      setState(() {
        _isPublishing = false;
      });
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error!',
          message: 'Error updating article: $e',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenPadding = size.width * 0.03;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFf2f2f2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Article",
          style: TextStyle(color: Colors.black, fontFamily: "a-b"),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
            child: ElevatedButton(
              onPressed: _isPublishing ? null : _updateArticle,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E48DF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isPublishing
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        "Update",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "a-m",
                          fontSize: 16,
                        ),
                      ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Cover Image Section
            const Text(
              "Cover Image",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: "a-m",
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickCoverImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child:
                    coverImage != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(coverImage!, fit: BoxFit.cover),
                        )
                        : existingImageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            '${ApiAddress.baseUrl}$existingImageUrl',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Error loading image",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontFamily: "a-r",
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                        : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap to add cover image",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "a-r",
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),

            // Title Section
            const Text(
              "Article Title",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: "a-m",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter article title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3E48DF)),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontSize: 16, fontFamily: "a-r"),
            ),
            const SizedBox(height: 24),

            // Tags Section
            const Text(
              "Tags",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: "a-m",
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  availableTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () => _toggleTag(tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xFF3E48DF)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF3E48DF)
                                    : Colors.grey[300]!,
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontFamily: "a-r",
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
