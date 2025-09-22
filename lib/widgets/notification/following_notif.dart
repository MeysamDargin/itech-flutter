import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:itech/screen/pageUser/profile_page.dart';
import 'package:itech/utils/url.dart';

class FollowingNotification extends StatelessWidget {
  final String profileImageUrl;
  final String username;
  final String timeAgo;
  final bool isFollowing;
  final VoidCallback onFollowTap;
  final VoidCallback onTap;
  final VoidCallback onTimeTap;
  final bool isRead;

  const FollowingNotification({
    Key? key,
    required this.profileImageUrl,
    required this.username,
    required this.timeAgo,
    required this.isFollowing,
    required this.onFollowTap,
    required this.onTap,
    required this.onTimeTap,
    this.isRead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfilePage(username: username),
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isRead ? Colors.transparent : const Color(0xffF5F5F5),
          child: Row(
            children: [
              // Profile image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child:
                      profileImageUrl.isNotEmpty
                          ? Image.network(
                            '${ApiAddress.baseUrl}${profileImageUrl}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Image.asset(
                                  "assets/img/44884218_345707102882519_2446069589734326272_n.jpg",
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                ),
                              );
                            },
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.person, color: Colors.grey[600]),
                          ),
                ),
              ),

              const SizedBox(width: 12),

              // Notification text - جدا کردن نام کاربری و متن
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نام کاربری در بالا
                    Text(
                      username,
                      style: TextStyle(
                        fontFamily: 'a-m',
                        fontSize: 17,
                        color: textTheme.bodyMedium!.color,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // متن "started following you" در پایین
                    Text(
                      'started following you',
                      style: TextStyle(
                        fontFamily: 'g-m',
                        fontSize: 17,
                        color: textTheme.bodyMedium!.color,
                      ),
                    ),
                    const SizedBox(height: 4),

                    GestureDetector(
                      onTap: () {
                        onTimeTap();
                      },
                      child: Text(
                        timeAgo,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: 'a-m',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Follow button
              IntrinsicWidth(
                child: Container(
                  height: 36,
                  constraints: BoxConstraints(minWidth: 85),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          isFollowing
                              ? const Color.fromARGB(255, 200, 200, 200)
                              : const Color(0xFF4055FF),
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: CupertinoButton(
                    onPressed: onFollowTap,
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 0),
                    minSize: 36,
                    color: isFollowing ? Colors.white : Color(0xff123fdb),
                    borderRadius: BorderRadius.circular(99),
                    child: Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: isFollowing ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'a-m',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
