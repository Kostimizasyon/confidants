import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../data_models/chat_message.dart';
import '../../theme/app_colors.dart';
import '../../util/l10n_extensions.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage chatMessage;
  final bool isUserBubble;

  const ChatBubble({
    super.key,
    required this.chatMessage,
    required this.isUserBubble,
  });

  const ChatBubble.user({
    super.key,
    required this.chatMessage,
  }) : isUserBubble = true;

  const ChatBubble.ai({
    super.key,
    required this.chatMessage,
  }) : isUserBubble = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final userBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;
    final aiBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final timeLabel =
        '${chatMessage.timestamp.hour.toString().padLeft(2, '0')}:${chatMessage.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUserBubble ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserBubble) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: userBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                chatMessage.isError ? LucideIcons.circleAlert : LucideIcons.bot,
                size: 16,
                color: AppColors.surfaceLight,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUserBubble ? userBg : aiBg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUserBubble ? 14 : 4),
                  bottomRight: Radius.circular(isUserBubble ? 4 : 14),
                ),
                border: isUserBubble ? null : Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (chatMessage.isGenerating)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.chatGeneratingStatus,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      chatMessage.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUserBubble ? AppColors.surfaceLight : null,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    timeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: isUserBubble
                          ? AppColors.accentHighlight
                          : secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUserBubble) ...[
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.user,
                size: 16,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.primaryDarkBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
