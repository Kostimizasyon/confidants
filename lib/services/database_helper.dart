import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../data_models/custom_field.dart';
import '../data_models/user_profile.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'confidants.db';
  static const int _dbVersion = 2;

  static const String tableProfiles = 'profiles';
  static const String tableCustomFields = 'custom_fields';
  static const String tableFileMappings = 'file_mappings';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _dbName);

    return openDatabase(
      fullPath,
      version: _dbVersion,
      onConfigure: (db) async {
        // Enforces cascade deletion of custom_fields when a parent profile is deleted.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProfiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_hash TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        email TEXT,
        birthday TEXT,
        nickname TEXT,
        notes_to_remember TEXT NOT NULL,
        likes TEXT NOT NULL,
        dislikes TEXT NOT NULL,
        hobbies TEXT NOT NULL,
        avatar_icon TEXT NOT NULL DEFAULT 'user',
        is_favorite INTEGER NOT NULL DEFAULT 0,
        is_training_enabled INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCustomFields (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        field_key TEXT NOT NULL,
        field_value TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES $tableProfiles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableFileMappings (
        profile_hash TEXT PRIMARY KEY,
        file_path TEXT NOT NULL,
        exported_at INTEGER NOT NULL,
        checksum TEXT NOT NULL
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_custom_fields_profile_id ON $tableCustomFields (profile_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE $tableProfiles ADD COLUMN avatar_icon TEXT NOT NULL DEFAULT 'user'",
      );
      await db.execute(
        "ALTER TABLE $tableProfiles ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0",
      );
    }
  }

  Future<int> saveProfile(UserProfile profile) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedProfile = profile.copyWith(updatedAt: now);

    return db.transaction((txn) async {
      int profileId;
      if (updatedProfile.id != null) {
        profileId = updatedProfile.id!;
        await txn.update(
          tableProfiles,
          updatedProfile.toMap(),
          where: 'id = ?',
          whereArgs: [profileId],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        final existing = await txn.query(
          tableProfiles,
          columns: ['id', 'created_at'],
          where: 'profile_hash = ?',
          whereArgs: [updatedProfile.profileHash],
          limit: 1,
        );

        if (existing.isNotEmpty) {
          profileId = existing.first['id'] as int;
          final originalCreatedAt = existing.first['created_at'] as int;
          final mergedMap = updatedProfile
              .copyWith(id: profileId, createdAt: originalCreatedAt)
              .toMap();
          await txn.update(
            tableProfiles,
            mergedMap,
            where: 'id = ?',
            whereArgs: [profileId],
          );
        } else {
          profileId = await txn.insert(
            tableProfiles,
            updatedProfile.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      await txn.delete(
        tableCustomFields,
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );

      for (final field in updatedProfile.customFields) {
        if (field.fieldKey.trim().isEmpty) continue;
        await txn.insert(
          tableCustomFields,
          field.toMap(overrideProfileId: profileId),
        );
      }

      return profileId;
    });
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      tableProfiles,
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<UserProfile>> getAllProfiles({String? searchQuery}) async {
    final db = await database;
    final trimmed = searchQuery?.trim() ?? '';

    final List<Map<String, dynamic>> profileRows;
    if (trimmed.isEmpty) {
      profileRows = await db.query(
        tableProfiles,
        orderBy: 'is_favorite DESC, name COLLATE NOCASE ASC',
      );
    } else {
      final pattern = '%$trimmed%';
      profileRows = await db.query(
        tableProfiles,
        where:
            'name LIKE ? OR phone_number LIKE ? OR nickname LIKE ? OR notes_to_remember LIKE ?',
        whereArgs: [pattern, pattern, pattern, pattern],
        orderBy: 'is_favorite DESC, name COLLATE NOCASE ASC',
      );
    }

    return _hydrateProfilesWithCustomFields(db, profileRows);
  }

  Future<List<UserProfile>> getTrainingEnabledProfiles() async {
    final db = await database;
    final profileRows = await db.query(
      tableProfiles,
      where: 'is_training_enabled = ?',
      whereArgs: [1],
      orderBy: 'is_favorite DESC, name COLLATE NOCASE ASC',
    );
    return _hydrateProfilesWithCustomFields(db, profileRows);
  }

  Future<UserProfile?> getProfileById(int id) async {
    final db = await database;
    final rows = await db.query(
      tableProfiles,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final hydrated = await _hydrateProfilesWithCustomFields(db, rows);
    return hydrated.first;
  }

  Future<UserProfile?> getProfileByHash(String profileHash) async {
    final db = await database;
    final rows = await db.query(
      tableProfiles,
      where: 'profile_hash = ?',
      whereArgs: [profileHash],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final hydrated = await _hydrateProfilesWithCustomFields(db, rows);
    return hydrated.first;
  }

  Future<int> deleteProfile(int id) async {
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        tableProfiles,
        columns: ['profile_hash'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (rows.isNotEmpty) {
        final hash = rows.first['profile_hash'] as String;
        await txn.delete(
          tableFileMappings,
          where: 'profile_hash = ?',
          whereArgs: [hash],
        );
      }

      return txn.delete(
        tableProfiles,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> upsertFileMapping({
    required String profileHash,
    required String filePath,
    required int exportedAt,
    required String checksum,
  }) async {
    final db = await database;
    await db.insert(
      tableFileMappings,
      {
        'profile_hash': profileHash,
        'file_path': filePath,
        'exported_at': exportedAt,
        'checksum': checksum,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getFileMapping(String profileHash) async {
    final db = await database;
    final rows = await db.query(
      tableFileMappings,
      where: 'profile_hash = ?',
      whereArgs: [profileHash],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getAllFileMappings() async {
    final db = await database;
    return db.query(
      tableFileMappings,
      orderBy: 'exported_at DESC',
    );
  }

  Future<void> deleteFileMapping(String profileHash) async {
    final db = await database;
    await db.delete(
      tableFileMappings,
      where: 'profile_hash = ?',
      whereArgs: [profileHash],
    );
  }

  Future<List<UserProfile>> _hydrateProfilesWithCustomFields(
    DatabaseExecutor db,
    List<Map<String, dynamic>> profileRows,
  ) async {
    if (profileRows.isEmpty) return const [];

    final allCustomRows = await db.query(tableCustomFields);
    final groupedFields = <int, List<CustomField>>{};

    for (final row in allCustomRows) {
      final field = CustomField.fromMap(row);
      final pId = field.profileId;
      if (pId != null) {
        groupedFields.putIfAbsent(pId, () => []).add(field);
      }
    }

    return profileRows.map((row) {
      final id = row['id'] as int?;
      final fields = id != null ? (groupedFields[id] ?? const []) : const <CustomField>[];
      return UserProfile.fromMap(row, customFields: fields);
    }).toList();
  }
}
