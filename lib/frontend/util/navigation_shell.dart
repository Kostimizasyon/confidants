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

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: _FloatingCapsuleNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              _CapsuleNavItem(
                icon: LucideIcons.grid3x3,
                label: l10n.navKeypad,
              ),
              _CapsuleNavItem(
                icon: LucideIcons.user,
                label: l10n.navProfiles,
              ),
              _CapsuleNavItem(
                icon: LucideIcons.messageSquare,
                label: l10n.navChat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingCapsuleNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_CapsuleNavItem> items;

  const _FloatingCapsuleNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.navBarDark : AppColors.navBarLight;
    final borderColor =
        isDark ? AppColors.navBarBorderDark : AppColors.navBarBorderLight;

    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: _CapsuleTile(
                item: items[i],
                isSelected: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _CapsuleNavItem {
  final IconData icon;
  final String label;

  const _CapsuleNavItem({
    required this.icon,
    required this.label,
  });
}

class _CapsuleTile extends StatelessWidget {
  final _CapsuleNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _CapsuleTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pillColor = isSelected
        ? (isDark ? AppColors.navPillDark : AppColors.navPillLight)
        : AppColors.transparent;

    final textColor = isSelected
        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    final iconColor = textColor;
    final fontWeight = isSelected ? FontWeight.w600 : FontWeight.w500;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 20,
                color: iconColor,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: fontWeight,
                  fontSize: 11.5,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
