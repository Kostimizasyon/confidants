import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data_models/call_entry.dart';
import '../../data_models/contact_item.dart';
import '../../data_models/user_profile.dart';
import '../../services/call_log_service.dart';
import '../../services/contact_index.dart';
import '../../services/database_helper.dart';
import '../profiles_page/profile_detail_page.dart';
import '../theme/app_colors.dart';
import '../util/custom_app_bar.dart';
import '../util/l10n_extensions.dart';
import '../util/proteinbar.dart';
import 'util/call_log_tile.dart';
import 'util/dial_pad.dart';
import 'util/dialer_match_tile.dart';

class DialerPage extends StatefulWidget {
  const DialerPage({super.key});

  @override
  State<DialerPage> createState() => _DialerPageState();
}

class _DialerPageState extends State<DialerPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final CallLogService _callLogService = CallLogService.instance;

  bool _showKeypad = false;
  String _input = '';
  List<UserProfile> _matches = const [];
  int _searchGeneration = 0;

  List<CallEntry> _callLogs = const [];
  bool _isLoadingLogs = true;
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _dbHelper.revision.addListener(_onDatabaseChanged);
    _loadCallLogs();
  }

  @override
  void dispose() {
    _dbHelper.revision.removeListener(_onDatabaseChanged);
    super.dispose();
  }

  void _onDatabaseChanged() {
    if (_showKeypad) {
      _search(_input);
    }
    _loadCallLogs();
  }

  Future<void> _loadCallLogs() async {
    if (!_callLogService.isSupported) {
      if (mounted) {
        setState(() {
          _isLoadingLogs = false;
          _hasPermission = false;
          _callLogs = const [];
        });
      }
      return;
    }

    final hasPerm = await _callLogService.hasPermission();
    if (!mounted) return;

    if (!hasPerm) {
      setState(() {
        _hasPermission = false;
        _isLoadingLogs = false;
        _callLogs = const [];
      });
      return;
    }

    setState(() {
      _hasPermission = true;
      _isLoadingLogs = true;
    });

    final logs = await _callLogService.getCallLogs(limit: 100);
    if (!mounted) return;

    setState(() {
      _callLogs = logs;
      _isLoadingLogs = false;
    });
  }

  Future<void> _requestPermission() async {
    final granted = await _callLogService.requestPermission();
    if (!mounted) return;
    if (granted) {
      await _loadCallLogs();
    } else {
      setState(() {
        _hasPermission = false;
        _isLoadingLogs = false;
      });
    }
  }

  Future<void> _search(String input) async {
    final generation = ++_searchGeneration;
    final results = await _dbHelper.searchForDialer(input);
    if (!mounted || generation != _searchGeneration) return;
    setState(() => _matches = results);
  }

  void _setInput(String value) {
    setState(() {
      _input = ContactIndex.sanitizeDialInput(value);
      _showKeypad = true;
    });
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

  Future<void> _createProfileFromInput(String number) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProfileDetailPage.create(
          contact: ContactItem.phoneOnly(displayName: '', phoneNumber: number),
        ),
      ),
    );
  }

  void _openEntryOptions(CallEntry entry) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (entry.matchedConfidant != null) {
      Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ProfileDetailPage(
            initialProfile: entry.matchedConfidant!,
            isNew: false,
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    entry.displayTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(LucideIcons.phone, color: AppColors.success),
                  title: Text(l10n.dialerCallTooltip),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _call(entry.number);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.userPlus, color: AppColors.accentHighlight),
                  title: Text(l10n.dialerCreateProfile),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _createProfileFromInput(entry.number);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.copy, color: AppColors.textSecondaryDark),
                  title: Text(l10n.fieldPhone),
                  subtitle: Text(entry.number),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    Clipboard.setData(ClipboardData(text: entry.number));
                    proteinBar(context, '${entry.number} copied');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: CustomAppBar.dialer(
        leading: _showKeypad
            ? IconButton(
                icon: const Icon(LucideIcons.chevronDown, size: 22),
                tooltip: l10n.dialerHideKeypad,
                onPressed: () => setState(() => _showKeypad = false),
              )
            : null,
        actions: [
          if (!_showKeypad)
            IconButton(
              onPressed: () => setState(() => _showKeypad = true),
              icon: const Icon(LucideIcons.search, size: 22),
              tooltip: l10n.searchProfilesHint,
            ),
          if (_showKeypad && _input.isNotEmpty)
            IconButton(
              onPressed: () => _createProfileFromInput(_input),
              icon: const Icon(LucideIcons.userPlus, size: 22),
              tooltip: l10n.dialerCreateProfile,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _showKeypad ? _buildKeypadView(context) : _buildRecentCallsView(context),
        ),
      ),
      floatingActionButton: _showKeypad
          ? null
          : FloatingActionButton(
              onPressed: () => setState(() => _showKeypad = true),
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.surfaceLight,
              tooltip: l10n.dialerOpenKeypad,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(LucideIcons.grid3x3, size: 26),
            ),
    );
  }

  Widget _buildRecentCallsView(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (_isLoadingLogs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasPermission && _callLogService.isSupported) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.phoneCall,
                  size: 28,
                  color: AppColors.accentHighlight,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.recentCallsPermissionTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.recentCallsPermissionSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(LucideIcons.shieldCheck, size: 18),
                label: Text(l10n.recentCallsPermissionButton),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentHighlight,
                  foregroundColor: AppColors.primaryDarkBlue,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_callLogs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.phoneIncoming, size: 48, color: secondaryColor),
              const SizedBox(height: 12),
              Text(
                l10n.recentCallsEmpty,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCallLogs,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 84),
        itemCount: _callLogs.length,
        itemBuilder: (context, index) {
          final entry = _callLogs[index];
          return CallLogTile(
            entry: entry,
            onCall: () => _call(entry.number),
            onTap: () => _openEntryOptions(entry),
          );
        },
      ),
    );
  }

  Widget _buildKeypadView(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final accentColor =
        isDark ? AppColors.accentHighlight : AppColors.primaryDarkBlue;

    return Column(
      children: [
        // Live matches above the pad
        Expanded(child: _buildMatchArea(context, secondaryColor, accentColor)),
        // Active number display
        Padding(
          padding: const EdgeInsets.fromLTRB(56, 8, 8, 2),
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
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
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
            ],
          ),
        ),
      ],
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
      return const SizedBox.shrink();
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
              onPressed: () => _createProfileFromInput(_input),
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
