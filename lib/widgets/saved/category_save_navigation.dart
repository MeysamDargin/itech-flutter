import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itech/main.dart';
import 'dart:ui';
import 'package:itech/widgets/saved/edit_save_directory.dart';
import 'package:itech/service/saved/delete_category_service.dart';
import 'package:itech/utils/save/fach_save_directory.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// Custom Glassmorphism Widget
class GlassMorphism extends StatelessWidget {
  const GlassMorphism({
    Key? key,
    required this.child,
    required this.blur,
    required this.opacity,
    required this.color,
    this.borderRadius,
  }) : super(key: key);
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class CategorySaveNavigation extends StatefulWidget {
  final int selectedCategoryIndex;
  final List<Map<String, dynamic>> categories;
  final Function(int) onCategorySelected;
  final double screenPadding;

  const CategorySaveNavigation({
    Key? key,
    required this.selectedCategoryIndex,
    required this.categories,
    required this.onCategorySelected,
    required this.screenPadding,
  }) : super(key: key);

  @override
  State<CategorySaveNavigation> createState() => _CategorySaveNavigationState();
}

class _CategorySaveNavigationState extends State<CategorySaveNavigation>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _showOptionsMenu(BuildContext context, int index, Offset position) {
    // اگر منو باز است، آن را ببند
    if (_overlayEntry != null) {
      _closeMenu();
      return;
    }

    // بازخورد هپتیک پیشرفته
    HapticFeedback.mediumImpact();

    print(
      "Showing menu at position: $position for category: ${widget.categories[index]['name']}",
    );

    // ساخت منو
    _overlayEntry = _createOverlayEntry(context, index, position);

    // اطمینان از وجود Overlay
    final overlay = Overlay.of(context);
    if (overlay != null) {
      overlay.insert(_overlayEntry!);
      _controller.forward();
    } else {
      print("Overlay is null");
    }
  }

  void _closeMenu() {
    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  OverlayEntry _createOverlayEntry(
    BuildContext context,
    int index,
    Offset position,
  ) {
    // اندازه صفحه
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;

    // اطمینان از اینکه منو در محدوده صفحه نمایش باشد
    final double menuWidth = 160.0;
    final double menuHeight = 120.0;

    double left = position.dx - (menuWidth / 2);
    if (left < 10) left = 10;
    if (left > screenSize.width - menuWidth - 10)
      left = screenSize.width - menuWidth - 10;

    // محاسبه فضای باقیمانده در پایین موقعیت کلیک
    final bottomSpace = screenHeight - position.dy - 50;

    // تصمیم‌گیری برای باز شدن منو به سمت بالا یا پایین
    final showBelow = bottomSpace >= menuHeight || position.dy < menuHeight;

    return OverlayEntry(
      builder:
          (context) => Stack(
            children: [
              // لایه پس‌زمینه برای بستن منو با کلیک
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeMenu,
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              ),
              // منو
              Positioned(
                left: left,
                // اگر فضای کافی در پایین نباشد، منو را بالای موقعیت کلیک نمایش بده
                top: showBelow ? position.dy + 10 : null,
                bottom: !showBelow ? screenHeight - position.dy + 10 : null,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: GlassMorphism(
                      blur: 15,
                      opacity: 0.7,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: menuWidth,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // گزینه ویرایش
                              _buildMenuItem(
                                icon: AssetImage(
                                  "assets/icons/edit-1-svgrepo-com (1).png",
                                ),
                                text: 'Edit',
                                onTap: () {
                                  _closeMenu();
                                  _handleEditCategory(index);
                                },
                              ),
                              // گزینه حذف
                              _buildMenuItem(
                                icon: AssetImage(
                                  "assets/icons/delete-f-svgrepo-com.png",
                                ),
                                text: 'Delete',
                                color: Color.fromARGB(255, 255, 52, 52),
                                onTap: () {
                                  _closeMenu();
                                  _handleDeleteCategory(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildMenuItem({
    required AssetImage icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Image(
                image: icon,
                width: 20,
                height: 20,
                color: color ?? Colors.black87,
              ),
              SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Outfit-Medium",
                  color: color ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleEditCategory(int index) {
    // Get the directory ID and name
    final directoryId = widget.categories[index]['id'];
    final currentName = widget.categories[index]['name'];

    print('Editing category: $currentName (ID: $directoryId)');

    // Show the edit bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => EditSaveDirectorySheet(
            directoryId: directoryId,
            currentName: currentName,
            onDirectoryUpdated: (newName) {
              // Update the category name in the UI
              setState(() {
                widget.categories[index]['name'] = newName;
              });

              print('Category updated: $newName');
            },
          ),
    );
  }

  void _handleDeleteCategory(int index) {
    // Get the directory ID and name
    final directoryId = widget.categories[index]['id'];
    final directoryName = widget.categories[index]['name'];

    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Delete Collection',
              style: TextStyle(fontFamily: 'a-b', fontSize: 18),
            ),
            content: Text(
              'Are you sure you want to delete "$directoryName"? This action cannot be undone.',
              style: TextStyle(fontFamily: 'a-r', fontSize: 14),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'a-m', color: Colors.grey[700]),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Close the dialog
                  Navigator.pop(context);

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (BuildContext dialogContext) => Center(
                          child: CircularProgressIndicator(
                            color: Color(0xff123fdb),
                          ),
                        ),
                  );

                  try {
                    print("Deleting directory: $directoryId - $directoryName");

                    // Delete the directory
                    final DeleteCategoryService deleteService =
                        DeleteCategoryService();
                    final response = await deleteService.deleteSaveDirectory(
                      directoryId: directoryId,
                    );

                    print("Delete response: $response");

                    // Make sure to close the loading dialog
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                      print("Loading dialog closed");
                    } else {
                      print("Cannot pop loading dialog");
                    }

                    if (response != null && response['status'] == 'success') {
                      print("Delete successful, updating UI");

                      // Remove the category from the list immediately
                      setState(() {
                        // Store the current selected index
                        int currentSelectedIndex = widget.selectedCategoryIndex;

                        // Remove the category from the local list
                        final deletedCategory = widget.categories.removeAt(
                          index,
                        );
                        print(
                          "Removed category from UI: ${deletedCategory['name']}",
                        );

                        // Adjust the selected index if needed
                        if (currentSelectedIndex == index) {
                          // If the deleted category was selected, select "All" (index 0)
                          widget.onCategorySelected(0);
                          print(
                            "Selected category was deleted, selecting 'All' instead",
                          );
                        } else if (currentSelectedIndex > index) {
                          // If the deleted category is before the selected one, adjust the index
                          widget.onCategorySelected(currentSelectedIndex - 1);
                          print(
                            "Adjusted selected index from $currentSelectedIndex to ${currentSelectedIndex - 1}",
                          );
                        }
                      });

                      // Refresh the categories list from server in the background
                      fetchAndParseCategoryList();
                      print("Refreshing categories list from server");

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Success',
                            message: 'Collection deleted successfully',
                            contentType: ContentType.success,
                          ),
                        ),
                      );
                    } else {
                      print("Delete failed: ${response?['message']}");

                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          elevation: 0,
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.transparent,
                          content: AwesomeSnackbarContent(
                            title: 'Error',
                            message:
                                'Failed to delete collection. Please try again.',
                            contentType: ContentType.failure,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    print("Exception during delete: $e");

                    // Make sure to close the loading dialog
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                      print("Loading dialog closed after exception");
                    } else {
                      print("Cannot pop loading dialog after exception");
                    }

                    // Show error message
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
                  }
                },
                child: Text(
                  'Delete',
                  style: TextStyle(fontFamily: 'a-m', color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final categoryBorderColor =
        Theme.of(context).extension<CategoryBorderColors>()!;
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: widget.screenPadding),
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          final isSelected = widget.selectedCategoryIndex == index;

          // برای هر آیتم یک کلید منحصر به فرد ایجاد می‌کنیم
          final itemKey = GlobalKey();

          return Container(
            key: itemKey,
            margin: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onCategorySelected(index),
                onLongPress: () {
                  print(
                    "Long press detected on category: ${widget.categories[index]['name']}",
                  );

                  // بازخورد هپتیک قوی‌تر
                  HapticFeedback.heavyImpact();

                  // پیدا کردن موقعیت آیتم با استفاده از کلید
                  final RenderBox? renderBox =
                      itemKey.currentContext?.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    final size = renderBox.size;
                    final position = renderBox.localToGlobal(
                      Offset(size.width / 2, size.height / 2),
                    );
                    _showOptionsMenu(context, index, position);
                  } else {
                    print(
                      "RenderBox is null for category: ${widget.categories[index]['name']}",
                    );
                  }
                },
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF4055FF)
                            : colorScheme.background,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFF4055FF)
                              : categoryBorderColor.categoryBorderColor!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.categories[index]['name'],
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : textTheme.bodyMedium!.color,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                          fontFamily: "a-m",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
