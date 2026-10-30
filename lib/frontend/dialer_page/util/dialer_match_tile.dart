import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../util/contact_avatar.dart';
import '../../util/l10n_extensions.dart';

/// A live dialer search result: avatar, name, number, and a quick-call button.
class DialerMatchTile extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onSelect;
  final VoidCallback onCall;

  const DialerMatchTile({
    super.key,
    required this.profile,
    required this.onSelect,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final callColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;
    final name =
        profile.name.trim().isNotEmpty ? profile.name.trim() : l10n.unnamedProfile;

    return ListTile(
      onTap: onSelect,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: ContactAvatar(profile: profile, size: 40),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        profile.phoneNumber.isNotEmpty ? profile.phoneNumber : l10n.noPhoneNumber,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(color: secondaryColor),
      ),
      trailing: profile.phoneNumber.isEmpty
          ? null
          : IconButton(
              onPressed: onCall,
              tooltip: l10n.dialerCallTooltip,
              icon: Icon(LucideIcons.phone, size: 20, color: callColor),
            ),
    );
  }
}
