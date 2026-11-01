import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';

OverlayEntry? _currentOverlayEntry;
Timer? _autoDismissTimer;

/// Frosted capsule toast notification.
///
/// Can be invoked via [ProteinBar], [ProteinBar.success], [ProteinBar.fail],
/// or the legacy [proteinBar] helper function.
class ProteinBar {
  ProteinBar(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    int duration = 3,
  }) {
    show(
      context,
      message,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
      iconColor: iconColor,
      duration: duration,
    );
  }

  /// Green success toast with checkmark icon by default.
  ProteinBar.success(
    BuildContext context,
    String message, {
    IconData? icon,
    int duration = 3,
  }) : this(
          context,
          message,
          icon: icon ?? LucideIcons.check,
          backgroundColor: AppColors.success,
          textColor: AppColors.surfaceLight,
          iconColor: AppColors.surfaceLight,
          duration: duration,
        );

  /// Red failure/error toast with alert icon by default.
  ProteinBar.fail(
    BuildContext context,
    String message, {
    IconData? icon,
    int duration = 3,
  }) : this(
          context,
          message,
          icon: icon ?? LucideIcons.circleAlert,
          backgroundColor: AppColors.error,
          textColor: AppColors.surfaceLight,
          iconColor: AppColors.surfaceLight,
          duration: duration,
        );

  /// Dismisses any currently visible [ProteinBar].
  static void dismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    if (_currentOverlayEntry != null && _currentOverlayEntry!.mounted) {
      _currentOverlayEntry!.remove();
      _currentOverlayEntry = null;
    }
  }

  /// Displays the overlay entry.
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    int duration = 3,
  }) {
    dismiss();

    final overlay = Overlay.maybeOf(context) ?? Overlay.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final txtColor = textColor ??
        (backgroundColor != null
            ? AppColors.surfaceLight
            : (isDark ? AppColors.surfaceLight : AppColors.textPrimaryLight));
    final icnColor = iconColor ?? txtColor;

    late OverlayEntry newEntry;
    newEntry = OverlayEntry(
      builder: (context) => _ProteinBarWidget(
        message: message,
        icon: icon,
        bgColor: bgColor,
        txtColor: txtColor,
        icnColor: icnColor,
        onDismiss: () {
          if (newEntry.mounted && _currentOverlayEntry == newEntry) {
            dismiss();
          }
        },
      ),
    );

    _currentOverlayEntry = newEntry;
    overlay.insert(newEntry);

    _autoDismissTimer = Timer(Duration(seconds: duration), () {
      if (newEntry.mounted && _currentOverlayEntry == newEntry) {
        newEntry.remove();
        _currentOverlayEntry = null;
      }
      _autoDismissTimer = null;
    });
  }
}

/// Legacy functional interface delegating to [ProteinBar].
void proteinBar(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? backgroundColor,
  Color? textColor,
  Color? iconColor,
  int duration = 3,
}) {
  ProteinBar(
    context,
    message,
    icon: icon,
    backgroundColor: backgroundColor,
    textColor: textColor,
    iconColor: iconColor,
    duration: duration,
  );
}

class _ProteinBarWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color bgColor;
  final Color txtColor;
  final Color icnColor;
  final VoidCallback onDismiss;

  const _ProteinBarWidget({
    required this.message,
    this.icon,
    required this.bgColor,
    required this.txtColor,
    required this.icnColor,
    required this.onDismiss,
  });

  @override
  State<_ProteinBarWidget> createState() => _ProteinBarWidgetState();
}

class _ProteinBarWidgetState extends State<_ProteinBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    if (_dismissed) return;
    _dismissed = true;
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0.0
        ? MediaQuery.of(context).viewInsets.bottom + 20
        : MediaQuery.of(context).size.height * 0.1;

    final isSpecialStatus = widget.bgColor == AppColors.success ||
        widget.bgColor == AppColors.error;
    final bgAlpha = isSpecialStatus ? 0.90 : 0.85;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding, left: 32, right: 32),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleDismiss,
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! > 8) _handleDismiss();
                },
                child: Material(
                  color: AppColors.transparent,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: widget.bgColor.withValues(alpha: bgAlpha),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSpecialStatus
                                ? AppColors.surfaceLight.withValues(alpha: 0.25)
                                : AppColors.surfaceLight.withValues(alpha: 0.10),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.backgroundDark.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, color: widget.icnColor, size: 20),
                              const SizedBox(width: 10),
                            ],
                            Flexible(
                              child: Text(
                                widget.message,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: widget.txtColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
