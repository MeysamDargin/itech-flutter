import 'package:flutter/material.dart';

class BuildEmptyChat extends StatefulWidget {
  const BuildEmptyChat({super.key});

  @override
  State<BuildEmptyChat> createState() => _BuildEmptyChatState();
}

class _BuildEmptyChatState extends State<BuildEmptyChat> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(207, 228, 228, 228),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Write your first comment on this article!",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'a-m',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
