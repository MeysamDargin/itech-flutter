import 'dart:ui';
import 'package:flutter/material.dart';

class ShowCategory extends StatefulWidget {
  String categoryName;
  ShowCategory({super.key, required this.categoryName});

  @override
  State<ShowCategory> createState() => _ShowCategoryState();
}

class _ShowCategoryState extends State<ShowCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: GradientShadowBox(
              child: Center(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 102, 0).withOpacity(0.8),
                        Color.fromARGB(255, 0, 26, 255).withOpacity(0.8),
                        Color.fromARGB(255, 94, 99, 255).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    "${widget.categoryName}",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'a-xb',
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 70),
          Text(
            "This is article about ${widget.categoryName} category",
            style: TextStyle(fontFamily: 'a-m', fontSize: 17),
          ),
        ],
      ),
    );
  }
}

class GradientShadowBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blurStrength;
  final double spread;

  const GradientShadowBox({
    super.key,
    required this.child,
    this.radius = 25,
    this.blurStrength = 30,
    this.spread = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // لایه سایه گرادینتی
        Positioned(
          left: -spread,
          right: -spread,
          top: -spread,
          bottom: -spread,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurStrength,
              sigmaY: blurStrength,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius + spread),
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(122, 255, 170, 0),
                    Color.fromARGB(103, 0, 170, 255),
                    Color.fromARGB(126, 49, 118, 255),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        // لایه محتوای اصلی
        child,
      ],
    );
  }
}
