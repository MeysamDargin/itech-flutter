import 'package:flutter/material.dart';

class ShareProfileBottomSheet extends StatelessWidget {
  const ShareProfileBottomSheet({super.key});

  // تابع نمایش باتم شیت
  void showQRBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xffF4F4F4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // خط بالای باتم شیت
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // تصویر QR کد
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 240,
                  height: 240,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/img/3604523fa3d53d9c017ba476f523b98e.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // نام کاربری
              const SizedBox(height: 20),
              const Text(
                'meysam_dargin',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IR-bold',
                ),
              ),

              // دکمه‌های دانلود و اسکن
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: AssetImage(
                      "assets/icons/download-minimalistic-svgrepo-com.png",
                    ),
                    label: 'دانلود کن',
                    onTap: () {},
                  ),
                  _buildActionButton(
                    icon: AssetImage(
                      "assets/icons/qr-code-scan-svgrepo-com.png",
                    ),
                    label: 'اسکن کن!',
                    onTap: () {},
                  ),
                ],
              ),

              // گزینه‌های کپی و اشتراک‌گذاری
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.copy_outlined),
                      title: const Text(
                        'کپی کن',
                        style: TextStyle(fontFamily: 'IR-bold', fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                      onTap: () {},
                    ),
                    const Divider(height: 2, color: Color(0xffD9D7D7)),
                    ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text(
                        'به اشتراک بگذار',
                        style: TextStyle(fontFamily: 'IR-bold', fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ساخت دکمه‌های اکشن
  Widget _buildActionButton({
    required AssetImage icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(icon),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontFamily: 'IR-r', fontSize: 14),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text(''), backgroundColor: Colors.white),
      body: Center(
        child: ElevatedButton(
          onPressed: () => showQRBottomSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'نمایش QR کد',
            style: TextStyle(fontFamily: 'IR-r', fontSize: 16),
          ),
        ),
      ),
    );
  }
}
