import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itech/screen/Article/create/article_landing.dart';
import 'dart:io';
import 'package:itech/service/article/send_article.dart';
import 'package:flutter/cupertino.dart';
import 'package:itech/screen/Article/show_article.dart';

class ArticleSettingsPage extends StatefulWidget {
  final String textContent;
  final String quillDelta;

  const ArticleSettingsPage({
    Key? key,
    required this.textContent,
    required this.quillDelta,
  }) : super(key: key);

  @override
  State<ArticleSettingsPage> createState() => _ArticleSettingsPageState();
}

class _ArticleSettingsPageState extends State<ArticleSettingsPage> {
  final TextEditingController titleController = TextEditingController();
  final List<String> availableTags = [
    "philosophy",
    "life",
    "business",
    "misc",
    "technology",
    "science",
    "health",
    "sport",
    "entertainment",
    "travel",
    "food",
    "fashion",
    "art",
    "music",
    "movies",
    "games",
    "other",
  ];
  final List<String> selectedTags = [];
  File? coverImage;
  final ImagePicker _imagePicker = ImagePicker();
  final SendArticleService _sendArticleService = SendArticleService();
  bool _isPublishing = false;

  Future<void> _pickCoverImage() async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      setState(() {
        coverImage = File(pickedImage.path);
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

  void _publishArticle() async {
    final String title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً عنوان مقاله را وارد کنید'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (coverImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً عکس کاور مقاله را انتخاب کنید'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لطفاً حداقل یک تگ انتخاب کنید'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      // ارسال مقاله به سرور
      final result = await _sendArticleService.createArticle(
        title: title,
        delta: widget.quillDelta,
        text: widget.textContent,
        imgCover: coverImage!,
        category: selectedTags.join(','), // تبدیل تگ‌ها به string
      );

      setState(() {
        _isPublishing = false;
      });

      if (result != null && result['status'] == 'success') {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder:
                (context) => ArticleLanding(articleId: result['article_id']),
          ),
          (route) => false, // This will remove all previous routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? 'خطا در انتشار مقاله'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isPublishing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطا در ارسال مقاله: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenPadding = size.width * 0.03;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Article Settings",
          style: TextStyle(fontFamily: 'a-m', fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsetsGeometry.only(right: 15),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                child:
                    _isPublishing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Color(0xFF123fdb),
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          "Publish",
                          style: TextStyle(
                            color: Color(0xFF123fdb),
                            fontFamily: "a-b",
                            fontSize: 18,
                          ),
                        ),
                onTap: _isPublishing ? null : _publishArticle,
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
                  color: Color.fromARGB(255, 238, 238, 238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 194, 194, 194)!,
                  ),
                ),
                child:
                    coverImage != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(coverImage!, fit: BoxFit.cover),
                        )
                        : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                image: AssetImage("assets/icons/image.png"),
                                width: 48,
                                height: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Tap to add cover image",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontFamily: "a-m",
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
                hintText: "What's the meaning of life?",
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
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isSelected
                                    ? const Color(0xFF3E48DF)
                                    : Color.fromARGB(255, 200, 200, 200),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontFamily: "a-m",
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
