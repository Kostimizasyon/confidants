import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../chat_page/chat_page.dart';
import '../dialer_page/dialer_page.dart';
import '../profiles_page/profiles_page.dart';
import '../theme/app_colors.dart';
import 'l10n_extensions.dart';

/// Bottom tabs, left to right: Keypad, Profiles, AI Chat.
/// Settings lives in the top-right of each tab's [CustomAppBar].
class NavigationShell extends StatefulWidget {
  final int initialIndex;

  const NavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  const NavigationShell.dialer({super.key}) : initialIndex = 0;

  const NavigationShell.profiles({super.key}) : initialIndex = 1;

  const NavigationShell.chat({super.key}) : initialIndex = 2;

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  late int _currentIndex;

  static const List<Widget> _tabs = [
    DialerPage(),
    ProfilesPage(),
    ChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      // SafeArea keeps the tab bar clear of Android 3-button navigation.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(LucideIcons.grid3x3),
                activeIcon: const Icon(LucideIcons.phone),
                label: l10n.navKeypad,
              ),
              BottomNavigationBarItem(
                icon: const Icon(LucideIcons.users),
                activeIcon: const Icon(LucideIcons.userCheck),
                label: l10n.navProfiles,
              ),
              BottomNavigationBarItem(
                icon: const Icon(LucideIcons.messageSquare),
                activeIcon: const Icon(LucideIcons.messageSquareDot),
                label: l10n.navChat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
