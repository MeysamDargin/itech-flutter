import 'package:flutter/material.dart';

class ProfileStateColumn extends StatefulWidget {
  final String label;
  final String count;
  const ProfileStateColumn({
    super.key,
    required this.count,
    required this.label,
  });

  @override
  State<ProfileStateColumn> createState() => _ProfileStateColumnState();
}

class _ProfileStateColumnState extends State<ProfileStateColumn> {
  @override
  Widget build(BuildContext context) {
    return buildStatColumn(widget.count, widget.label);
  }

  Widget buildStatColumn(String count, String label) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textTheme.bodyMedium!.color,
            fontFamily: "a-b",
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textTheme.bodyMedium!.color,
            fontFamily: "a-m",
          ),
        ),
      ],
    );
  }
}
