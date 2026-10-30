import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/call_entry.dart';
import '../../theme/app_colors.dart';
import '../../util/contact_avatar.dart';
import '../../util/l10n_extensions.dart';

class CallLogTile extends StatelessWidget {
  final CallEntry entry;
  final VoidCallback onCall;
  final VoidCallback onTap;

  const CallLogTile({
    super.key,
    required this.entry,
    required this.onCall,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final isMissed = entry.type == CallType.missed ||
        entry.type == CallType.rejected ||
        entry.type == CallType.blocked;

    final title = entry.displayTitle.isNotEmpty
        ? entry.displayTitle
        : (entry.number.isNotEmpty ? entry.number : l10n.unnamedProfile);

    final showSubtitleNumber =
        entry.matchedConfidant != null && entry.number.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 0.6),
          ),
        ),
        child: Row(
          children: [
            if (entry.matchedConfidant != null)
              ContactAvatar(profile: entry.matchedConfidant!, size: 44)
            else
              _buildDefaultAvatar(context, isDark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isMissed
                          ? AppColors.error
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _buildTypeIcon(context),
                      const SizedBox(width: 5),
                      Text(
                        _getTypeLabel(l10n),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isMissed ? AppColors.error : secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' • ${_formatTimestamp(context, entry.timestamp)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (showSubtitleNumber) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.number,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: secondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onCall,
              tooltip: l10n.callNowTooltip(title),
              icon: const Icon(
                LucideIcons.phone,
                size: 20,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context, bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        LucideIcons.user,
        size: 20,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      ),
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    switch (entry.type) {
      case CallType.incoming:
        return const Icon(
          LucideIcons.phoneIncoming,
          size: 14,
          color: AppColors.success,
        );
      case CallType.outgoing:
        return const Icon(
          LucideIcons.phoneOutgoing,
          size: 14,
          color: AppColors.accentHighlight,
        );
      case CallType.missed:
        return const Icon(
          LucideIcons.phoneMissed,
          size: 14,
          color: AppColors.error,
        );
      case CallType.rejected:
      case CallType.blocked:
        return const Icon(
          LucideIcons.phoneOff,
          size: 14,
          color: AppColors.error,
        );
      case CallType.unknown:
        return const Icon(
          LucideIcons.phone,
          size: 14,
          color: AppColors.accentHighlight,
        );
    }
  }

  String _getTypeLabel(dynamic l10n) {
    switch (entry.type) {
      case CallType.incoming:
        return l10n.callTypeIncoming;
      case CallType.outgoing:
        return l10n.callTypeOutgoing;
      case CallType.missed:
        return l10n.callTypeMissed;
      case CallType.rejected:
        return l10n.callTypeRejected;
      case CallType.blocked:
        return l10n.callTypeBlocked;
      case CallType.unknown:
        return '';
    }
  }

  String _formatTimestamp(BuildContext context, DateTime dt) {
    final now = DateTime.now();
    final isToday =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = yesterday.year == dt.year &&
        yesterday.month == dt.month &&
        yesterday.day == dt.day;

    final timeStr = DateFormat.Hm().format(dt);
    if (isToday) {
      return timeStr;
    } else if (isYesterday) {
      return '${DateFormat.E().format(dt)} $timeStr';
    } else {
      return DateFormat('d MMM, HH:mm').format(dt);
    }
  }
}
