import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:itech/main.dart';
import 'package:itech/widgets/profile/logout_sheet.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool _isDarkModeEnabled = false;
  void _showCreateFeedbackSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogoutSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).extension<IconColors>()!;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontFamily: "a-m",
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textTheme.bodyMedium!.color,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: iconColor.iconColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: colorScheme.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // General Section
              const Padding(
                padding: EdgeInsets.only(top: 12.0, bottom: 8.0),
                child: Text(
                  'General',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: "a-m",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Customize Interests
              _buildSettingItem(
                iconAsset: "assets/icons/grid-4-svgrepo-com.png",
                title: 'Customize Interests',
                onTap: () {},
                showDivider: true,
              ),

              // Personal Info
              _buildSettingItem(
                iconAsset: "assets/icons/profile-svgrepo-com.png",
                title: 'Personal Info',
                onTap: () {},
                showDivider: true,
              ),

              // Notification
              _buildSettingItem(
                iconAsset: "assets/icons/notification-bell-svgrepo-com.png",
                title: 'Notification',
                onTap: () {},
                showDivider: true,
              ),

              // Security
              _buildSettingItem(
                iconAsset: "assets/icons/security-svgrepo-com.png",
                title: 'Security',
                onTap: () {},
                showDivider: true,
              ),

              // Language
              _buildSettingItem(
                iconAsset: "assets/icons/translate-svgrepo-com.png",
                title: 'Language',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'English (US)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontFamily: "a-m",
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ],
                ),
                onTap: () {},
                showDivider: true,
              ),

              // Dark Mode
              _buildSettingItemWithSwitch(
                iconAsset: "assets/icons/eye-svgrepo-com.png",
                title: 'Dark Mode',
                value: _isDarkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _isDarkModeEnabled = value;
                  });
                },
              ),

              // About Section
              const Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
                child: Text(
                  'About',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: "a-m",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Follow us on Social Media
              _buildSettingItem(
                iconAsset: "assets/icons/at-email-svgrepo-com.png",
                title: 'Follow us on Social Media',
                onTap: () {},
                showDivider: true,
              ),

              // Help Center
              _buildSettingItem(
                iconAsset: "assets/icons/document-text-svgrepo-com.png",
                title: 'Help Center',
                onTap: () {},
                showDivider: true,
              ),

              // Privacy Policy
              _buildSettingItem(
                iconAsset: "assets/icons/lock-password-svgrepo-com.png",
                title: 'Privacy Policy',
                onTap: () {},
                showDivider: true,
              ),

              // About Newsline
              _buildSettingItem(
                iconAsset:
                    "assets/icons/about-description-help-svgrepo-com.png",
                title: 'About Newsline',
                onTap: () {},
                showDivider: false,
              ),

              const SizedBox(height: 12),

              // Logout
              InkWell(
                onTap: _showCreateFeedbackSheet,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      ImageIcon(
                        const AssetImage(
                          "assets/icons/logout-2-svgrepo-com.png",
                        ),
                        color: Colors.red[400],
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "a-m",
                          color: Colors.red[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String iconAsset,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    bool showDivider = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).extension<IconColors>()!;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                ImageIcon(
                  AssetImage(iconAsset),
                  color: iconColor.iconColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "a-m",
                    color: textTheme.bodyMedium!.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                trailing ??
                    Image.asset(
                      "assets/icons/chevron-right-svgrepo-com.png",
                      color: iconColor.iconColor,
                      width: 22,
                      height: 22,
                    ),
              ],
            ),
          ),
        ),
        // if (showDivider)
        //   Divider(color: Colors.grey.withOpacity(0.1), height: 1),
      ],
    );
  }

  Widget _buildSettingItemWithSwitch({
    required String iconAsset,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).extension<IconColors>()!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              ImageIcon(
                AssetImage(iconAsset),
                color: iconColor.iconColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "a-m",
                  color: textTheme.bodyMedium!.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              CupertinoSwitch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
                activeColor: Color(0xFF123fdb),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.withOpacity(0.1), height: 1),
      ],
    );
  }
}
