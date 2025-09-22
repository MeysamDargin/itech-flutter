import 'package:flutter/material.dart';

class CategorySearch extends StatelessWidget {
  final int selectedCategoryIndex;
  final List<Map<String, dynamic>> categories;
  final Function(int) onCategorySelected;
  final double screenPadding;

  const CategorySearch({
    Key? key,
    required this.selectedCategoryIndex,
    required this.categories,
    required this.onCategorySelected,
    required this.screenPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenPadding),
      child: Row(
        children:
            categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final isSelected = selectedCategoryIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onCategorySelected(index),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < categories.length - 1 ? 8 : 0,
                      left: index > 0 ? 8 : 0,
                    ),
                    height: 45,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF4055FF)
                              : const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF4055FF)
                                : const Color.fromARGB(255, 203, 203, 203),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 15,
                          fontFamily: "a-m",
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
