import 'package:flutter/material.dart';
import 'package:itech/main.dart';
import 'package:itech/screen/Article/create/create_article.dart';
import 'package:itech/screen/Notifications/Notifications.dart';
import 'package:itech/screen/Search/search.dart';
import 'package:provider/provider.dart';
import 'package:itech/providers/chat/notifications_socket.dart';

class TopNavigationBar extends StatelessWidget {
  final double screenPadding;

  const TopNavigationBar({Key? key, required this.screenPadding})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = Theme.of(context).extension<IconColors>()!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenPadding, vertical: 10),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateArticle()),
                  );
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.background,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: iconColor.iconColor,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 53,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: colorScheme.background,
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Search()),
                          );
                        },
                        borderRadius: BorderRadius.circular(25),
                        child: Center(
                          child: ImageIcon(
                            AssetImage("assets/icons/search-svgrepo-com.png"),
                            color: iconColor.iconColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Notifications(),
                          ),
                        );
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: colorScheme.background,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Consumer<NotificationsProvider>(
                            builder: (context, notificationsManager, child) {
                              final unreadCount =
                                  notificationsManager.unreadCount;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  ImageIcon(
                                    AssetImage(
                                      "assets/icons/notification-bell-svgrepo-com.png",
                                    ),
                                    color: iconColor.iconColor,
                                    size: 25,
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      top: 2,
                                      right: 6,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
