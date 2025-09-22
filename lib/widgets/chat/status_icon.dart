import 'package:flutter/material.dart';

class BuildStatusIcon extends StatefulWidget {
  final String sendStatus;
  final bool seen;
  const BuildStatusIcon({
    super.key,
    required this.sendStatus,
    required this.seen,
  });

  @override
  State<BuildStatusIcon> createState() => _BuildStatusIconState();
}

class _BuildStatusIconState extends State<BuildStatusIcon> {
  @override
  Widget build(BuildContext context) {
    return buildStatusIcon(widget.sendStatus, widget.seen);
  }

  Widget buildStatusIcon(String sendStatus, bool seen) {
    if (sendStatus == "sending") {
      // نمایش آیکون ساعت برای در حال ارسال
      return Icon(Icons.access_time, size: 14, color: Color(0xff5DA853));
    } else if (sendStatus == "error") {
      // نمایش آیکون خطا
      return Icon(
        Icons.error_outline,
        size: 14,
        color: Colors.red.withOpacity(0.9),
      );
    } else {
      // نمایش آیکون تیک برای ارسال شده
      return Image(
        image:
            seen
                ? AssetImage("assets/icons/seen-svgrepo-com.png")
                : AssetImage("assets/icons/check-good-yes-svgrepo-com.png"),
        width: seen ? 20 : 15,
        color: Color(0xff5DA853),
      );
    }
  }
}
