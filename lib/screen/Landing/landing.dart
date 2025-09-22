import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/screen/auth/signing/signing.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xffF8F7F5),
      body: SafeArea(
        child: Column(
          children: [
            // Use a responsive SizedBox for vertical spacing
            SizedBox(
              height:
                  isTablet
                      ? screenSize.height * 0.05
                      : screenSize.height * 0.03,
            ),

            // Use responsive image sizing based on screen width
            Center(
              child: Image.asset(
                "assets/logo/Screenshot_2025-05-11_at_2-new.48.58_PM-removebg-preview (1).png",
                width:
                    isTablet ? screenSize.width * 0.15 : screenSize.width * 0.3,
              ),
            ),

            // Use responsive padding for horizontal spacing
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 13),
              child: Text(
                "Connecting The World, One Story at A Time",
                style: TextStyle(
                  color: const Color(0xff3F3F41),
                  fontFamily: 'a-xb',
                  // Use responsive font size
                  fontSize: isTablet ? 55 : 45,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Use Expanded to make the image take up all available vertical space
            Expanded(
              child: Center(
                child: Image.asset(
                  "assets/img/ChatGPT Image Aug 27, 2025, 11_38_26 AM.png",
                  // Remove the width property so the image can fill the space
                ),
              ),
            ),

            // Use responsive padding for the quote
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 60 : 12),
              child: Text(
                '"In the world of technology, journey from code to culture. Find the connections that bring us together and make the path of innovation global."',
                style: TextStyle(
                  fontFamily: 'sf-m',
                  // Use responsive font size
                  fontSize: isTablet ? 18 : 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Add a SizedBox to create space between the text and the button
            SizedBox(
              height:
                  isTablet
                      ? screenSize.height * 0.03
                      : screenSize.height * 0.02,
            ),

            // Use responsive padding for the button
            CupertinoButton(
              borderRadius: BorderRadius.circular(10),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 150 : 110,
                vertical: isTablet ? 20 : 17,
              ),
              color: const Color(0xFF123fdb),
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white, fontFamily: 'sf-b'),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),

            // Add some bottom padding
            SizedBox(height: isTablet ? 30 : 20),
          ],
        ),
      ),
    );
  }
}
