import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:itech/icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert'; // برای jsonEncode
import 'dart:developer' as developer;
import 'package:itech/service/upload_service.dart';
import 'package:flutter/rendering.dart';
import 'package:itech/screen/Article/edit/article_settings_edit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:itech/service/article/article_detail_service.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

class EditArticle extends StatefulWidget {
  final String? initialDeltaContent;
  final String? articleId;

  const EditArticle({Key? key, this.initialDeltaContent, this.articleId})
    : super(key: key);

  @override
  State<EditArticle> createState() => _EditArticleState();
}

class _EditArticleState extends State<EditArticle> with WidgetsBindingObserver {
  late QuillController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _isKeyboardVisible = false;
  bool _isUploading = false;
  bool _isEditMode = false;

  // متغیر BuildContext
  late BuildContext _buildContext;

  // Image picker and selected images
  final ImagePicker _imagePicker = ImagePicker();
  final UploadService _uploadService = UploadService();

  @override
  void initState() {
    super.initState();

    _controller = QuillController.basic();

    _isEditMode =
        widget.initialDeltaContent != null && widget.articleId != null;

    WidgetsBinding.instance.addObserver(this);

    if (_isEditMode) {
      Future.microtask(() => _setInitialContent());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0;
    });

    // وقتی کیبورد ظاهر می‌شود، با تأخیر اسکرول به موقعیت ویرایش
    // if (_isKeyboardVisible) {
    //   Future.delayed(const Duration(milliseconds: 300), () {
    //     _scrollToEditingPosition();
    //   });
    // }
  }

  // انتخاب و آپلود تصویر
  Future<String?> _pickAndUploadImage() async {
    try {
      // نشان دادن وضعیت بارگذاری
      setState(() {
        _isUploading = true;
      });

      // انتخاب تصویر از گالری
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedImage == null) {
        setState(() {
          _isUploading = false;
        });
        return null; // کاربر هیچ تصویری انتخاب نکرده است
      }

      // نمایش نشانگر بارگذاری
      ScaffoldMessenger.of(_buildContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Uploading image...',
            style: TextStyle(fontFamily: 'Outfit-Medium'),
          ),
          duration: Duration(seconds: 1),
        ),
      );

      // تبدیل XFile به File
      final File imageFile = File(pickedImage.path);

      // آپلود تصویر به سرور
      final String? imageUrl = await _uploadService.uploadImage(imageFile);

      // پایان وضعیت بارگذاری
      setState(() {
        _isUploading = false;
      });

      if (imageUrl == null) {
        ScaffoldMessenger.of(_buildContext).showSnackBar(
          const SnackBar(
            content: Text(
              'Error uploading photo',
              style: TextStyle(fontFamily: 'Outfit-Medium'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      ScaffoldMessenger.of(_buildContext).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      return imageUrl;
    } catch (e) {
      // مدیریت خطا و پایان وضعیت بارگذاری
      setState(() {
        _isUploading = false;
      });
      developer.log('خطا در انتخاب یا آپلود تصویر: $e', name: 'create_article');
      ScaffoldMessenger.of(_buildContext).showSnackBar(
        SnackBar(content: Text('error: $e'), backgroundColor: Colors.red),
      );
      return null;
    }
  }

  // اضافه کردن عکس به ویرایشگر با استفاده از URL
  Future<void> _onImageButtonPressed() async {
    final String? imageUrl = await _pickAndUploadImage();
    if (imageUrl != null) {
      final index = _controller.selection.baseOffset;

      // می‌توانید alt text پیش‌فرض تنظیم کنید
      final imageEmbed = BlockEmbed.image(imageUrl, altText: 'image');
      _controller.document.insert(index, imageEmbed);

      // یا بدون alt text (کاربر بعداً اضافه می‌کند)
      // final imageEmbed = BlockEmbed.image(imageUrl);

      _controller.updateSelection(
        TextSelection.collapsed(offset: index + 1),
        ChangeSource.local,
      );
    }
  }

  // تبدیل محتوای Quill به HTML - نسخه ساده
  String _returnDelta() {
    // چاپ دلتای کوئیل برای اشکال‌زدایی
    final delta = _controller.document.toDelta();
    final deltaJson = delta.toJson();
    return jsonEncode(deltaJson); // تبدیل به استرینگ قابل ذخیره‌سازی
  }

  // تبدیل HTML به محتوای Quill (ساده)
  void _setInitialContent() async {
    if (widget.initialDeltaContent != null &&
        widget.initialDeltaContent!.trim().isNotEmpty) {
      try {
        developer.log(
          'Setting initial content from Delta JSON',
          name: 'edit_article',
        );

        // تبدیل string به JSON
        final List<dynamic> deltaJson = jsonDecode(widget.initialDeltaContent!);

        // ساخت داکیومنت از دلتا
        final Document doc = Document.fromJson(deltaJson);

        // اعمال داکیومنت به کنترلر
        setState(() {
          _controller = QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        });

        developer.log(
          'Document loaded successfully, plain text length: ${_controller.document.toPlainText().length}',
          name: 'edit_article',
        );
      } catch (e) {
        developer.log(
          'Error while parsing initial Delta content: $e',
          name: 'edit_article',
        );
      }
    } else {
      developer.log(
        'Initial Delta content is null or empty',
        name: 'edit_article',
      );
    }
  }

  // رفتن به صفحه بعدی
  void _goToNextPage() async {
    final String deltaContent = _returnDelta();
    final plainText = _controller.document.toPlainText();

    // در حالت ویرایش
    if (_isEditMode && widget.articleId != null) {
      // دریافت اطلاعات مقاله
      final articleDetailService = ArticleDetailService();
      final articleData = await articleDetailService.getArticleDetail(
        widget.articleId!,
      );

      if (articleData != null) {
        final article = articleData.article;

        // انتقال به صفحه تنظیمات ویرایش مقاله
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ArticleSettingsEdit(
                  textContent: plainText,
                  quillDelta: deltaContent,
                  articleId: widget.articleId!,
                  initialTitle: article.title,
                  initialCategory: article.category,
                  initialImageUrl: article.imgCover,
                ),
          ),
        );
      } else {
        // نمایش خطا
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load article data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ذخیره context در متغیر کلاس
    _buildContext = context;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf2f2f2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.help_outline, color: Colors.black),
          //   onPressed: () {},
          // ),
          // IconButton(
          //   icon: const Icon(Icons.more_vert, color: Colors.black),
          //   onPressed: () {},
          // ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
            child: ElevatedButton(
              onPressed: _goToNextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E48DF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Next",
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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Editor with responsive image handling
                        QuillEditor.basic(
                          controller: _controller,
                          config: QuillEditorConfig(
                            embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                            placeholder: "Enter your Story",
                            checkBoxReadOnly: true,
                            floatingCursorDisabled: true,
                            enableScribble: true,
                            scrollable: true,
                            // enableAutoScroll: false,
                            padding: const EdgeInsets.all(0),
                            expands: false,
                            autoFocus: false,
                            enableInteractiveSelection: true,
                            enableSelectionToolbar: false,
                            keyboardAppearance: Brightness.light,
                            customStyles: DefaultStyles(
                              underline: const TextStyle(
                                fontFamily: "g-m",
                                decoration: TextDecoration.underline,
                              ),
                              small: TextStyle(
                                fontFamily: "g-r",
                                fontSize: 13,
                                color: const Color.fromARGB(255, 111, 111, 111),
                              ),
                              quote: DefaultTextBlockStyle(
                                const TextStyle(
                                  color: Colors.black,
                                  fontFamily: "a-m",
                                  height: 2,
                                  fontSize: 22,
                                ),
                                HorizontalSpacing.zero,
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                              lists: DefaultListBlockStyle(
                                const TextStyle(
                                  fontFamily: 'g-r',
                                  fontSize: 21,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  height: 1.3,
                                  letterSpacing: 0.6,
                                  wordSpacing: 2,
                                ),
                                HorizontalSpacing(0, 0),
                                VerticalSpacing.zero,
                                VerticalSpacing(15, 0),
                                const BoxDecoration(),
                                null,
                              ),
                              code: DefaultTextBlockStyle(
                                const TextStyle(
                                  color: Color.fromARGB(255, 180, 182, 195),
                                  fontFamily: "fr-r",
                                  fontSize: 15,
                                  height: 2,
                                ),
                                HorizontalSpacing.zero,
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                BoxDecoration(
                                  color: const Color(0xff222835),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              h1: DefaultTextBlockStyle(
                                const TextStyle(
                                  fontFamily: 'a-b',
                                  color: Colors.black,
                                  fontSize: 40,
                                ),
                                HorizontalSpacing.zero,
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                const BoxDecoration(),
                              ),
                              h2: DefaultTextBlockStyle(
                                const TextStyle(
                                  fontFamily: 'a-b',
                                  color: Colors.black,
                                  fontSize: 28,
                                ),
                                HorizontalSpacing.zero,
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                const BoxDecoration(),
                              ),
                              h3: DefaultTextBlockStyle(
                                const TextStyle(
                                  fontFamily: 'a-b',
                                  color: Colors.black,
                                  fontSize: 25,
                                ),
                                HorizontalSpacing.zero,
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                const BoxDecoration(),
                              ),
                              paragraph: DefaultTextBlockStyle(
                                const TextStyle(
                                  fontFamily: 'g-m',
                                  fontSize: 22,
                                  wordSpacing: 0.5,
                                  color: Colors.black87,
                                ),
                                HorizontalSpacing.zero,
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                const BoxDecoration(),
                              ),
                              placeHolder: DefaultTextBlockStyle(
                                const TextStyle(
                                  fontFamily: "g-m",
                                  fontSize: 25,
                                  color: Colors.grey,
                                ),
                                HorizontalSpacing.zero,
                                VerticalSpacing.zero,
                                VerticalSpacing.zero,
                                const BoxDecoration(),
                              ),
                            ),
                          ),
                        ),

                        // فضای اضافی در انتهای ویرایشگر برای جلوگیری از مخفی شدن متن پشت نوار ابزار
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 120,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating toolbar at the bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFf2f2f2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Add spacing between all toolbar items
                    _buildToolbarButton(
                      QuillToolbarHistoryButton(
                        isUndo: true,
                        controller: _controller,
                        options: QuillToolbarHistoryButtonOptions(
                          iconData: MyIcons.undo,
                          iconSize: 15,
                        ),
                      ),
                    ),
                    _buildToolbarButton(
                      QuillToolbarHistoryButton(
                        isUndo: false,
                        controller: _controller,
                        options: QuillToolbarHistoryButtonOptions(
                          iconData: MyIcons.redo,
                          iconSize: 15,
                        ),
                      ),
                    ),
                    _buildToolbarDivider(),

                    _buildToolbarButton(
                      QuillToolbarToggleStyleButton(
                        controller: _controller,
                        attribute: Attribute.bold,
                        options: const QuillToolbarToggleStyleButtonOptions(
                          iconData: MyIcons.bold,
                          iconSize: 10,
                        ),
                      ),
                    ),
                    _buildToolbarButton(
                      QuillToolbarToggleStyleButton(
                        controller: _controller,
                        attribute: Attribute.italic,
                        options: QuillToolbarToggleStyleButtonOptions(
                          iconData: MyIcons.italic,
                          iconSize: 11,
                        ),
                      ),
                    ),
                    // دکمه هدینگ 1
                    _buildToolbarButton(
                      QuillToolbarToggleStyleButton(
                        controller: _controller,
                        attribute: Attribute.h1,
                        options: QuillToolbarToggleStyleButtonOptions(
                          iconData: null,
                          childBuilder: (
                            dynamic options,
                            dynamic extraOptions,
                          ) {
                            final typedExtraOptions =
                                extraOptions
                                    as QuillToolbarToggleStyleButtonExtraOptions;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: QuillToolbarIconButton(
                                tooltip: "H1",
                                isSelected: typedExtraOptions.isToggled,
                                onPressed: typedExtraOptions.onPressed,
                                iconTheme: null,
                                icon: Text(
                                  'H1',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color:
                                        typedExtraOptions.isToggled
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // دکمه هدینگ 2
                    _buildToolbarButton(
                      QuillToolbarToggleStyleButton(
                        controller: _controller,
                        attribute: Attribute.h2,
                        options: QuillToolbarToggleStyleButtonOptions(
                          iconData: null,
                          childBuilder: (
                            dynamic options,
                            dynamic extraOptions,
                          ) {
                            final typedExtraOptions =
                                extraOptions
                                    as QuillToolbarToggleStyleButtonExtraOptions;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: QuillToolbarIconButton(
                                tooltip: 'H2',
                                isSelected: typedExtraOptions.isToggled,
                                onPressed: typedExtraOptions.onPressed,
                                iconTheme: null,
                                icon: Text(
                                  'H2',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color:
                                        typedExtraOptions.isToggled
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // دکمه هدینگ 3
                    _buildToolbarButton(
                      QuillToolbarToggleStyleButton(
                        controller: _controller,
                        attribute: Attribute.h3,
                        options: QuillToolbarToggleStyleButtonOptions(
                          iconData: null,
                          childBuilder: (
                            dynamic options,
                            dynamic extraOptions,
                          ) {
                            final typedExtraOptions =
                                extraOptions
                                    as QuillToolbarToggleStyleButtonExtraOptions;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: QuillToolbarIconButton(
                                tooltip: "H3",
                                isSelected: typedExtraOptions.isToggled,
                                onPressed: typedExtraOptions.onPressed,
                                iconTheme: null,
                                icon: Text(
                                  'H3',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color:
                                        typedExtraOptions.isToggled
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    _buildToolbarButton(
                      QuillToolbarToggleStyleButton(
                        controller: _controller,
                        attribute: Attribute.underline,
                        options: QuillToolbarToggleStyleButtonOptions(
                          iconData: MyIcons.underline,
                          iconSize: 12,
                        ),
                      ),
                    ),
                    _buildToolbarButton(
                      QuillToolbarClearFormatButton(
                        controller: _controller,
                        options: const QuillToolbarClearFormatButtonOptions(
                          iconSize: 12,
                        ),
                      ),
                    ),
                    QuillToolbarToggleStyleButton(
                      controller: _controller,
                      attribute: Attribute.blockQuote,
                      options: QuillToolbarToggleStyleButtonOptions(
                        iconData: MyIcons.blockQuote,
                      ),
                    ),
                    QuillToolbarToggleStyleButton(
                      controller: _controller,
                      attribute: Attribute.ol,
                    ),
                    QuillToolbarToggleStyleButton(
                      controller: _controller,
                      attribute: Attribute.ul,
                    ),
                    QuillToolbarToggleStyleButton(
                      controller: _controller,
                      attribute: Attribute.codeBlock,
                    ),
                    _buildToolbarDivider(),
                    _buildToolbarButton(
                      IconButton(
                        icon: Icon(MyIcons.img, size: 20),
                        onPressed: _isUploading ? null : _onImageButtonPressed,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    _buildToolbarDivider(),
                    _buildToolbarButton(
                      QuillToolbarColorButton(
                        controller: _controller,
                        isBackground: false,
                        options: QuillToolbarColorButtonOptions(
                          iconData: MyIcons.textColor,
                          iconSize: 12,
                        ),
                      ),
                    ),
                    _buildToolbarButton(
                      QuillToolbarColorButton(
                        controller: _controller,
                        isBackground: true,
                        options: QuillToolbarColorButtonOptions(
                          iconData: MyIcons.bgColor,
                          iconSize: 12,
                        ),
                      ),
                    ),
                    _buildToolbarDivider(),
                    _buildToolbarButton(
                      QuillToolbarLinkStyleButton(
                        controller: _controller,
                        options: QuillToolbarLinkStyleButtonOptions(
                          iconData: MyIcons.link,
                          iconSize: 12,
                        ),
                      ),
                    ),
                    _buildToolbarDivider(),
                    // دکمه‌های عملیات متن
                    _buildToolbarButton(
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          final selection = _controller.selection;
                          if (selection.isValid && !selection.isCollapsed) {
                            final text = _controller.document.getPlainText(
                              selection.start,
                              selection.end - selection.start,
                            );
                            Clipboard.setData(ClipboardData(text: text));
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    _buildToolbarButton(
                      IconButton(
                        icon: const Icon(Icons.paste, size: 20),
                        onPressed: () async {
                          final data = await Clipboard.getData('text/plain');
                          if (data?.text != null) {
                            final index = _controller.selection.baseOffset;
                            _controller.document.insert(index, data!.text!);
                            _controller.updateSelection(
                              TextSelection.collapsed(
                                offset: index + data.text!.length,
                              ),
                              ChangeSource.local,
                            );
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    _buildToolbarButton(
                      IconButton(
                        icon: const Icon(Icons.content_cut, size: 20),
                        onPressed: () {
                          final selection = _controller.selection;
                          if (selection.isValid && !selection.isCollapsed) {
                            final text = _controller.document.getPlainText(
                              selection.start,
                              selection.end - selection.start,
                            );
                            Clipboard.setData(ClipboardData(text: text));
                            _controller.document.delete(
                              selection.start,
                              selection.end - selection.start,
                            );
                            _controller.updateSelection(
                              TextSelection.collapsed(offset: selection.start),
                              ChangeSource.local,
                            );
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    _buildToolbarButton(
                      IconButton(
                        icon: const Icon(Icons.select_all, size: 20),
                        onPressed: () {
                          final length = _controller.document.length - 1;
                          _controller.updateSelection(
                            TextSelection(baseOffset: 0, extentOffset: length),
                            ChangeSource.local,
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // نشانگر بارگذاری در حین آپلود تصویر
          if (_isUploading)
            Container(
              child: const Center(
                child: SpinKitThreeBounce(color: Color(0xFF3E48DF), size: 30.0),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(Widget button) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(height: 35, child: button),
    );
  }

  Widget _buildToolbarDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 20,
        child: VerticalDivider(
          width: 1,
          thickness: 1,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
