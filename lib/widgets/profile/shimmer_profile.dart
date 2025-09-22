import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerProfile extends StatelessWidget {
  const ShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return buildProfileShimmer(context);
  }

  Widget buildProfileShimmer(context) {
    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            // Profile header with background image, profile photo shimmer
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                // Background image shimmer
                Container(
                  height: 240,
                  width: double.infinity,
                  color: Colors.white,
                ),

                // Glass effect stats container shimmer
                Positioned(
                  right: 20,
                  bottom: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Follower stats shimmer
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 18,
                              color: Colors.white,
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        // Following stats shimmer
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 18,
                              color: Colors.white,
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        // Articles stats shimmer
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 18,
                              color: Colors.white,
                            ),
                            SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile avatar shimmer
                Positioned(
                  left: 20,
                  bottom: 25,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            // User info shimmer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name shimmer
                  Container(width: 150, height: 20, color: Colors.white),
                  SizedBox(height: 8),
                  // Bio shimmer (3 lines)
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.white,
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Action buttons shimmer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Row(
                children: [
                  // Edit profile button shimmer
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Share profile button shimmer
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Content shimmer (posts)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(
                  4, // Generate 4 post shimmers
                  (index) => Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post header (user info and date)
                        Row(
                          children: [
                            // User avatar shimmer
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            // SizedBox(width: 12),
                            // User name and date shimmer
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4),
                                Container(
                                  width: 80,
                                  height: 12,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                            // Spacer(),
                            // Options icon shimmer
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(height: 12),
                        // Post content shimmer
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // SizedBox(height: 12),
                        // Post title shimmer
                        Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        // Post description shimmer (2 lines)
                        Container(
                          width: double.infinity,
                          height: 16,
                          color: Colors.white,
                        ),
                        SizedBox(height: 4),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
