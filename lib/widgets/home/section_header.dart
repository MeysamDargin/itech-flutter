import 'package:flutter/material.dart';

class BuildSectionHeader extends StatefulWidget {
  final double? horizontalPadding; // نوع اختیاری
  final double? viewAllPadding; // نوع اختیاری
  final String? title; // نوع اختیاری
  const BuildSectionHeader({
    super.key,
    this.horizontalPadding = 0.0, // مقدار پیش‌فرض به double تبدیل شد
    this.title = "", // مقدار پیش‌فرض خالی
    this.viewAllPadding = 0.0,
  });

  @override
  State<BuildSectionHeader> createState() => _BuildSectionHeaderState();
}

class _BuildSectionHeaderState extends State<BuildSectionHeader> {
  @override
  Widget build(BuildContext context) {
    return buildSectionHeader(
      widget.horizontalPadding,
      widget.title,
      widget.viewAllPadding,
    );
  }

  Widget buildSectionHeader(
    double? horizontalPadding,
    String? title,
    double? viewAllPadding,
  ) {
    // مدیریت نال بودن با مقادیر پیش‌فرض
    final effectivePadding = horizontalPadding ?? 0.0;
    final effectiveTitle = title ?? "";
    final textTheme = Theme.of(context).textTheme;

    // اطمینان از اینکه پدینگ منفی نشود
    final safePadding = effectivePadding > 0 ? effectivePadding : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: safePadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            effectiveTitle,
            style: TextStyle(
              fontSize: effectiveTitle == "Breaking News" ? 22 : 18,
              fontWeight: FontWeight.bold,
              fontFamily: "a-r",
              color: textTheme.bodyMedium!.color,
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(right: viewAllPadding!),
            child: GestureDetector(
              onTap: () {
                // می‌توانید اینجا منطق "Show More" را پیاده‌سازی کنید
                print("Show More clicked for: $effectiveTitle");
              },
              child: Text(
                "View All",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "a-m",
                  color: Color(0xFF4055FF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
