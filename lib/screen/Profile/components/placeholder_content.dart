import 'package:flutter/material.dart';

class PlaceholderContent extends StatelessWidget {
  final String title;

  const PlaceholderContent({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '$title content coming soon',
              style: TextStyle(
                fontSize: 18,
                fontFamily: "a-m",
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
