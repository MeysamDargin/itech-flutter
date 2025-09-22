import 'package:flutter/material.dart';
import 'package:itech/main.dart';

class CategoryNavigation extends StatelessWidget {
  final int selectedCategoryIndex;
  final List<Map<String, dynamic>> categories;
  final Function(int) onCategorySelected;
  final double screenPadding;

  const CategoryNavigation({
    Key? key,
    required this.selectedCategoryIndex,
    required this.categories,
    required this.onCategorySelected,
    required this.screenPadding,
  }) : super(key: key);

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
        padding: EdgeInsets.symmetric(horizontal: screenPadding),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategoryIndex == index;
          final hasIcon = categories[index].containsKey('icon');

          return GestureDetector(
            onTap: () => onCategorySelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    categories[index]['name'],
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
          );
        },
      ),
    );
  }
}
