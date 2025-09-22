import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:itech/models/ai/article_summary_model.dart';
import 'package:itech/models/ai/article_lang_model.dart';
import 'dart:convert';
import 'dart:math' as Math;
import 'package:lottie/lottie.dart';

class ArticleContentWidget extends StatelessWidget {
  final String originaldelta;
  final ArticleSummary? articleSummary;
  final ArticleLang? articleLang;
  final bool isShowingSummary;
  final bool isShowingTranslated;

  const ArticleContentWidget({
    Key? key,
    required this.originaldelta,
    this.articleSummary,
    this.articleLang,
    this.isShowingSummary = false,
    this.isShowingTranslated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return getArticleContent(context);
  }

  Widget getArticleContent(context) {
    // اگر هم ترجمه و هم خلاصه فعال است
    if (isShowingTranslated &&
        isShowingSummary &&
        articleLang != null &&
        articleSummary != null) {
      if (articleLang!.isLoading || articleSummary!.isLoading) {
        return Center(
          child: Lottie.asset(
            'assets/animation/Ai loading model.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        );
      } else if (articleLang!.error != null) {
        return Text(
          "خطا در دریافت ترجمه: ${articleLang!.error}",
          style: TextStyle(color: Colors.red),
        );
      } else if (articleSummary!.error != null) {
        return Text(
          "خطا در دریافت خلاصه: ${articleSummary!.error}",
          style: TextStyle(color: Colors.red),
        );
      } else {
        // نمایش خلاصه ترجمه شده
        return _buildQuillViewer(articleSummary!.summaryDelta ?? "", context);
      }
    }
    // اگر فقط ترجمه فعال است
    else if (isShowingTranslated && articleLang != null) {
      if (articleLang!.isLoading) {
        return Center(
          child: Lottie.asset(
            'assets/animation/Ai loading model.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        );
      } else if (articleLang!.error != null) {
        return Text(
          "خطا در دریافت ترجمه: ${articleLang!.error}",
          style: TextStyle(color: Colors.red),
        );
      } else {
        // نمایش ترجمه
        return _buildQuillViewer(articleLang!.langDelta ?? "", context);
      }
    }
    // اگر فقط خلاصه فعال است
    else if (isShowingSummary && articleSummary != null) {
      if (articleSummary!.isLoading) {
        return Center(
          child: Lottie.asset(
            'assets/animation/Ai loading model.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        );
      } else if (articleSummary!.error != null) {
        return Text(
          "خطا در دریافت خلاصه: ${articleSummary!.error}",
          style: TextStyle(color: Colors.red),
        );
      } else {
        // نمایش خلاصه
        return _buildQuillViewer(articleSummary!.summaryDelta ?? "", context);
      }
    }
    // نمایش متن اصلی
    else {
      return _buildQuillViewer(originaldelta, context);
    }
  }

  Widget _buildQuillViewer(String deltaJson, context) {
    final textTheme = Theme.of(context).textTheme;

    try {
      print(
        'Attempting to parse Delta JSON: ${deltaJson.substring(0, Math.min(100, deltaJson.length))}...',
      );

      List<dynamic> deltaData;

      try {
        deltaData = jsonDecode(deltaJson);
      } catch (jsonError) {
        print('Error parsing Delta JSON: $jsonError');

        final errorMessage = "Error parsing content: $jsonError";
        deltaData = [
          {"insert": errorMessage},
          {"insert": "\n"},
        ];
      }

      // --- اضافه کردن تضمینی newline ---
      if (deltaData.isNotEmpty) {
        final last = deltaData.last;
        if (last is Map && last.containsKey('insert')) {
          if (!(last['insert'] as String).endsWith('\n')) {
            last['insert'] = "${last['insert']}\n";
          }
        } else {
          deltaData.add({"insert": "\n"});
        }
      } else {
        deltaData.add({"insert": "\n"});
      }
      // --- پایان اضافه کردن newline ---

      // ایجاد Document از Delta JSON
      final document = Document.fromJson(deltaData);

      // ایجاد controller با document
      final controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );

      // تنظیم به حالت فقط خواندنی
      controller.readOnly = true;

      return QuillEditor.basic(
        controller: controller,
        config: QuillEditorConfig(
          showCursor: false,
          enableInteractiveSelection: true,
          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
          padding: const EdgeInsets.all(16),
          customStyles: DefaultStyles(
            h1: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'a-b',
                color: textTheme.bodyMedium!.color,
                height: 1.3,
              ),
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing(16, 0),
              const BoxDecoration(),
            ),
            h2: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'a-b',
                color: textTheme.bodyMedium!.color,
                height: 1.3,
              ),
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing(14, 0),
              const BoxDecoration(),
            ),
            h3: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'a-b',
                color: textTheme.bodyMedium!.color,
                height: 1.3,
              ),
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing(12, 0),
              const BoxDecoration(),
            ),
            paragraph: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 22,
                fontFamily: 'g-m',
                color: textTheme.bodyMedium!.color,
                height: 1.6,
                wordSpacing: 0.5,
              ),
              HorizontalSpacing(0, 0),
              VerticalSpacing.zero,
              VerticalSpacing(8, 0),
              const BoxDecoration(),
            ),
            quote: DefaultTextBlockStyle(
              TextStyle(
                fontSize: 22,
                fontFamily: 'a-m',
                fontStyle: FontStyle.italic,
                color: textTheme.bodyMedium!.color,
                height: 1.6,
              ),
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing(16, 0),
              BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    width: 4,
                  ),
                ),
              ),
            ),
            code: DefaultTextBlockStyle(
              const TextStyle(
                fontSize: 14,
                fontFamily: 'fr-r',
                color: Color.fromARGB(255, 180, 182, 195),
                height: 1.4,
              ),
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing(16, 0),
              BoxDecoration(
                color: const Color(0xff222835),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            lists: DefaultListBlockStyle(
              TextStyle(
                fontSize: 21,
                fontFamily: 'g-r',
                color: textTheme.bodyMedium!.color,
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
          ),
        ),
      );
    } catch (e) {
      print('خطا در پارس کردن Delta: $e');
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'خطا در نمایش محتوا:',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              e.toString(),
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'محتوای خام:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                originaldelta.length > 500
                    ? '${originaldelta.substring(0, 500)}...'
                    : originaldelta,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
