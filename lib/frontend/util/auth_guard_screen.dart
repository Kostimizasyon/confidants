import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';
import '../theme/app_colors.dart';
import 'l10n_extensions.dart';
import 'navigation_shell.dart';

class AuthGuardScreen extends StatefulWidget {
  const AuthGuardScreen({super.key});

  @override
  State<AuthGuardScreen> createState() => _AuthGuardScreenState();
}

class _AuthGuardScreenState extends State<AuthGuardScreen> {
  final PreferencesService _prefs = PreferencesService.instance;
  final AuthService _authService = AuthService.instance;

  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  bool _authFailed = false;

  @override
  void initState() {
    super.initState();
    if (!_prefs.requireFingerprintLock) {
      _isAuthenticated = true;
      return;
    }
    // Localized prompt text needs an inherited widget, so wait for the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _triggerBiometricPrompt();
    });
  }

  Future<void> _triggerBiometricPrompt() async {
    if (_isAuthenticating) return;
    final reason = context.l10n.authUnlockReason;
    setState(() {
      _isAuthenticating = true;
      _authFailed = false;
    });

    final success = await _authService.authenticate(reason: reason);
    if (!mounted) return;

    setState(() {
      _isAuthenticated = success;
      _isAuthenticating = false;
      _authFailed = !success;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return const NavigationShell.chat();
    }

    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final badgeColor =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _authFailed ? LucideIcons.shieldAlert : LucideIcons.fingerprint,
                    size: 34,
                    color: AppColors.surfaceLight,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.authVaultLockedTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  _authFailed
                      ? l10n.authVaultFailedMessage
                      : l10n.authVaultLockedMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                if (_isAuthenticating)
                  const CircularProgressIndicator()
                else
                  FilledButton.icon(
                    onPressed: _triggerBiometricPrompt,
                    style: FilledButton.styleFrom(
                      backgroundColor: badgeColor,
                      foregroundColor: AppColors.surfaceLight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    icon: const Icon(LucideIcons.keyRound, size: 18),
                    label: Text(l10n.authUnlockButton),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
