import 'package:confidants/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data_models/chat_message.dart';
import '../../services/ai_service.dart';
import '../../services/preferences_service.dart';
import '../theme/app_colors.dart';
import '../util/custom_app_bar.dart';
import '../util/l10n_extensions.dart';
import '../util/proteinbar.dart';
import 'util/chat_bubble.dart';
import 'util/chat_input_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final PreferencesService _prefs = PreferencesService.instance;
  final AiService _aiService = AiService.instance;
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;
  int _indexedChunks = 0;

  @override
  void initState() {
    super.initState();
    _refreshChunkCount();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshChunkCount() async {
    final count = await _aiService.getIndexedChunkCount();
    if (!mounted) return;
    setState(() => _indexedChunks = count);
  }

  Future<void> _handleSend(String query) async {
    final l10n = context.l10n;
    final userMsg = ChatMessage.user(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      message: query,
    );
    final placeholderId = '${userMsg.id}_ai';
    final loadingMsg = ChatMessage.ai(
      id: placeholderId,
      message: '',
      isGenerating: true,
    );

    setState(() {
      _messages.add(userMsg);
      _messages.add(loadingMsg);
      _isGenerating = true;
    });
    _scrollToBottom();

    try {
      await _refreshChunkCount();
      final replyText = await _aiService.generateResponse(
        userQuery: query,
        noContextMessage: l10n.chatNoContextResponse,
        noMatchMessage: l10n.chatNoMatchSummary,
        formatMockResponse: l10n.chatMockPrefix,
      );

      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == placeholderId);
        if (idx != -1) {
          _messages[idx] = ChatMessage.ai(
            id: placeholderId,
            message: replyText,
          );
        }
        _isGenerating = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == placeholderId);
        if (idx != -1) {
          _messages[idx] = ChatMessage.ai(
            id: placeholderId,
            message: l10n.chatErrorResponse,
            isError: true,
          );
        }
        _isGenerating = false;
      });
    }

    _scrollToBottom();
  }

  void _clearChat() {
    final l10n = context.l10n;
    setState(_messages.clear);
    proteinBar(
      context,
      l10n.chatClearedToast,
      icon: LucideIcons.trash2,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ValueListenableBuilder<bool>(
      valueListenable: _prefs.isAiEnabledNotifier,
      builder: (context, isAiEnabled, _) {
        return Scaffold(
          appBar: CustomAppBar.chat(
            actions: [
              if (isAiEnabled && _messages.isNotEmpty)
                IconButton(
                  onPressed: _clearChat,
                  icon: const Icon(LucideIcons.trash2, size: 19),
                  tooltip: l10n.chatClearTooltip,
                ),
            ],
          ),
          body: !isAiEnabled
              ? _ChatStateView.optInRequired(
                  onEnable: () => _prefs.setAiEnabled(true),
                )
              : Column(
                  children: [
                    Expanded(
                      child: _messages.isEmpty
                          ? ValueListenableBuilder<String>(
                              valueListenable: _prefs.selectedModelIdNotifier,
                              builder: (context, _, _) {
                                return _ChatStateView.ready(
                                  modelName: _prefs.activeAiModel.displayName,
                                  chunkCount: _indexedChunks,
                                );
                              },
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                return msg.isUser
                                    ? ChatBubble.user(chatMessage: msg)
                                    : ChatBubble.ai(chatMessage: msg);
                              },
                            ),
                    ),
                    ChatInputBar(
                      onSend: _handleSend,
                      isBusy: _isGenerating,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ChatStateView extends StatelessWidget {
  final IconData icon;
  final L10nText titleOf;
  final L10nText subtitleOf;
  final VoidCallback? onEnable;

  const _ChatStateView.optInRequired({
    required VoidCallback this.onEnable,
  })  : icon = LucideIcons.shieldOff,
        titleOf = _optInTitle,
        subtitleOf = _optInSubtitle;

  _ChatStateView.ready({
    required String modelName,
    required int chunkCount,
  })  : icon = LucideIcons.botMessageSquare,
        titleOf = _readyTitle,
        subtitleOf = ((l10n) => l10n.chatEmptySubtitle(modelName, chunkCount)),
        onEnable = null;

  static String _optInTitle(AppLocalizations l10n) =>
      l10n.chatOptInRequiredTitle;
  static String _optInSubtitle(AppLocalizations l10n) =>
      l10n.chatOptInRequiredSubtitle;
  static String _readyTitle(AppLocalizations l10n) => l10n.chatEmptyTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final btnBg =
        isDark ? AppColors.secondaryDarkBlue : AppColors.primaryDarkBlue;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 44,
              color: isDark
                  ? AppColors.accentHighlight
                  : AppColors.primaryDarkBlue,
            ),
            const SizedBox(height: 16),
            Text(
              titleOf(l10n),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitleOf(l10n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (onEnable != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onEnable,
                style: FilledButton.styleFrom(
                  backgroundColor: btnBg,
                  foregroundColor: AppColors.surfaceLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                icon: const Icon(LucideIcons.sparkles, size: 17),
                label: Text(l10n.chatOptInButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
