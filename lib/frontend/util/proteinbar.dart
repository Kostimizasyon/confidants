import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

OverlayEntry? _currentOverlayEntry;

void proteinBar(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? backgroundColor,
  Color? textColor,
  Color? iconColor,
  int duration = 3,
}) {
  if (_currentOverlayEntry != null) {
    if (_currentOverlayEntry!.mounted) {
      _currentOverlayEntry!.remove();
    }
    _currentOverlayEntry = null;
  }

  final overlay = Overlay.of(context);

  final bgColor = backgroundColor ?? AppColors.surfaceDark;
  final txtColor = textColor ?? AppColors.surfaceLight;
  final icnColor = iconColor ?? AppColors.surfaceLight;

  final newEntry = OverlayEntry(
    builder: (context) => _ProteinBarWidget(
      message: message,
      icon: icon,
      bgColor: bgColor,
      txtColor: txtColor,
      icnColor: icnColor,
      onDismiss: () {
        if (_currentOverlayEntry != null && _currentOverlayEntry!.mounted) {
          _currentOverlayEntry!.remove();
          _currentOverlayEntry = null;
        }
      },
    ),
  );

  _currentOverlayEntry = newEntry;
  overlay.insert(newEntry);

  Future.delayed(Duration(seconds: duration), () {
    if (newEntry.mounted && _currentOverlayEntry == newEntry) {
      newEntry.remove();
      _currentOverlayEntry = null;
    }
  });
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0.0
        ? MediaQuery.of(context).viewInsets.bottom + 20
        : MediaQuery.of(context).size.height * 0.1;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding, left: 32, right: 32),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta! > 10) widget.onDismiss();
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
                        color: widget.bgColor.withAlpha(85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.surfaceLight.withAlpha(10),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.backgroundDark.withAlpha(20),
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
    );
  }
}
