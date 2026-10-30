import 'package:flutter/material.dart';
import '../../../services/contact_index.dart';
import '../../theme/app_colors.dart';

/// 12-key numeric pad (1–9, *, 0, #) with T9 letters under each digit.
/// Long-pressing `0` types `+`.
class DialPad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;

  const DialPad({
    super.key,
    required this.onKeyPressed,
  });

  static const List<List<String>> _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['*', '0', '#'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in _rows)
          Row(
            children: [
              for (final key in row)
                Expanded(
                  child: _DialKey(
                    digit: key,
                    letters: ContactIndex.keypadLetters[key] ?? '',
                    onTap: () => onKeyPressed(key),
                    onLongPress: key == '0' ? () => onKeyPressed('+') : null,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DialKey extends StatelessWidget {
  final String digit;
  final String letters;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _DialKey({
    required this.digit,
    required this.letters,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final digitColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final lettersColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(32),
          child: SizedBox(
            height: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  digit,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: digitColor,
                    fontWeight: FontWeight.w400,
                    height: 1.1,
                  ),
                ),
                SizedBox(
                  height: 14,
                  child: Text(
                    letters,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: lettersColor,
                      fontSize: 10,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
