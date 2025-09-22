import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:itech/models/ai/AIFeature_model.dart';
import 'package:itech/widgets/article/ai/language_selector_sheet.dart';
import 'package:itech/models/article/article_detail_model.dart';

class AIFeaturesBottomSheet {
  static void show(
    BuildContext context, {
    required Function onSummarizePressed,
    required Function(String languageCode) onTranslatePressed,
    required Function onAnalyzePressed,
    required Article article,
    required Function(bool) onChatInputChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AIFeaturesBottomSheetContent(
          onSummarizePressed: onSummarizePressed,
          onTranslatePressed: onTranslatePressed,
          onAnalyzePressed: onAnalyzePressed,
          article: article,
          onChatInputChanged: onChatInputChanged,
        );
      },
    );
  }
}

class _AIFeaturesBottomSheetContent extends StatefulWidget {
  final Function onSummarizePressed;
  final Function(String languageCode) onTranslatePressed;
  final Function onAnalyzePressed;
  final Article article;
  final Function(bool) onChatInputChanged;

  const _AIFeaturesBottomSheetContent({
    Key? key,
    required this.onSummarizePressed,
    required this.onTranslatePressed,
    required this.onChatInputChanged,
    required this.onAnalyzePressed,
    required this.article,
  }) : super(key: key);

  @override
  State<_AIFeaturesBottomSheetContent> createState() =>
      _AIFeaturesBottomSheetContentState();
}

class _AIFeaturesBottomSheetContentState
    extends State<_AIFeaturesBottomSheetContent> {
  String searchQuery = '';

  LanguageModel selectedLanguage = LanguageModel(
    languageCode: 'en',
    countryCode: 'US',
    languageName: 'English',
  );

  final List<AIFeature> allFeatures = [];

  @override
  void initState() {
    super.initState();
    allFeatures.addAll([
      AIFeature(
        title: "Summarize",
        emoji: "assets/icons/note-2-svgrepo-com.png",
        description: "I want the summary of the article.",
        onTap: () {
          Navigator.pop(context);
          widget.onSummarizePressed();
        },
      ),
      AIFeature(
        title: "Chat",
        emoji: "assets/icons/chat-round-dots-svgrepo-com (1).png",
        description: "I want to chat with the article.",
        onTap: () {
          Navigator.pop(context);
          widget.onChatInputChanged(true);
        },
      ),
      AIFeature(
        title: "Translate",
        emoji: "assets/icons/translate-svgrepo-com.png",
        description: "I want to translate the article.",
        onTap: () => _showLanguageSelector(),
      ),
      AIFeature(
        title: "Analyze",
        emoji: "assets/icons/activity-svgrepo-com.png",
        description: "I want to analyze the article.",
        onTap: () {
          Navigator.pop(context);
          widget.onAnalyzePressed();
        },
      ),
    ]);
  }

  void _showLanguageSelector() {
    LanguageSelectorSheet.show(
      context,
      onLanguageSelected: (language) {
        setState(() {
          selectedLanguage = language;
          print(
            'Selected language: ${language.languageName} (${language.languageCode})',
          );

          Navigator.pop(context);

          widget.onTranslatePressed(language.languageCode);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<AIFeature> filteredFeatures =
        searchQuery.isEmpty
            ? allFeatures
            : allFeatures
                .where(
                  (feature) =>
                      feature.title.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      feature.description.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                )
                .toList();

    List<List<AIFeature>> featureRows = [];
    for (int i = 0; i < filteredFeatures.length; i++) {
      featureRows.add([filteredFeatures[i]]);
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFEEEEEE).withOpacity(0.85),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 6,
                    margin: EdgeInsets.only(top: 5, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[400], size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontFamily: 'a-r',
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(
                                  top: 8,
                                  bottom: 8,
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),
                          ),
                          if (searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.grey[400],
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 25),

                  // AI Features List
                  Expanded(
                    child:
                        filteredFeatures.isEmpty
                            ? Center(
                              child: Text(
                                "No features found",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontFamily: 'a-r',
                                ),
                              ),
                            )
                            : SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                children:
                                    featureRows
                                        .map(
                                          (row) =>
                                              _buildAIFeatureRow(context, row),
                                        )
                                        .toList(),
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIFeatureRow(BuildContext context, List<AIFeature> features) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children:
            features.map((feature) {
              return Expanded(
                child: _buildAIFeatureCard(context: context, feature: feature),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAIFeatureCard({
    required BuildContext context,
    required AIFeature feature,
  }) {
    return InkWell(
      onTap: feature.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (feature.hasHalo)
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text("👼", style: TextStyle(fontSize: 10)),
                    ),
                  ),
                Image.asset(feature.emoji, width: 40, height: 40),
              ],
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'a-b',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    feature.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'a-r',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
