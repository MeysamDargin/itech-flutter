import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/models/save/category_save_list_model.dart';
import 'package:itech/service/saved/article_saved_service.dart';
import 'package:itech/utils/save/fach_save_directory.dart';
import 'package:itech/widgets/saved/create_save_directory.dart';

class SaveToBookmarkSheet extends StatefulWidget {
  final String articleId;
  final Function(bool)? onSaveStateChanged;

  const SaveToBookmarkSheet({
    Key? key,
    required this.articleId,
    this.onSaveStateChanged,
  }) : super(key: key);

  @override
  State<SaveToBookmarkSheet> createState() => _SaveToBookmarkSheetState();
}

class _SaveToBookmarkSheetState extends State<SaveToBookmarkSheet> {
  final ArticleSavedService _articleSavedService = ArticleSavedService();
  bool _isSaved = false;
  bool _isLoading = true;
  bool _isSaving = false;
  List<SaveDirectory> _directories = [];
  String? _selectedDirectoryId;

  @override
  void initState() {
    super.initState();
    _loadSaveDirectories();
  }

  Future<void> _loadSaveDirectories() async {
    try {
      final categoryList = await fetchAndParseCategoryList();

      if (categoryList != null) {
        setState(() {
          _directories = categoryList.directories;

          // If there's at least one directory, select the first one by default
          if (_directories.isNotEmpty) {
            _selectedDirectoryId = _directories[0].id;
          }

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading save directories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savedArticleHandle() async {
    if (_selectedDirectoryId == null) {
      // Show error if no directory is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a folder'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _isSaved = true; // Optimistically set to saved
    });

    try {
      // Save article to the selected directory
      final response = await _articleSavedService.saveArticle(
        widget.articleId,
        directoryId: _selectedDirectoryId,
      );

      if (response['status'] == 'error') {
        throw Exception(response['message'] ?? 'Failed to save article');
      }

      // Notify parent widget about the save state change
      if (widget.onSaveStateChanged != null) {
        widget.onSaveStateChanged!(_isSaved);
      }

      // Close the bottom sheet
      Navigator.pop(context);
    } catch (e) {
      // If there's an error, revert the saved state
      setState(() {
        _isSaved = false;
      });

      // Notify parent widget about the save state change
      if (widget.onSaveStateChanged != null) {
        widget.onSaveStateChanged!(_isSaved);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Save to bookmark',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'a-b',
                    color: textTheme.bodyMedium!.color,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const CreateSaveDirectorySheet(),
                    );

                    // Reload directories after creating a new one
                    _loadSaveDirectories();
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 22,
                    color: Color(0xff123fdb),
                  ),
                  label: const Text(
                    'New',
                    style: TextStyle(
                      color: Color(0xff123fdb),
                      fontFamily: 'a-m',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xff123fdb)),
              )
            else if (_directories.isEmpty)
              const Center(
                child: Text(
                  'No bookmark folders found. Create one!',
                  style: TextStyle(
                    fontFamily: 'a-m',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children:
                    _directories.map((directory) {
                      return RadioListTile<String>(
                        title: Text(
                          directory.name,
                          style: const TextStyle(
                            fontFamily: 'a-m',
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Text(
                          '${directory.articleCount} articles',
                          style: const TextStyle(
                            fontFamily: 'a-r',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        value: directory.id,
                        groupValue: _selectedDirectoryId,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedDirectoryId = value;
                          });
                        },
                        activeColor: const Color(0xff123fdb),
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
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
                  child: CupertinoButton(
                    borderRadius: BorderRadius.circular(99),
                    onPressed: _isSaving ? null : _savedArticleHandle,
                    color: const Color(0xff123fdb),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Done',
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
}
