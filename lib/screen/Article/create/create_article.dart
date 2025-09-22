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
import 'package:itech/screen/Article/create/article_settings_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class CreateArticle extends StatefulWidget {
  const CreateArticle({Key? key}) : super(key: key);

  @override
  State<CreateArticle> createState() => _CreateArticleState();
}

class _CreateArticleState extends State<CreateArticle>
    with WidgetsBindingObserver {
  late QuillController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _isKeyboardVisible = false;
  bool _isUploading = false;

  // متغیر BuildContext
  late BuildContext _buildContext;

  // Image picker and selected images
  final ImagePicker _imagePicker = ImagePicker();
  final UploadService _uploadService = UploadService();

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
    WidgetsBinding.instance.addObserver(this);

    // پیمایش خودکار هنگام تایپ در نزدیکی پایین صفحه
    _controller.document.changes.listen((event) {
      // اسکرول به موقعیت ویرایش پس از تغییرات متن
      // if (event.source == ChangeSource.local) {
      //   _scrollToEditingPosition();
      // }
    });
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

      // نمایش نشانگر بارگذاری - فقط اگر context هنوز معتبر باشد
      if (mounted) {
        // به جای نمایش اسنک‌بار، فقط وضعیت بارگذاری را نمایش می‌دهیم
        // وضعیت بارگذاری با متغیر _isUploading کنترل می‌شود
      }

      // تبدیل XFile به File
      final File imageFile = File(pickedImage.path);

      // آپلود تصویر به سرور
      final String? imageUrl = await _uploadService.uploadImage(imageFile);

      // پایان وضعیت بارگذاری
      setState(() {
        _isUploading = false;
      });

      if (imageUrl == null) {
        // آپلود ناموفق بود، اما اسنک‌بار نمایش نمی‌دهیم تا از خطا جلوگیری شود
        developer.log('Image upload failed', name: 'create_article');
        return null;
      }

      // آپلود موفق بود، اما اسنک‌بار نمایش نمی‌دهیم تا از خطا جلوگیری شود
      developer.log(
        'Image uploaded successfully: $imageUrl',
        name: 'create_article',
      );

      return imageUrl;
    } catch (e) {
      // مدیریت خطا و پایان وضعیت بارگذاری
      setState(() {
        _isUploading = false;
      });
      developer.log(
        'Error selecting or uploading image: $e',
        name: 'create_article',
      );

      // به جای نمایش اسنک‌بار، فقط خطا را در لاگ ثبت می‌کنیم
      developer.log(
        'Error uploading image: $e',
        name: 'create_article',
        error: e,
      );
      return null;
    }
  }

  // اضافه کردن عکس به ویرایشگر با استفاده از URL
  Future<void> _onImageButtonPressed() async {
    if (_isUploading) return;

    final String? imageUrl = await _pickAndUploadImage();
    if (imageUrl != null) {
      final index = _controller.selection.baseOffset;

      // می‌توانید مقدار پیش‌فرض alt text تنظیم کنید
      final imageEmbed = BlockEmbed.image(imageUrl, altText: 'image');
      _controller.document.insert(index, imageEmbed);

      _controller.updateSelection(
        TextSelection.collapsed(offset: index + 1),
        ChangeSource.local,
      );

      _controller.document.insert(_controller.selection.baseOffset, '\n\n');
      _controller.updateSelection(
        TextSelection.collapsed(offset: _controller.selection.baseOffset + 3),
        ChangeSource.local,
      );
    }
  }

  String _returnDelta() {
    final delta = _controller.document.toDelta();
    final deltaJson = delta.toJson();
    return jsonEncode(deltaJson); // تبدیل به استرینگ قابل ذخیره‌سازی
  }

  // رفتن به صفحه بعدی
  void _goToNextPage() {
    final String deltaContent = _returnDelta();

    // لاگ‌گیری از متن مقاله
    final plainText = _controller.document.toPlainText();
    developer.log(
      'Article plainText Content: $plainText',
      name: 'create_article',
    );
    developer.log(
      'Article delta Content: $deltaContent',
      name: 'create_article',
    );

    // انتقال به صفحه تنظیمات مقاله (تایتل، کاور، تگ‌ها)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ArticleSettingsPage(
              textContent: plainText,
              quillDelta: deltaContent,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ذخیره context در متغیر کلاس - استفاده از mounted context برای جلوگیری از خطا
    if (mounted) {
      _buildContext = context;
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                            floatingCursorDisabled: false,
                            enableScribble: true,
                            scrollable: true,
                            requestKeyboardFocusOnCheckListChanged: false,
                            // enableAutoScroll: false,
                            padding: const EdgeInsets.all(0),
                            expands: false,
                            autoFocus: true,
                            enableInteractiveSelection: true,
                            enableSelectionToolbar: false,
                            keyboardAppearance: Brightness.light,
                            customStyles: DefaultStyles(
                              // bold: const TextStyle(fontFamily: "g-b"),
                              // italic: const TextStyle(
                              //   fontFamily: "g-m",
                              //   fontStyle: FontStyle.italic,
                              // ),
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
                                  color: Colors.black87,
                                  wordSpacing: 0.5,
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
                        options: const QuillToolbarToggleStyleButtonOptions(
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
                        options: const QuillToolbarToggleStyleButtonOptions(
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
                      options: const QuillToolbarToggleStyleButtonOptions(
                        iconData: MyIcons.blockQuote,
                      ),
                    ),
                    QuillToolbarToggleStyleButton(
                      controller: _controller,
                      attribute: Attribute.ol,
                      options: const QuillToolbarToggleStyleButtonOptions(),
                    ),
                    QuillToolbarToggleStyleButton(
                      controller: _controller,
                      attribute: Attribute.ul,
                      options: const QuillToolbarToggleStyleButtonOptions(),
                    ),
                    QuillToolbarToggleStyleButton(
                      controller: _controller,
                      attribute: Attribute.codeBlock,
                      options: const QuillToolbarToggleStyleButtonOptions(),
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
                        options: const QuillToolbarColorButtonOptions(
                          iconData: MyIcons.textColor,
                          iconSize: 12,
                        ),
                      ),
                    ),
                    _buildToolbarButton(
                      QuillToolbarColorButton(
                        controller: _controller,
                        isBackground: true,
                        options: const QuillToolbarColorButtonOptions(
                          iconData: MyIcons.bgColor,
                          iconSize: 12,
                        ),
                      ),
                    ),
                    _buildToolbarDivider(),
                    _buildToolbarButton(
                      QuillToolbarLinkStyleButton(
                        controller: _controller,
                        options: const QuillToolbarLinkStyleButtonOptions(
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
