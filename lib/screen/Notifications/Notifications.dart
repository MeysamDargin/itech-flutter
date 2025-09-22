import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itech/main.dart';
import 'package:itech/providers/chat/notifications_socket.dart';
import 'package:itech/providers/notifications/notifications_socket_group.dart';
import 'package:itech/service/following/follow_service.dart';
import 'package:itech/widgets/notification/comment_create_notig.dart';
import 'package:itech/widgets/notification/comment_reply_notig.dart';
import 'package:itech/widgets/notification/following_notif.dart';
import 'package:itech/widgets/notification/like_notif.dart';
import 'package:itech/widgets/notification/new_article_notif.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  Timer? _timeUpdateTimer;

  @override
  void initState() {
    super.initState();
    // Request notifications when page loads
    Future.delayed(Duration.zero, () {
      final notificationsManager = Provider.of<NotificationsProvider>(
        context,
        listen: false,
      );
      notificationsManager.requestNotifications();
      final notificationsGroupManager = Provider.of<NotificationsGroupProvider>(
        context,
        listen: false,
      );
      notificationsGroupManager.requestNotifications();
    });

    // Update time display every 5 minutes
    _timeUpdateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  // Helper method to format time ago with real-time calculation
  DateTime _parseToLocalTime(String dateTimeStr) {
    try {
      // اگه رشته `Z` نداره، اضافه کن
      if (!dateTimeStr.endsWith('Z')) {
        dateTimeStr = '${dateTimeStr}Z';
      }

      final dateTime = DateTime.parse(dateTimeStr);
      return dateTime.toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  // Helper method to format time ago with real-time calculation using local time
  String formatTimeAgo(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return '';

    try {
      final dateTime = _parseToLocalTime(dateTimeStr);
      final now = DateTime.now(); // This is already in local time
      final difference = now.difference(dateTime);

      // کمتر از ۱ دقیقه
      if (difference.inSeconds < 60) {
        return 'Now';
      }

      // کمتر از ۱ ساعت - نمایش دقیقه
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      }

      // کمتر از ۲۴ ساعت - نمایش ساعت
      if (difference.inHours < 24) {
        return '${difference.inHours}  hours ago';
      }

      // یک روز
      if (difference.inDays == 1) {
        return 'Yesterday';
      }

      // کمتر از ۷ روز - نمایش روز
      if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      }

      // کمتر از ۳۰ روز - نمایش هفته
      if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        if (weeks == 1) {
          return 'week ago';
        }
        return '$weeks weeks ago';
      }

      // کمتر از ۳۶۵ روز - نمایش ماه
      if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        if (months == 1) {
          return 'month ago';
        }
        return '$months month ago';
      }

      // بیش از یک سال
      final years = (difference.inDays / 365).floor();
      if (years == 1) {
        return 'year ago';
      }
      return '$years years ago';
    } catch (e) {
      return '';
    }
  }

  // همچنین می‌تونی این متد رو برای نمایش Dialog استفاده کنی:
  void showDetailedTime(BuildContext context, String dateTimeStr) {
    final localTime = _parseToLocalTime(dateTimeStr);
    final formattedTime =
        '${localTime.year}/${localTime.month}/${localTime.day} '
        '${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Time Details', style: TextStyle(fontFamily: 'g-m')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTimeAgo(dateTimeStr),
                  style: TextStyle(fontFamily: 'a-r', fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  formattedTime,
                  style: TextStyle(fontFamily: 'a-r', fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ok', style: TextStyle(fontFamily: 'a-m')),
              ),
            ],
          ),
    );
  }

  // Group notifications by time period using local time
  Map<String, List<dynamic>> _groupNotificationsByTime(
    List<dynamic> notifications,
  ) {
    final now = DateTime.now(); // زمان محلی فعلی
    final Map<String, List<dynamic>> grouped = {
      'Today': [],
      'This Week': [],
      'This Month': [],
      'Older': [],
    };

    for (var notification in notifications) {
      try {
        final localDateTime = _parseToLocalTime(
          notification['created_at'] ?? '',
        );
        final difference = now.difference(localDateTime);

        if (difference.inHours < 24) {
          grouped['Today']!.add(notification);
        } else if (difference.inDays < 7) {
          grouped['This Week']!.add(notification);
        } else if (difference.inDays < 30) {
          grouped['This Month']!.add(notification);
        } else {
          grouped['Older']!.add(notification);
        }
      } catch (e) {
        grouped['Today']!.add(
          notification,
        ); // Default to today if date parsing fails
      }
    }

    return grouped;
  }

  // Helper method to check if user is being followed
  bool isUserFollowing(dynamic userId) {
    // Replace with actual implementation that checks if the user is being followed
    // For now, return false as placeholder
    return false;
  }

  // ✅ Fixed toggle follow with optimistic UI update
  Future<void> _toggleFollow(dynamic userId, int index) async {
    final notificationsManager = Provider.of<NotificationsProvider>(
      context,
      listen: false,
    );

    print("Toggle follow called for userId: $userId, index: $index");

    // ذخیره وضعیت فعلی
    final originalStatus = notificationsManager.getFollowStatus(index);
    print("Original status: $originalStatus");

    // ✅ اول UI رو تغییر بده (Optimistic Update)
    notificationsManager.updateFollowStatus(index, !originalStatus);
    print("UI updated to: ${!originalStatus}");

    try {
      // ارسال درخواست به سرور
      final response = await FollowService.followService(userId.toString());
      print("Server response: $response");

      if (response['status'] != 'success') {
        // شکست - بازگشت به وضعیت قبل
        notificationsManager.updateFollowStatus(index, originalStatus);
        print("Request failed, reverted to: $originalStatus");

        // نمایش پیام خطا (اختیاری)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update follow status'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print("Follow status updated successfully");
      }
    } catch (e) {
      print("Error occurred: $e");
      // خطا - بازگشت به وضعیت قبل
      notificationsManager.updateFollowStatus(index, originalStatus);

      // نمایش پیام خطا
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error occurred'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Safe method to extract data from target_id
  String _safeExtractFromTarget(
    dynamic targetId,
    String key, {
    String defaultValue = '',
  }) {
    if (targetId is Map<String, dynamic>) {
      return targetId[key]?.toString() ?? defaultValue;
    }
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    final notificationsManager = Provider.of<NotificationsProvider>(context);
    final notificationsGroupManager = Provider.of<NotificationsGroupProvider>(
      context,
    );
    final iconColor = Theme.of(context).extension<IconColors>()!;

    final unreadCount = notificationsManager.unreadCount;
    final notifications =
        notificationsManager.notifications
            .map((n) => {...n, 'source': 'regular'})
            .toList();
    final unreadCountgroup = notificationsGroupManager.unreadCount;
    final notificationsGroup =
        notificationsGroupManager.notifications
            .map((n) => {...n, 'source': 'group'})
            .toList();

    // Combine notifications
    final allNotifications = [...notifications, ...notificationsGroup];

    // Group notifications by time period
    final groupedNotifications = _groupNotificationsByTime(allNotifications);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications${(unreadCount + unreadCountgroup) > 0 ? ' (${unreadCount + unreadCountgroup})' : ''}",
          style: TextStyle(fontFamily: 'a-m', fontSize: 22),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              "assets/icons/setting-2-svgrepo-com.png",
              width: 25,
              height: 25,
              color: iconColor.iconColor,
            ),
          ),
        ],
      ),
      body:
          allNotifications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animation/Empty Notifications (1).json',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                    ),
                    Text(
                      'Empty',
                      style: TextStyle(
                        fontFamily: 'g-b',
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No notifications',
                      style: TextStyle(fontFamily: 'a-m', fontSize: 16),
                    ),
                  ],
                ),
              )
              : ListView(
                children: [
                  // Build each time section
                  for (var timeSection in groupedNotifications.entries)
                    if (timeSection.value.isNotEmpty) ...[
                      // Section header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          timeSection.key,
                          style: TextStyle(
                            fontFamily: 'a-m',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      // Section notifications
                      ...timeSection.value.asMap().entries.map((entry) {
                        final localIndex = entry.key;
                        final notification = entry.value;
                        final globalIndex = allNotifications.indexOf(
                          notification,
                        );

                        if (notification['type'] == 'follow') {
                          return FollowingNotification(
                            profileImageUrl:
                                notification['actor_profile_img'] ?? '',
                            username: notification['actor_username'] ?? '',
                            timeAgo: formatTimeAgo(
                              notification['created_at'] ?? '',
                            ),
                            isFollowing:
                                notification['is_mutual_follow'] ?? false,
                            onFollowTap: () {
                              _toggleFollow(
                                notification['actor_id'],
                                globalIndex,
                              );
                            },
                            onTap: () {
                              final notificationId =
                                  notification['notification_id'];
                              if (notificationId != null) {
                                // Mark notification as read using appropriate provider
                                if (notification['source'] == 'regular') {
                                  notificationsManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                } else {
                                  notificationsGroupManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                }
                              }
                            },
                            onTimeTap: () {
                              showDetailedTime(
                                context,
                                notification['created_at'] ?? '',
                              );
                            },
                            isRead: notification['read'] ?? false,
                          );
                        }

                        if (notification['type'] == 'like') {
                          final target = notification['target_id'];
                          final articleId =
                              target != null &&
                                      target is Map &&
                                      target['id'] != null
                                  ? target['id'].toString()
                                  : '';
                          final extra_data = notification['extra_data'] ?? {};
                          final articleCover =
                              extra_data['article_img_cover'] ?? '';

                          return LikeArticleNotification(
                            profileImageUrl:
                                notification['actor_profile_img'] ?? '',
                            username: notification['actor_username'] ?? '',
                            timeAgo: formatTimeAgo(
                              notification['created_at'] ?? '',
                            ),
                            articleId: articleId,
                            articleCover: articleCover,
                            onTap: () {
                              final notificationId =
                                  notification['notification_id'];
                              if (notificationId != null) {
                                if (notification['source'] == 'regular') {
                                  notificationsManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                } else {
                                  notificationsGroupManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                }
                              }
                            },
                            onTimeTap: () {
                              showDetailedTime(
                                context,
                                notification['created_at'] ?? '',
                              );
                            },
                            isRead: notification['read'] ?? false,
                          );
                        }

                        if (notification['type'] == 'comment_create') {
                          final target = notification['target_id'];
                          final articleId =
                              target != null &&
                                      target is Map &&
                                      target['article_id'] != null
                                  ? target['article_id'].toString()
                                  : '';
                          final commentId =
                              target != null && target is Map
                                  ? target['id']?.toString() ?? ''
                                  : '';
                          final extra_data = notification['extra_data'] ?? {};
                          final articleCover =
                              extra_data['article_img_cover'] ?? '';
                          final commentText = extra_data['comment'] ?? '';

                          return CommentCreateNotification(
                            profileImageUrl:
                                notification['actor_profile_img'] ?? '',
                            username: notification['actor_username'] ?? '',
                            timeAgo: formatTimeAgo(
                              notification['created_at'] ?? '',
                            ),
                            commentId: commentId,
                            articleId: articleId,
                            articleCover: articleCover,
                            commentText: commentText,
                            onTap: () {
                              final notificationId =
                                  notification['notification_id'];
                              if (notificationId != null) {
                                if (notification['source'] == 'regular') {
                                  notificationsManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                } else {
                                  notificationsGroupManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                }
                              }
                            },
                            onTimeTap: () {
                              showDetailedTime(
                                context,
                                notification['created_at'] ?? '',
                              );
                            },
                            isRead: notification['read'] ?? false,
                          );
                        }

                        if (notification['type'] == 'comment_reply') {
                          final target = notification['target_id'];
                          final articleId =
                              target != null &&
                                      target is Map &&
                                      target['article_id'] != null
                                  ? target['article_id'].toString()
                                  : '';
                          final new_comment_id =
                              target != null && target is Map
                                  ? target['new_comment']?.toString() ?? ''
                                  : '';
                          final extra_data = notification['extra_data'] ?? {};
                          final articleCover =
                              extra_data['article_img_cover'] ?? '';
                          final commentText = extra_data['comment'] ?? '';

                          return CommentReplyNotification(
                            profileImageUrl:
                                notification['actor_profile_img'] ?? '',
                            username: notification['actor_username'] ?? '',
                            timeAgo: formatTimeAgo(
                              notification['created_at'] ?? '',
                            ),
                            articleId: articleId,
                            articleCover: articleCover,
                            commentText: commentText,
                            new_comment_id: new_comment_id,
                            onTap: () {
                              final notificationId =
                                  notification['notification_id'];
                              if (notificationId != null) {
                                if (notification['source'] == 'regular') {
                                  notificationsManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                } else {
                                  notificationsGroupManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                }
                              }
                            },
                            onTimeTap: () {
                              showDetailedTime(
                                context,
                                notification['created_at'] ?? '',
                              );
                            },
                            isRead: notification['read'] ?? false,
                          );
                        }

                        if (notification['type'] == 'new_article') {
                          var target = notification['target_id'];
                          String articleId = '';
                          if (target is Map<String, dynamic> &&
                              target['article_id'] != null) {
                            articleId = target['article_id'].toString();
                          } else if (target != null) {
                            // If target is not a map (e.g., int or string), use it directly as articleId
                            articleId = target.toString();
                          }
                          final extra_data = notification['extra_data'] ?? {};
                          final articleCover = extra_data['imgCover'] ?? '';
                          final articleTitle = extra_data['title'] ?? '';

                          return NewArticleNotification(
                            profileImageUrl:
                                notification['actor_profile_img'] ?? '',
                            username: notification['actor_username'] ?? '',
                            timeAgo: formatTimeAgo(
                              notification['created_at'] ?? '',
                            ),
                            articleId: articleId,
                            articleCover: articleCover,
                            articleTitle: articleTitle,
                            onTap: () {
                              final notificationId =
                                  notification['notification_id'];
                              if (notificationId != null) {
                                if (notification['source'] == 'regular') {
                                  notificationsManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                } else {
                                  notificationsGroupManager.markAsRead(
                                    notificationId.toString(),
                                  );
                                }
                              }
                            },
                            onTimeTap: () {
                              showDetailedTime(
                                context,
                                notification['created_at'] ?? '',
                              );
                            },
                            isRead: notification['read'] ?? false,
                          );
                        }

                        // Default notification item for other types
                        return ListTile(
                          title: Text(notification['type'] ?? 'Notification'),
                          subtitle: Text(
                            formatTimeAgo(notification['created_at'] ?? ''),
                          ),
                        );
                      }).toList(),
                    ],
                ],
              ),
      floatingActionButton:
          allNotifications.isNotEmpty && (unreadCount + unreadCountgroup) > 0
              ? FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 66, 33, 255),
                onPressed: () {
                  notificationsManager.markAllAsRead();
                  notificationsGroupManager.markAllAsRead();
                },
                child: Icon(Icons.done_all, color: Colors.white),
                tooltip: 'Mark all as read',
              )
              : null,
    );
  }
}
