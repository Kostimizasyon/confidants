import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data_models/contact_item.dart';
import '../../data_models/user_profile.dart';
import '../../services/contact_index.dart';
import '../../services/database_helper.dart';
import '../profiles_page/profile_detail_page.dart';
import '../theme/app_colors.dart';
import '../util/custom_app_bar.dart';
import '../util/l10n_extensions.dart';
import '../util/proteinbar.dart';
import 'util/dial_pad.dart';
import 'util/dialer_match_tile.dart';

class DialerPage extends StatefulWidget {
  const DialerPage({super.key});

  @override
  State<DialerPage> createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _input = '';
  List<UserProfile> _matches = const [];
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    _dbHelper.revision.addListener(_refreshMatches);
  }

  @override
  void dispose() {
    _dbHelper.revision.removeListener(_refreshMatches);
    super.dispose();
  }

  void _refreshMatches() => _search(_input);

  Future<void> _search(String input) async {
    // Generation counter drops stale results when the user types quickly.
    final generation = ++_searchGeneration;
    final results = await _dbHelper.searchForDialer(input);
    if (!mounted || generation != _searchGeneration) return;
    setState(() => _matches = results);
  }

  void _setInput(String value) {
    setState(() => _input = ContactIndex.sanitizeDialInput(value));
    _search(_input);
  }

  void _handleKey(String key) => _setInput(_input + key);

  void _handleBackspace() {
    if (_input.isEmpty) return;
    _setInput(_input.substring(0, _input.length - 1));
  }

  Future<void> _call(String rawNumber) async {
    final number = ContactIndex.sanitizeDialInput(rawNumber);
    if (number.isEmpty) return;
    final l10n = context.l10n;

    var launched = false;
    try {
      launched = await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {
      launched = false;
    }

    if (!launched && mounted) {
      proteinBar(context, l10n.dialerCallFailed, icon: LucideIcons.phoneOff);
    }
  }

  Future<void> _createProfileFromInput() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileDetailPage.create(
          contact: ContactItem.phoneOnly(displayName: '', phoneNumber: _input),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final accentColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;

    return Scaffold(
      appBar: const CustomAppBar.dialer(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Live matches above the pad.
            Expanded(child: _buildMatchArea(context, secondaryColor, accentColor)),
            Divider(height: 1, color: borderColor),
            // Active number display.
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 12, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _input,
                        maxLines: 1,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: _input.isEmpty
                        ? null
                        : GestureDetector(
                            onLongPress: () => _setInput(''),
                            child: IconButton(
                              onPressed: _handleBackspace,
                              tooltip: l10n.dialerBackspaceTooltip,
                              icon: Icon(
                                LucideIcons.delete,
                                size: 22,
                                color: secondaryColor,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: DialPad(onKeyPressed: _handleKey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: SizedBox(
                width: 64,
                height: 64,
                child: FilledButton(
                  onPressed: _input.isEmpty ? null : () => _call(_input),
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.surfaceLight,
                    disabledBackgroundColor:
                        AppColors.success.withValues(alpha: 0.35),
                    disabledForegroundColor: AppColors.surfaceLight,
                  ),
                  child: Semantics(
                    label: l10n.dialerCallTooltip,
                    child: const Icon(LucideIcons.phone, size: 26),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchArea(
    BuildContext context,
    Color secondaryColor,
    Color accentColor,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (_input.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            l10n.dialerEmptyHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
          ),
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dialerNoMatches,
              style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _createProfileFromInput,
              icon: Icon(LucideIcons.userPlus, size: 18, color: accentColor),
              label: Text(
                l10n.dialerCreateProfile,
                style: TextStyle(color: accentColor),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final profile = _matches[index];
        return DialerMatchTile(
          profile: profile,
          onSelect: () => _setInput(profile.phoneNumber),
          onCall: () => _call(profile.phoneNumber),
        );
      },
    );
  }
}
