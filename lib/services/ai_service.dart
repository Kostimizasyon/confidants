import 'dart:convert';
import 'dart:io';
import '../data_models/ai_model_config.dart';
import 'export_service.dart';
import 'preferences_service.dart';

class AiService {
  AiService._();

  static final AiService instance = AiService._();

  final ExportService _exportService = ExportService.instance;
  final PreferencesService _prefs = PreferencesService.instance;

  AiModelConfig get activeModel => _prefs.activeAiModel;

  Future<int> getIndexedChunkCount() async {
    final files = await _exportService.listChunkFiles();
    return files.length;
  }

  Future<String> generateResponse({
    required String userQuery,
    required String noContextMessage,
    required String noMatchMessage,
    required String Function(String modelName, int chunkCount, String summary)
        formatMockResponse,
  }) async {
    final contextChunks = await _exportService.listChunkFiles();
    if (contextChunks.isEmpty) {
      return noContextMessage;
    }

    final parsedChunks = await _readChunkPayloads(contextChunks);
    final systemPrompt = _buildSystemPrompt(parsedChunks);
    final model = activeModel;

    // TODO: AI API call - Ingest context files from ExportService and dispatch prompt to local LLM
    // Expected input: List<File> contextChunks, String userQuery (plus AiModelConfig model & String systemPrompt)
    // Expected output: Stream<String> or Future<String> modelResponse
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final matchedSummary = _searchContextChunks(
      query: userQuery,
      chunks: parsedChunks,
      systemPrompt: systemPrompt,
    );

    return formatMockResponse(
      model.displayName,
      parsedChunks.length,
      matchedSummary ?? noMatchMessage,
    );
  }

  Future<List<Map<String, dynamic>>> _readChunkPayloads(
    List<File> files,
  ) async {
    final payloads = <Map<String, dynamic>>[];
    for (final file in files) {
      try {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          payloads.add(decoded);
        }
      } on Object {
        continue;
      }
    }
    return payloads;
  }

  String _buildSystemPrompt(List<Map<String, dynamic>> chunks) {
    final buffer = StringBuffer(
      'You are Confidants AI, an offline personal memory assistant. '
      'Answer the user strictly using the following JSON profile chunks:\n',
    );
    for (final chunk in chunks) {
      buffer.writeln(jsonEncode(chunk));
    }
    return buffer.toString();
  }

  String? _searchContextChunks({
    required String query,
    required List<Map<String, dynamic>> chunks,
    required String systemPrompt,
  }) {
    if (systemPrompt.isEmpty) return null;

    final tokens = query
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9ğüşıöç]+'))
        .where((t) => t.length >= 2)
        .toList();

    if (tokens.isEmpty) return null;

    final matches = <String>[];
    for (final chunk in chunks) {
      final rawText = jsonEncode(chunk).toLowerCase();
      final hit = tokens.any(rawText.contains);
      if (hit) {
        matches.add(_formatChunkSummary(chunk));
      }
    }

    if (matches.isEmpty) return null;
    return matches.join('\n\n');
  }

  String _formatChunkSummary(Map<String, dynamic> chunk) {
    final name = (chunk['name'] as String?) ?? '';
    final nickname = chunk['nickname'] as String?;
    final birthday = chunk['birthday'] as String?;
    final notes = (chunk['notes_to_remember'] as String?) ?? '';
    final likes = (chunk['likes'] as List<dynamic>?)?.join(', ') ?? '';
    final dislikes = (chunk['dislikes'] as List<dynamic>?)?.join(', ') ?? '';
    final hobbies = (chunk['hobbies'] as List<dynamic>?)?.join(', ') ?? '';
    final custom = chunk['custom_attributes'] as Map<String, dynamic>?;

    final lines = <String>[
      if (nickname != null && nickname.isNotEmpty)
        '• $name ($nickname)'
      else
        '• $name',
      if (birthday != null && birthday.isNotEmpty) '  Birthday: $birthday',
      if (likes.isNotEmpty) '  Likes: $likes',
      if (dislikes.isNotEmpty) '  Dislikes: $dislikes',
      if (hobbies.isNotEmpty) '  Hobbies: $hobbies',
      if (notes.isNotEmpty) '  Notes: $notes',
      if (custom != null && custom.isNotEmpty)
        '  Attributes: ${custom.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
    ];

    return lines.join('\n');
  }
}
