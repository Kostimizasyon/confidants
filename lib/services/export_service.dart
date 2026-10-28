import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../data_models/user_profile.dart';
import 'database_helper.dart';
import 'hash_service.dart';

/// Writes one JSON "context chunk" per training-enabled profile so a local
/// mini-LLM can ingest them, and keeps the `file_mappings` table in step.
///
/// Files are named after the profile's SHA-256 hash (never the phone number or
/// name), and the exported JSON omits the raw phone number.
class ExportService {
  ExportService._();

  static final ExportService instance = ExportService._();

  static const String chunkDirectoryName = 'ai_context_chunks';

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Directory> _chunkDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, chunkDirectoryName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _fileNameFor(String profileHash) => '$profileHash.json';

  /// Exports [profile], or removes its chunk when training is disabled.
  /// Returns `true` when the profile's on-disk state now matches the database.
  Future<bool> syncProfile(UserProfile profile) async {
    if (!profile.isTrainingEnabled) {
      return removeProfileChunk(profile.profileHash);
    }

    try {
      final dir = await _chunkDirectory();
      final file = File(p.join(dir.path, _fileNameFor(profile.profileHash)));

      final payload = const JsonEncoder.withIndent(
        '  ',
      ).convert(profile.toExportJson());
      final checksum = HashService.computeChecksum(payload);

      final existing = await _dbHelper.getFileMapping(profile.profileHash);
      if (existing != null &&
          existing['checksum'] == checksum &&
          await file.exists()) {
        return true;
      }

      await file.writeAsString(payload, flush: true);
      await _dbHelper.upsertFileMapping(
        profileHash: profile.profileHash,
        filePath: file.path,
        exportedAt: DateTime.now().millisecondsSinceEpoch,
        checksum: checksum,
      );
      return true;
    } on FileSystemException {
      return false;
    }
  }

  /// Deletes the chunk file and its mapping row for [profileHash].
  Future<bool> removeProfileChunk(String profileHash) async {
    try {
      final dir = await _chunkDirectory();
      final file = File(p.join(dir.path, _fileNameFor(profileHash)));
      if (await file.exists()) {
        await file.delete();
      }
      await _dbHelper.deleteFileMapping(profileHash);
      return true;
    } on FileSystemException {
      return false;
    }
  }

  /// Reconciles the chunk folder with the database: exports every
  /// training-enabled profile and removes chunks that no longer belong.
  /// Returns the number of chunks that exist afterwards.
  Future<int> syncAll() async {
    final profiles = await _dbHelper.getAllProfiles();
    final enabledHashes = <String>{};

    for (final profile in profiles) {
      if (profile.isTrainingEnabled) {
        enabledHashes.add(profile.profileHash);
      }
      await syncProfile(profile);
    }

    final mappings = await _dbHelper.getAllFileMappings();
    for (final mapping in mappings) {
      final hash = mapping['profile_hash'] as String;
      if (!enabledHashes.contains(hash)) {
        await removeProfileChunk(hash);
      }
    }

    return enabledHashes.length;
  }

  /// Chunk files currently on disk, in no particular order.
  Future<List<File>> listChunkFiles() async {
    final dir = await _chunkDirectory();
    return dir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .cast<File>()
        .toList();
  }
}
